# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  belongs_to :user
  validates :user_id, :start_date, :end_date, :type, presence: true

  validate :verify_dates
  validate :check_date_conflicts

  validate :check_user_attributes
  before_save :update_google_calendar
  before_destroy :delete_event_google_calendar

  after_initialize :set_default_values, if: :new_record?

  def business_days_between(start_date, end_date)
    business_days = 0
    while end_date >= start_date
      business_days += 1 unless end_date.saturday? || end_date.sunday?
      end_date -= 1.day
    end
    business_days

    # TODO
    # Create an array of dates =  [start_date, +1,.., end_date]
    # dates.collect {|d| d.day}.reject {|d| ['satruday', 'sunday'].include?(d).count
  end

  # TODO: Move 3 methods to FY models
  def year_and_quarter(date)
    quarters = %w[q4 q1 q2 q3]
    get_financial_year(date) + quarters[(date.month - 1) / 3]
  end

  def end_month_of_quarter(date)
    quarter_end_months = [3, 6, 9, 12]
    quarter_end_months[(date.month - 1) / 3]
  end

  def start_month_of_quarter(date)
    quarter_start_months = [1, 4, 7, 10]
    quarter_start_months[(date.month - 1) / 3]
  end

  private

  def verify_dates
    return unless start_date && end_date &&
                  start_date > end_date
    errors.add(:start_date, 'must be before end date')
  end

  # checks whether current leave has any conflicts with previous leaves
  def check_date_conflicts
    return unless start_date && end_date
    user.ooo_periods.each do |ooo_period|
      next if ooo_period == self
      next unless start_date <= ooo_period.end_date &&
                  ooo_period.start_date <= end_date
      errors.add(
        :generic,
        'dates are overlapping with previous OOO Period dates. Please correct.'
      )
      break
    end
  end

  def check_user_attributes
    return unless start_date && end_date
    # TODO: Dont store the derivable number_of_days
    set_number_of_business_days
    leave? ? check_user_leaves : check_user_wfhs
  end

  def update_google_calendar
    if changes.key?(:type) && type_was
      begin
        google_client.delete_event(type_change_calendar_id, google_event_id)
        insert_calendar
      rescue
        logger.info "the event(#{google_event_id}) you are trying to delete\
        has already been deleted"
      end
    else
      google_event_id.blank? ? insert_calendar : edit_calendar
    end
  end

  def delete_event_google_calendar
    client = google_client
    begin
      client.delete_event(calendar_id, google_event_id)
    rescue
      logger.info "the event(#{google_event_id}) you are trying to delete\
      has already been deleted"
    end
  end

  def set_default_values
    self.start_date = Time.zone.now.strftime('%Y-%m-%d') if start_date.blank?
    self.end_date = Time.zone.now.strftime('%Y-%m-%d') if end_date.blank?
  end

=begin
def number_of_days
  raise 'Should be defined in the concrete class'
end

