# frozen_string_literal: true

class FinancialYear
  def initialize(financial_year, leaves_count: nil)
    @financial_year = financial_year
    @leaves_count = leaves_count
  end

  def self.get_financial_year(date)
    if date.month > 3
      "#{date.year}-#{date.year + 1}"
    else
      "#{date.year - 1}-#{date.year}"
    end
  end

  def start_date
    years = @financial_year.split('-')
    Date.new(years[0].to_i, 4, 1)
  end

  def end_date
    years = @financial_year.split('-')
    Date.new(years[1].to_i, 3, -1)
  end

  def configured_leaves_count
    @leaves_count.presence || OOOConfig.find_by('financial_year = ?', @financial_year).leaves_count
  end

  def did_user_join_in_between_the_given_fy(joining_date)
    start_date <= joining_date && joining_date <= end_date
  end

  def date_in_previous_fy?(date)
    date < start_date
  end

  def date_in_next_fy?(date)
    date > end_date
  end
end
