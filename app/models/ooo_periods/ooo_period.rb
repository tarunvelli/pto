# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  belongs_to :user
  validates :user_id, :start_date, :end_date, :type, presence: true

  validate :verify_dates
  validate :check_date_conflicts

  validate :set_and_check_user_attributes
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

  def set_and_check_user_attributes
    set_number_of_business_days
    leave? ? set_user_leave_attributes : set_user_wfh_attributes
  end

  def set_user_leave_attributes
    number_of_days_was ? edit_leave : new_leave
  end

  def new_leave
    if get_financial_year(start_date) == get_financial_year(end_date)
      financial_year = get_financial_year(start_date)
      user_info = user_ooo_period_info(financial_year)
      user_info.remaining_leaves -= number_of_days
      if user_info.remaining_leaves.negative?
        errors.add(
          :generic,
          'you dont have enough remaining leaves to apply this leave'
        )
      end
      user_info.save!
    else
      start_date_financial_year = get_financial_year(start_date)
      start_date_user_info = user_ooo_period_info(start_date_financial_year)
      start_date_user_info.remaining_leaves -= OOOPeriod.business_days_between(
        start_date.to_date,
        Date.new(start_date.year, 3, -1)
      )
      start_date_user_info.save!
      end_date_financial_year = get_financial_year(end_date)
      end_date_user_info = user_ooo_period_info(end_date_financial_year)
      end_date_user_info.remaining_leaves -= OOOPeriod.business_days_between(
        Date.new(end_date.year, 4, 1),
        end_date.to_date
      )
      end_date_user_info.save!
      if start_date_user_info.remaining_leaves.negative? ||
         end_date_user_info.remaining_leaves.negative?
        errors.add(
          :generic,
          'you dont have enough remaining leaves to apply this leave'
        )
      end
    end
  end

  def edit_leave
    changes.key?(:type) ? increase_remaining_wfhs : increase_remaining_leaves
    new_leave
  end

  def increase_remaining_leaves
    if get_financial_year(start_date_was) == get_financial_year(end_date_was)
      financial_year = get_financial_year(start_date_was)
      user_info = user_ooo_period_info(financial_year)
      user_info.remaining_leaves += number_of_days_was
      user_info.save!
    else
      start_date_financial_year = get_financial_year(start_date_was)
      start_date_user_info = user_ooo_period_info(start_date_financial_year)
      start_date_user_info.remaining_leaves += OOOPeriod.business_days_between(
        start_date_was.to_date,
        Date.new(start_date_was.year, 3, -1)
      )
      end_date_financial_year = get_financial_year(end_date_was)
      end_date_user_info = user_ooo_period_info(end_date_financial_year)
      end_date_user_info.remaining_leaves += OOOPeriod.business_days_between(
        Date.new(end_date_was.year, 4, 1),
        end_date_was.to_date
      )
      start_date_user_info.save!
      end_date_user_info.save!
    end
  end

  def increase_remaining_wfhs
    if year_and_quarter(start_date_was) == year_and_quarter(end_date_was)
      financial_year = get_financial_year(start_date)
      user_info = user_ooo_period_info(financial_year)
      user_info.remaining_wfhs[get_quarter(start_date_was)] += number_of_days_was
      user_info.save!
    else
      start_date_quarter = get_quarter(start_date_was)
      start_date_financial_year = get_financial_year(start_date_was)
      start_date_user_info = user_ooo_period_info(start_date_financial_year)
      start_date_user_info.remaining_wfhs[start_date_quarter] += OOOPeriod.business_days_between(
        start_date_was.to_date,
        Date.new(start_date_was.year, end_month_of_quarter(start_date_was), -1)
      )
      start_date_user_info.save!
      end_date_quarter = get_quarter(end_date_was)
      end_date_financial_year = get_financial_year(end_date_was)
      end_date_user_info = user_ooo_period_info(end_date_financial_year)
      end_date_user_info.remaining_wfhs[end_date_quarter] += OOOPeriod.business_days_between(
        Date.new(end_date_was.year, start_month_of_quarter(end_date_was), 1),
        end_date_was.to_date
      )
      end_date_user_info.save!
    end
  end

  def user_ooo_period_info(financial_year)
    user.ooo_periods_infos.where('financial_year = ? ', financial_year).first
  end

  def set_user_wfh_attributes
    number_of_days_was ? edit_wfh : new_wfh
  end

  def edit_wfh
    changes.key?(:type) ? increase_remaining_leaves : increase_remaining_wfhs
    new_wfh
  end

  def new_wfh
    if year_and_quarter(start_date) == year_and_quarter(end_date)
      financial_year = get_financial_year(start_date)
      user_info = user_ooo_period_info(financial_year)
      user_info.remaining_wfhs[get_quarter(start_date)] -= number_of_days
      if user_info.remaining_wfhs[get_quarter(start_date)].negative?
        errors.add(
          :generic,
          'you dont have enough remaining wfhs to apply this wfh'
        )
      else
        user_info.save!
      end
    else
      start_date_quarter = get_quarter(start_date)
      start_date_financial_year = get_financial_year(start_date)
      start_date_user_info = user_ooo_period_info(start_date_financial_year)
      start_date_user_info.remaining_wfhs[start_date_quarter] -= OOOPeriod.business_days_between(
        start_date.to_date,
        Date.new(start_date.year, end_month_of_quarter(start_date), -1)
      )
      start_date_user_info.save!
      end_date_quarter = get_quarter(end_date)
      end_date_financial_year = get_financial_year(end_date)
      end_date_user_info = user_ooo_period_info(end_date_financial_year)
      end_date_user_info.remaining_wfhs[end_date_quarter] -= OOOPeriod.business_days_between(
        Date.new(end_date.year, start_month_of_quarter(end_date), 1),
        end_date.to_date
      )
      if start_date_user_info.remaining_wfhs[start_date_quarter].negative? ||
         end_date_user_info.remaining_wfhs[end_date_quarter].negative?
        errors.add(
          :generic,
          'you dont have enough remaining wfhs to apply this wfh'
        )
      else
        end_date_user_info.save!
      end
    end
  end

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

  def get_quarter(date)
    quarters = %w[q4 q1 q2 q3]
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
    leave? ? increase_remaining_leaves : increase_remaining_wfhs
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
end
