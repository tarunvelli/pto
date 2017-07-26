# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

set :environment, Rails.env

# Convert IST time to UTC
# use http://crontab.guru

# Run this task at IST 9 AM on every weekday
every :weekday, at: '3:30am' do
  rake 'slack:send_slack_notification'
end

every :year, at: 'March 31st 11:59pm' do
  rake 'config:set_ooo_configs_every_year'
end
