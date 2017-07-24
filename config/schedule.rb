# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

set :environment, Rails.env

every :weekday, at: '9am' do
  rake 'slack:send_slack_notification'
end

every :year, at: 'March 31st 11:59pm' do
  rake 'config:set_ooo_configs_every_year'
end
