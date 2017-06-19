# frozen_string_literal: true

namespace :config do
  desc 'rake task to reset leaves every year for user'
  task reset_leaves_every_year_and_set_ooo_configs: :environment do
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 1 : Date.current.year
    financial_year = "#{start_year_of_fy}-#{start_year_of_fy + 1}"
    wfh_count = Hash[
      'quarter1' => NO_OF_WFH,
      'quarter2' => NO_OF_WFH,
      'quarter3' => NO_OF_WFH,
      'quarter4' => NO_OF_WFH
    ]
    OOOConfig.create!(
      financial_year: financial_year,
      leaves_count: NO_OF_PTO,
      wfhs_count: wfh_count
    )
    users = User.all
    users.each do |user|
      user.total_leaves = user.remaining_leaves = NO_OF_PTO
      user.save!
    end
  end

  desc 'rake task to reset wfhs every quarter'
  task reset_wfhs_every_quarter: :environment do
    users = User.all
    users.each do |user|
      user.total_wfhs = user.remaining_wfhs = NO_OF_PTO
      user.save!
    end
  end
end
