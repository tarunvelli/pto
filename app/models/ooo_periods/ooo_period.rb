# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  belongs_to :user
  validates :user_id, :start_date, :end_date, :type, presence: true

  validate :verify_dates
  validate :check_date_conflicts

  before_save :set_number_of_business_days
  before_save :update_user_attributes
  before_save :update_google_calendar
  after_save :save_user
  before_destroy :update_user_remaining_attributes
  before_destroy :delete_event_google_calendar
  after_destroy :save_user

  def self.business_days_between(start_date, end_date)
    business_days = 0
    while end_date >= start_date
      business_days += 1 unless holiday?(end_date)
      end_date -= 1.day
    end
    business_days
  end

  def self.holiday?(date)
    holidays = Holiday.all
    return true if date.saturday? || date.sunday?
    holidays.each do |holiday|
      return true if holiday.date == date
    end
    false
  end

  private

  def verify_dates
    return unless start_date && end_date &&
                  start_date > end_date
    errors.add(:start_date, 'must be before end date')
  end

  def set_number_of_business_days
    self.number_of_days = OOOPeriod.business_days_between(
      start_date.to_date,
      end_date.to_date
    )
  end

  def update_user_attributes
    if leave?
      remaining_leaves = remaining_leaves_count
      if remaining_leaves.negative?
        errors.add(
          :generic,
          'you dont have enough remaining leaves to apply this leave'
        )
      end
      user.remaining_leaves = remaining_leaves
    else
      remaining_wfhs = remaining_wfhs_count
      if remaining_wfhs.negative?
        errors.add(
          :generic,
          'you dont have enough remaining wfhs to apply this wfh'
        )
      end
      user.remaining_wfhs = remaining_wfhs
    end
  end

  def google_client
    calendar_service = Google::Apis::CalendarV3::CalendarService.new
    calendar_service.authorization = user.oauth_token
    calendar_service
  end

  def update_google_calendar
    if changes.key?(:type) && type_was
      begin
        google_client.delete_event(type_change_calendar_id, google_event_id)
        insert_calendar
      rescue
      end
    else
      google_event_id.blank? ? insert_calendar : edit_calendar
    end
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
    end
  end

  def calendar_id
    leave? ? OOO_CALENDAR_ID : WFH_CALENDAR_ID
  end

  def update_user_remaining_attributes
    if leave?
      user.remaining_leaves += number_of_days
    else
      user.remaining_wfhs += number_of_days
    end
  end

  def leave?
    type == 'Leave'
  end

  def delete_event_google_calendar
    client = google_client
    begin
      client.delete_event(calendar_id, google_event_id)
    rescue
    end
  end

  def save_user
    user.save!
  end

  # checks whether current leave has any conflicts with previous leaves
  def check_date_conflicts
    return unless start_date && end_date
    user.o_o_o_periods.each do |ooo_period|
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

  def remaining_leaves_count
    if changes.key?(:number_of_days) || changes.key?(:type)
      calculate_remaining_leaves
    else
      user.remaining_leaves
    end
  end

  def remaining_wfhs_count
    if changes.key?(:number_of_days) || changes.key?(:type)
      calculate_remaining_wfhs
    else
      user.remaining_wfhs
    end
  end

  def calculate_remaining_wfhs
    number_of_days_was ? edit_no_of_wfh_days : new_no_of_wfh_days
  end

  def edit_no_of_wfh_days
    determine_number_of_wfh_days
    if changes.key?(:type)
      user.remaining_leaves += number_of_days_was
      user.remaining_wfhs - number_of_days
    else
      user.remaining_wfhs + number_of_days_was - number_of_days
    end
  end

  def new_no_of_wfh_days
    determine_number_of_wfh_days
    user.remaining_wfhs - number_of_days
  end

  def determine_number_of_wfh_days
    return unless start_date.to_datetime - 450.minutes < DateTime.current
    self.number_of_days += 2 - 1
  end

  def calculate_remaining_leaves
    number_of_days_was ? edit_no_of_days : new_no_of_days
  end

  def edit_no_of_days
    if changes.key?(:type)
      user.remaining_wfhs += number_of_days_was
      user.remaining_leaves - number_of_days
    else
      user.remaining_leaves + number_of_days_was - number_of_days
    end
  end

  def new_no_of_days
    user.remaining_leaves - number_of_days
  end
end
