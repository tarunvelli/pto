# frozen_string_literal: true

module OooPeriodCounts
  extend ActiveSupport::Concern

  def remaining_leaves_count(ooo_config, exclude_leave_id)
    fy = ooo_config
    total_leaves_count = total_leaves_count(ooo_config)
    leaves = get_in_range(self.leaves, fy.start_date, fy.end_date)
    leaves_used = 0
    leaves.each do |leave|
      next if leave.id == exclude_leave_id

      start_date = fy.date_in_previous_fy?(leave.start_date) ? fy.start_date : leave.start_date
      end_date = fy.date_in_next_fy?(leave.end_date) ? fy.end_date : leave.end_date
      leaves_used += OOOPeriod.business_days_count_between(start_date, end_date, holidays: ooo_config&.holidays)
    end

    total_leaves_count - leaves_used
  end

  def leaves_used_count(ooo_config)
    (total_leaves_count(ooo_config) - remaining_leaves_count(ooo_config, nil)).to_i
  end

  def wfhs_used_count(ooo_config, quarter)
    (total_wfhs_count(ooo_config, quarter) -
      remaining_wfhs_count(ooo_config, quarter, nil)).to_i
  end

  def remaining_wfhs_count(ooo_config, quarter, exclude_wfh_id)
    financial_quarter = FinancialQuarter.new(ooo_config, quarter)
    total_wfhs_count = total_wfhs_count(ooo_config, quarter)
    wfhs = get_in_range(self.wfhs, financial_quarter.start_date, financial_quarter.end_date)
    wfhs_used = 0
    wfhs.each do |wfh|
      next if wfh.id == exclude_wfh_id

      start_date = financial_quarter.date_in_previous_fq(wfh.start_date) ? financial_quarter.start_date : wfh.start_date

      end_date = financial_quarter.date_in_next_fq?(wfh.end_date) ? financial_quarter.end_date : wfh.end_date

      updated_at = financial_quarter.date_in_previous_fq(wfh.start_date) ? start_date - 1.day : wfh.updated_at

      wfhs_used += Wfh.days_count_between(
        start_date, end_date, updated_at, ooo_config: ooo_config, skip_penalty: wfh.skip_penalty
      )
    end

    total_wfhs_count - wfhs_used
  end

  def total_leaves_count(ooo_config)
    fy = ooo_config
    case
    when fy.date_in_previous_fy?(joining_date)
      fy.leaves_count
    when fy.did_user_join_in_between_the_given_fy(joining_date)
      ((fy.end_date - joining_date) * fy.leaves_count / 365).ceil
    else
      0
    end
  end

  def total_wfhs_count(ooo_config, quarter)
    financial_quarter = FinancialQuarter.new(ooo_config, quarter)
    case
    when financial_quarter.date_in_previous_fq(joining_date)
      financial_quarter.configured_wfhs_count
    when financial_quarter.did_user_join_in_between_the_quarter(joining_date)
      ((financial_quarter.end_date - joining_date) * financial_quarter.configured_wfhs_count / 90).ceil
    else
      0
    end
  end

  def get_in_range(ooo_periods, start_date, end_date)
    ooo_periods.select do |ooo_period|
      (ooo_period.start_date >= start_date && ooo_period.start_date <= end_date) ||
        (ooo_period.end_date >= start_date && ooo_period.end_date <= end_date)
    end
  end
end
