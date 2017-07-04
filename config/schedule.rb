# frozen_string_literal: true

every :weekday, at: '9am' do
  rake 'send_slack_notification'
end

every :year, at: 'March 31st 11:59pm' do
  rake 'config:set_ooo_configs_every_year'
end
