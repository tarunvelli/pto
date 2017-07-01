# frozen_string_literal: true

namespace :config do
  desc 'rake task to reset leaves every year for user'
  task set_ooo_configs_every_year: :environment do
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 1 : Date.current.year
    financial_year = "#{start_year_of_fy}-#{start_year_of_fy + 1}"
    OOOConfig.create!(
      financial_year: financial_year,
      leaves_count: NO_OF_PTO,
      wfhs_count: NO_OF_WFH
    )
  end
end
