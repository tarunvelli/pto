# frozen_string_literal: true

namespace :config do
  desc 'rake task to reset leaves every year for user'
  task set_ooo_configs_every_year: :environment do
    year = Date.current.year + 1
    financial_year = "#{year}/01-#{year}/12"
    OOOConfig.create!(
      financial_year: financial_year,
      leaves_count: NO_OF_PTO,
      wfhs_count: NO_OF_WFH,
      wfh_penalty_coefficient: 0,
      wfh_headsup_hours: 0,
      start_date: Date.new(year, 1, 1),
      end_date: Date.new(year, 12, 31)
    )
  end
end
