#frozen_string_literal: true

namespace :wfh_conversion do
  desc 'rake task to convert unused work from homes to leave every quarter'
  task convert_wfh_to_leaves: :environment do
    previous_quarter = FinancialQuarter.previous_quarter
    current_financial_year = OOOConfig.current_financial_year
    wfh_from_financial_year = previous_quarter == 4 ? OOOConfig.previous_financial_year : OOOConfig.current_financial_year
    User.all.each do |user|
      user_wfh_conversions = user.wfh_conversions.find_or_create_by!(financial_year: current_financial_year)
      user_wfh_conversions.update_attributes(count: user_wfh_conversions.count +
        user.remaining_wfhs_count(wfh_from_financial_year, previous_quarter, nil).to_f / 4)
    end
  end
end