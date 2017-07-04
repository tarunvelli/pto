# frozen_string_literal: true

class FinancialQuarter
  def start_date(financial_year, quarter)
    years = financial_year.split('-')
    year = quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers(quarter)[0], 1)
  end

  def end_date(financial_year, quarter)
    years = financial_year.split('-')
    year = quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers(quarter)[2], -1)
  end

  def quarter_month_numbers(quarter)
    month_numbers = [[4, 5, 6], [7, 8, 9], [10, 11, 12], [1, 2, 3]]
    month_numbers[quarter - 1]
  end

  def year_and_quarter(date)
    quarters = %w[q4 q1 q2 q3]
    FinancialYear.new.get_financial_year(date) + quarters[(date.month - 1) / 3]
  end

  def end_month_of_quarter(date)
    quarter_end_months = [3, 6, 9, 12]
    quarter_end_months[(date.month - 1) / 3]
  end

  def start_month_of_quarter(date)
    quarter_start_months = [1, 4, 7, 10]
    quarter_start_months[(date.month - 1) / 3]
  end

  def get_quarter(date)
    quarters = [4, 1, 2, 3]
    quarters[(date.month - 1) / 3]
  end

  def current_quarter
    quarters = [4, 1, 2, 3]
    quarters[(Date.today.month - 1) / 3]
  end

  def did_user_join_in_given_quarter(financial_year, quarter, joining_date)
    start_date(financial_year, quarter) <= joining_date &&
      joining_date <= end_date(financial_year, quarter)
  end
end