and define this method in the concrete class.
=end

  def set_number_of_business_days
    number_of_days = business_days_between(
      start_date.to_date,
      end_date.to_date
    )
    if type == 'Wfh' && start_date.to_datetime - 450.minutes < DateTime.current
      self.number_of_days = number_of_days + 1
    else
      self.number_of_days = number_of_days
    end
  end

  def check_user_leaves
    leave_id = number_of_days_was ? id : nil
    if get_financial_year(start_date) == get_financial_year(end_date)
      validate_user_leaves(leave_id)
    else
      validate_user_leaves_in_two_fy(leave_id)
    end
  end

  def validate_user_leaves(leave_id)
    user_remaining_leaves = get_remaining_leaves(start_date, leave_id)
    return unless user_remaining_leaves < number_of_days
    add_error
  end

  def validate_user_leaves_in_two_fy(leave_id)
    user_remaining_leaves_in_start_date_fy =
      get_remaining_leaves(start_date, leave_id)
    no_of_days_in_start_date_fy = business_days_between(
      start_date.to_date,
      Date.new(start_date.year, 3, -1)
    )
    user_remaining_leaves_in_end_date_fy =
      get_remaining_leaves(end_date, leave_id)
    no_of_days_in_end_date_fy = business_days_between(
      Date.new(end_date.year, 4, 1),
      end_date.to_date
    )
    if user_remaining_leaves_in_start_date_fy < no_of_days_in_start_date_fy ||
       user_remaining_leaves_in_end_date_fy < no_of_days_in_end_date_fy
      add_error
    end
  end

  def get_remaining_leaves(date, leave_id)
    user.remaining_leaves(get_financial_year(date), leave_id)
  end

  def add_error
    errors.add(
      :generic,
      "you dont have enough #{type}s to apply this #{type}"
    )
  end

  def check_user_wfhs
    wfh_id = number_of_days_was ? id : nil
    if year_and_quarter(start_date) == year_and_quarter(end_date)
      validate_user_wfhs(start_date, wfh_id)
    else
      remaining_wfhs_in_start_date_quarter =
        get_remaining_wfhs(start_date, wfh_id)
      no_of_days_in_start_quarter = business_days_between(
        start_date.to_date,
        Date.new(start_date.year, end_month_of_quarter(start_date), -1)
      )
      remaining_wfhs_in_end_date_quarter = get_remaining_wfhs(end_date, wfh_id)
      no_of_days_in_end_date_quarter = business_days_between(
        Date.new(end_date.year, start_month_of_quarter(end_date), 1),
        end_date.to_date
      )
      if remaining_wfhs_in_start_date_quarter < no_of_days_in_start_quarter ||
         remaining_wfhs_in_end_date_quarter < no_of_days_in_end_date_quarter
        add_error
      end
    end
  end

  def validate_user_wfhs(date, wfh_id)
    user_remaining_wfhs = get_remaining_wfhs(date, wfh_id)
    return unless user_remaining_wfhs < number_of_days
    add_error
  end

  def get_remaining_wfhs(date, wfh_id)
    user.remaining_wfhs(get_financial_year(date), get_quarter(date), wfh_id)
  end

  def get_quarter(date)
    quarters = [4, 1, 2, 3]
    quarters[(date.month - 1) / 3]
  end

  def get_financial_year(date)
    if date.month > 3
      "#{date.year}-#{date.year + 1}"
    else
      "#{date.year - 1}-#{date.year}"
    end
  end

  def google_client
    calendar_service = Google::Apis::CalendarV3::CalendarService.new
    calendar_service.authorization = user.oauth_token
    calendar_service
  end

  def type_change_calendar_id
    type_was == 'Leave' ? OOO_CALENDAR_ID : WFH_CALENDAR_ID
  end

  def insert_calendar
    client = google_client
    event = Google::Apis::CalendarV3::Event.new ( {
      summary: "#{user.name}-#{type}",
      start: {
        date: start_date.strftime('%Y-%m-%d')
      },
      end: {
        date: (end_date + 1).strftime('%Y-%m-%d')
      }
    })
    # TODO: Fix calender issues
    begin
      response = client.insert_event(calendar_id, event)
      self.google_event_id = response.id
    rescue
      logger.info 'Authorisation failure,event cannot be\
      created in google calendar'
    end
  end

  def edit_calendar
    client = google_client
    begin
      event = client.get_event(calendar_id, google_event_id)
      event.start.date = start_date.strftime('%Y-%m-%d')
      event.end.date = (end_date + 1).strftime('%Y-%m-%d')
      client.update_event(calendar_id, event.id, event)
    rescue
      logger.info 'Authorisation failure,event cannot be\
      fetched from google calendar'
    end
  end

  def calendar_id
    leave? ? OOO_CALENDAR_ID : WFH_CALENDAR_ID
  end

  def leave?
    type == 'Leave'
  end
end
