# frozen_string_literal: true

class Wfh < OOOPeriod
  def self.days_count_between(start_date, end_date, time_to_compare)
    number_of_days = OOOPeriod.business_days_count_between(start_date, end_date)
    ooo_config = OOOConfig.find_by('financial_year = ?', FinancialYear.get_financial_year(start_date))
    penalty = start_date - (ooo_config.wfh_headsup_hours * 60).minutes < time_to_compare
    penalty ? number_of_days + ooo_config.wfh_penalty_coefficient : number_of_days
  end

  def check_user_wfhs_count
    wfh_id = start_date_was ? id : nil
    case compare_date_quarters
    when 'different_quarter'
      financial_year, quarter = FinancialQuarter.year_and_quarter(start_date)
      validate_user_wfhs_count(start_date, FinancialQuarter.new(financial_year, quarter).end_date, wfh_id)
      financial_year, quarter = FinancialQuarter.year_and_quarter(end_date)
      validate_user_wfhs_count(FinancialQuarter.new(financial_year, quarter).start_date, end_date, wfh_id)
    else
      validate_user_wfhs_count(start_date, end_date, wfh_id)
    end
  end

  def validate_user_wfhs_count(start_date, end_date, wfh_id)
    user_remaining_wfhs_count = get_remaining_wfhs_count(start_date, wfh_id)
    return unless user_remaining_wfhs_count < Wfh.days_count_between(start_date, end_date, DateTime.current)
    add_error
  end

  def get_remaining_wfhs_count(date, wfh_id)
    user.remaining_wfhs_count(FinancialYear.get_financial_year(date), FinancialQuarter.get_quarter(date), wfh_id)
  end

  def compare_date_quarters
    compare_quarters = FinancialQuarter.year_and_quarter(start_date) == FinancialQuarter.year_and_quarter(end_date)
    compare_quarters ? 'same_quarter' : 'different_quarter'
  end
end
