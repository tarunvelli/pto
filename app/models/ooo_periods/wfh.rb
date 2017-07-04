# frozen_string_literal: true

class Wfh < OOOPeriod
  def days_count_between(start_date, end_date, time_to_compare)
    number_of_days = business_days_count_between(
      start_date,
      end_date
    )
    penalty = start_date.to_datetime - 450.minutes < time_to_compare
    penalty ? number_of_days + 1 : number_of_days
  end

  def check_user_wfhs_count
    wfh_id = start_date_was ? id : nil
    if dates_in_same_quarter?
      validate_user_wfhs_count(start_date, wfh_id)
    else
      remaining_wfhs_in_start_date_quarter =
        get_remaining_wfhs_count(start_date, wfh_id)
      no_of_days_in_start_quarter = days_count_between(
        start_date.to_date,
        Date.new(start_date.year,
                 FinancialQuarter.new.end_month_of_quarter(start_date),
                 -1),
        DateTime.current
      )
      remaining_wfhs_in_end_date_quarter =
        get_remaining_wfhs_count(end_date, wfh_id)
      no_of_days_in_end_date_quarter = days_count_between(
        Date.new(end_date.year,
                 FinancialQuarter.new.start_month_of_quarter(end_date),
                 1),
        end_date.to_date,
        DateTime.current
      )
      if remaining_wfhs_in_start_date_quarter < no_of_days_in_start_quarter ||
         remaining_wfhs_in_end_date_quarter < no_of_days_in_end_date_quarter
        add_error
      end
    end
  end

  def validate_user_wfhs_count(date, wfh_id)
    user_remaining_wfhs_count = get_remaining_wfhs_count(date, wfh_id)
    return unless user_remaining_wfhs_count < days_count_between(
      start_date,
      end_date,
      DateTime.current
    )
    add_error
  end

  def get_remaining_wfhs_count(date, wfh_id)
    user.remaining_wfhs_count(FinancialYear.new.get_financial_year(date),
                              FinancialQuarter.new.get_quarter(date),
                              wfh_id)
  end

  def dates_in_same_quarter?
    FinancialQuarter.new.year_and_quarter(start_date) ==
      FinancialQuarter.new.year_and_quarter(end_date)
  end
end
