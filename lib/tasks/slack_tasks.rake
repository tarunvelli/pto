# frozen_string_literal: true

namespace :slack do
  desc 'send slack notification'
  task send_slack_notification: :environment do
    exit 0 unless Time.now.on_weekday?

    leaves = Leave.where('start_date <= ? and end_date >= ?', Date.today, Date.today)
    leave_users = leaves.select{ |leave| leave.user.active }.collect{ |leave| leave.user.name }.join(', ')
    wfhs = Wfh.where('start_date <= ? and end_date >= ?', Date.today, Date.today)
    wfh_users = wfhs.select{ |wfh| wfh.user.active }.collect{ |wfh| wfh.user.name }.join(', ')
    Slacked.post " #{leave_users} will be on leave today" if !leaves.blank?
    Slacked.post " #{wfh_users} will be on WFH today" if !wfhs.blank?
  end
end
