# frozen_string_literal: true

module OooPeriodCounts
  extend ActiveSupport::Concern

  def remaining_leaves_count(financial_year, quarter, exclude_leave_id)
    fy = FinancialYear.new(financial_year)
    leaves = self.leaves.where('(start_date >= ? & start_date <= ?) || (end_date >= ? & end_date <= ?)',
                               fy.start_date, fy.end_date,
                               fy.start_date, fy.end_date)
    leaves_used = 0
    leaves.each do |leave|
      next if leave.id == exclude_leave_id
      start_date = fy.date_in_previous_fy?(leave.start_date) ? fy.start_date : leave.start_date
      end_date = fy.date_in_next_fy?(leave.end_date) ? fy.end_date : leave.end_date
      leaves_used += OOOPeriod.business_days_count_between(start_date, end_date)
    end
    convert_till_quarter = quarter
    if financial_year == FinancialYear.get_financial_year(Date.current)
      convert_till_quarter = FinancialQuarter.current_quarter
    end
    total_leaves_count(financial_year) + converted_leaves_count(financial_year, convert_till_quarter).to_i - leaves_used
  end

  def leaves_used_count(financial_year, quarter)
    convert_till_quarter = quarter
    if financial_year == FinancialYear.get_financial_year(Date.current)
      convert_till_quarter = FinancialQuarter.current_quarter
    end
    total_leaves_count(financial_year) + converted_leaves_count(financial_year, convert_till_quarter).to_i -
      remaining_leaves_count(financial_year, quarter, nil)
  end

  def wfhs_used_count(financial_year, quarter)
    total_wfhs_count(financial_year, quarter) - remaining_wfhs_count(financial_year, quarter, nil)
  end

  def remaining_wfhs_count(financial_year, quarter, exclude_wfh_id)
    financial_quarter = FinancialQuarter.new(financial_year, quarter)
    wfhs = self.wfhs.where('(start_date >= ? AND start_date <= ?) || (end_date >= ? AND end_date <= ?)',
                           financial_quarter.start_date, financial_quarter.end_date,
                           financial_quarter.start_date, financial_quarter.end_date)
    wfhs_used = 0
    wfhs.each do |wfh|
      next if wfh.id == exclude_wfh_id
      start_date = financial_quarter.date_in_previous_fq(wfh.start_date) ? financial_quarter.start_date : wfh.start_date

      end_date = financial_quarter.date_in_next_fq?(wfh.end_date) ? financial_quarter.end_date : wfh.end_date

      updated_at = financial_quarter.date_in_previous_fq(wfh.start_date) ? start_date - 1.day : wfh.updated_at

      wfhs_used += Wfh.days_count_between(start_date, end_date, updated_at)
    end
    total_wfhs_count(financial_year, quarter) - wfhs_used
  end

  def total_leaves_count(financial_year)
    fy = FinancialYear.new(financial_year)
    case
    when fy.date_in_previous_fy?(joining_date)
      fy.configured_leaves_count
    when fy.did_user_join_in_between_the_given_fy(joining_date)
      ((fy.end_date - joining_date) * fy.configured_leaves_count / 365).ceil
    else
      0
    end
  end

  def total_wfhs_count(financial_year, quarter)
    financial_quarter = FinancialQuarter.new(financial_year, quarter)
    case
    when financial_quarter.date_in_previous_fq(joining_date)
      financial_quarter.configured_wfhs_count
    when financial_quarter.did_user_join_in_between_the_quarter(joining_date)
      ((financial_quarter.end_date - joining_date) * financial_quarter.configured_wfhs_count / 90).ceil
    else
      0
    end
  end

  def converted_leaves_count(financial_year, quarter)
    cumulative_remaining_wfhs_count(financial_year, quarter).to_f / 4
  end

  # returns number of cumulative wfhs remaining until, but not including, the specified quarter
  def cumulative_remaining_wfhs_count(financial_year, quarter)
    cumulative_wfhs = 0
    quarter -= 1
    while quarter.positive?
      cumulative_wfhs += remaining_wfhs_count(financial_year, quarter, nil)
      quarter -= 1
    end
    cumulative_wfhs
  end
end
