desc 'send slack notification'
task send_slack_notification: :environment do
  leaves = Leave.where(leave_start_from: Date.today + 1 )
    leaves.each do |leave|
      Slacked.post " #{leave.user.name} will be on leave from" + 
                          " #{leave.leave_start_from} to #{leave.leave_end_at} "
    end 
end