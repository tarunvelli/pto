# frozen_string_literal: true

class FinancialYear
  def get_financial_year(date)
    if date.month > 3
      "#{date.year}-#{date.year + 1}"
    else
      "#{date.year - 1}-#{date.year}"
    end
  end

  def start_date(financial_year)
    years = financial_year.split('-')
    Date.new(years[0].to_i, 4, 1)
  end

  def end_date(financial_year)
    years = financial_year.split('-')
    Date.new(years[1].to_i, 3, -1)
  end

  def get_configured_leaves_count(financial_year)
    OOOConfig.find_by('financial_year = ?', financial_year).leaves_count
  end

  def get_configured_wfhs_count(financial_year)
    OOOConfig.find_by('financial_year = ?', financial_year).wfhs_count
  end

  def did_user_join_in_between_the_given_fy(financial_year, joining_date)
    start_date(financial_year) < joining_date &&
      joining_date < end_date(financial_year)
  end
end
