# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  belongs_to :user
  validates :user_id, :start_date, :end_date, presence: true

  validate :verify_dates
  validate :check_date_conflicts

  before_save :set_number_of_business_days
  before_save :google_calendar
  after_save :save_user
  before_destroy :update_remaining_leaves
  after_destroy :save_user

  def self.business_days_between start_date, end_date
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

  def google_calendar
    user.remaining_leaves = remaining_leaves_count
    update_google_calendar
  end

  def google_client
     calendar_service = Google::Apis::CalendarV3::CalendarService.new
     calendar_service.authorization = user.oauth_token
     calendar_service
  end

   def update_google_calendar
     google_event_id.blank? ? insert_calendar : edit_calendar
   end



   def insert_calendar
     client = google_client
     ooo_calendar_id = 'beautifulcode.in_u4r1aag3llp06abvmmt1nsie80@group.calendar.google.com'
     wfh_calendar_id = "beautifulcode.in_ftlgca8tnpaqenr3i9ihgla3bg@group.calendar.google.com"
     event = Google::Apis::CalendarV3::Event.new ( {
       summary: "#{user.name} Leave",
       description: 'will be on leave',
       start: {
         date_time: start_date.to_time.to_datetime,
         time_zone: 'Asia/Kolkata'
       },
       end: {
         date_time: (end_date + 1).to_time.to_datetime ,
         time_zone: 'Asia/Kolkata'
       }
     })
     response = client.insert_event(wfh_calendar_id, event)
     self.google_event_id = response.id
   end

   def edit_calendar
     client = google_client
     ooo_calendar_id = 'beautifulcode.in_u4r1aag3llp06abvmmt1nsie80@group.calendar.google.com'
     wfh_calendar_id = "beautifulcode.in_ftlgca8tnpaqenr3i9ihgla3bg@group.calendar.google.com"
     event = client.get_event(wfh_calendar_id, google_event_id)
     event.start.date_time = start_date.to_time.to_datetime
     event.end.date_time = (end_date + 1).to_time.to_datetime
     client.update_event(wfh_calendar_id, event.id, event)
   end

  def update_remaining_leaves
    user.remaining_leaves = user.remaining_leaves + number_of_days
    delete_event_google_calendar
  end

  def delete_event_google_calendar
     client = google_client
     ooo_calendar_id = 'beautifulcode.in_u4r1aag3llp06abvmmt1nsie80@group.calendar.google.com'
     wfh_calendar_id = "beautifulcode.in_ftlgca8tnpaqenr3i9ihgla3bg@group.calendar.google.com"
     begin
       client.delete_event(wfh_calendar_id, google_event_id)
     rescue =>e
     end
  end

  def save_user
    user.save!
  end

  # checks whether current leave has any conflicts with previous leaves
  def check_date_conflicts
    return unless start_date && end_date
    user.leaves.each do |leave|
      next if leave == self
      next unless start_date <= leave.end_date &&
                  leave.start_date <= end_date
      errors.add(:generic,
                 'Leave dates are overlapping with previous leave dates.
                  Please correct.')
      break
    end
  end

  def remaining_leaves_count
    if changes.key?(:number_of_days)
      calculate_remaining_leaves
    else
      user.remaining_leaves
    end
  end

  def calculate_remaining_leaves
    number_of_days_was ? edit_no_of_days : new_no_of_days
  end

  def edit_no_of_days
    user.remaining_leaves + number_of_days_was - number_of_days
  end

  def new_no_of_days
    user.remaining_leaves - number_of_days
  end
end
