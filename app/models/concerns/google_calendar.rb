# frozen_string_literal: true

module GoogleCalendar
  extend ActiveSupport::Concern

  included do
    before_save :update_google_calendar
    before_destroy :delete_event_google_calendar
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
      rescue StandardError
        logger.info "the event(#{google_event_id}) you are trying to delete has already been deleted"
      end
    else
      google_event_id.blank? ? insert_calendar : edit_calendar
    end
  end

  def delete_event_google_calendar
    client = google_client
    begin
      client.delete_event(calendar_id, google_event_id)
    rescue StandardError
      logger.info "the event(#{google_event_id}) you are trying to delete has already been deleted"
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
    rescue StandardError
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
    rescue StandardError
      logger.info 'Authorisation failure,event cannot be fetched from google calendar'
    end
  end

  def calendar_id
    leave? ? OOO_CALENDAR_ID : WFH_CALENDAR_ID
  end
end
