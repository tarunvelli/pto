# frozen_string_literal: true

class Leave < OOOPeriod
  def check_user_leaves_count
    leave_id = start_date_was ? id : nil
    dates_in_same_fy? ? validate_user_leaves_count(leave_id) : validate_user_leaves_count_in_two_fy(leave_id)
  end

  def validate_user_leaves_count(leave_id)
    user_remaining_leaves_count = get_remaining_leaves_count(start_date, leave_id)
    return unless user_remaining_leaves_count < OOOPeriod.business_days_count_between(start_date, end_date)
    add_error
  end

  def validate_user_leaves_count_in_two_fy(leave_id)
    user_remaining_leaves_in_start_date_fy = get_remaining_leaves_count(start_date, leave_id)

    no_of_days_in_start_date_fy = OOOPeriod.business_days_count_between(start_date, Date.new(start_date.year, 3, -1))

    user_remaining_leaves_in_end_date_fy = get_remaining_leaves_count(end_date, leave_id)

    no_of_days_in_end_date_fy = OOOPeriod.business_days_count_between(Date.new(end_date.year, 4, 1), end_date)

    if user_remaining_leaves_in_start_date_fy < no_of_days_in_start_date_fy ||
       user_remaining_leaves_in_end_date_fy < no_of_days_in_end_date_fy
      add_error
    end
  end

  def get_remaining_leaves_count(date, leave_id)
    user.remaining_leaves_count(FinancialYear.get_financial_year(date), FinancialQuarter.get_quarter(date), leave_id)
  end

  def dates_in_same_fy?
    FinancialYear.get_financial_year(start_date) == FinancialYear.get_financial_year(end_date)
  end
end
