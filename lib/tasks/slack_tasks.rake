# frozen_string_literal: true

desc 'send slack notification'
task send_slack_notification: :environment do
  ooo_periods = OOOPeriod.where(start_date: Time.zone.today).order('type')
  ooo_periods.each do |ooo_period|
    Slacked.post " #{ooo_period.user.name} will be on #{ooo_period.type} from\
    #{ooo_period.start_date} to #{ooo_period.end_date} "
  end
end
