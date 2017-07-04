# frozen_string_literal: true

class FinancialQuarter
  def initialize(financial_year, quarter)
    @financial_year = financial_year
    @quarter = quarter
  end

  def self.year_and_quarter(date)
    [FinancialYear.get_financial_year(date), FinancialQuarter.get_quarter(date)]
  end

  def self.end_month_of_quarter(date)
    quarter_end_months = [3, 6, 9, 12]
    quarter_end_months[(date.month - 1) / 3]
  end

  def self.start_month_of_quarter(date)
    quarter_start_months = [1, 4, 7, 10]
    quarter_start_months[(date.month - 1) / 3]
  end

  def self.get_quarter(date)
    quarters = [4, 1, 2, 3]
    quarters[(date.month - 1) / 3]
  end

  def self.current_quarter
    quarters = [4, 1, 2, 3]
    quarters[(Date.today.month - 1) / 3]
  end

  def start_date
    years = @financial_year.split('-')
    year = @quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers[0], 1)
  end

  def end_date
    years = @financial_year.split('-')
    year = @quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers[2], -1)
  end

  def quarter_month_numbers
    month_numbers = [[4, 5, 6], [7, 8, 9], [10, 11, 12], [1, 2, 3]]
    month_numbers[@quarter - 1]
  end

  def did_user_join_in_between_the_quarter(date)
    start_date <= date && date <= end_date
  end

  def date_in_previous_fq(date)
    date < start_date
  end

  def date_in_next_fq?(date)
    date > end_date
  end

  def configured_wfhs_count
    OOOConfig.find_by('financial_year = ?', @financial_year).wfhs_count
  end
end
