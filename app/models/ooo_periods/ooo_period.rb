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

  def business_days_count_between(start_date, end_date)
    (start_date..end_date).select { |d| (1..5).cover?(d.wday) }.size
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
      next if ooo_period.id == id
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
    leave? ? check_user_leaves_count : check_user_wfhs_count
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

  def add_error
    errors.add(
      :generic,
      "you dont have enough #{type}s to apply this #{type}"
    )
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
