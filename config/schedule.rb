# frozen_string_literal: true

every :weekday, at: '4pm' do
  rake 'send_slack_notification'
end
