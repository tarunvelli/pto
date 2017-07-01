# frozen_string_literal: true

class User < ApplicationRecord
  has_many :ooo_periods, class_name: 'OOOPeriod'
  has_many :leaves
  has_many :wfhs
  validates :name, :email, :oauth_token, :token_expires_at, presence: true
  validate :beautifulcode_mail

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize

    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.info.name
    user.email = auth.info.email
    user.oauth_token = auth.credentials.token
    user.token_expires_at = auth.credentials.expires_at
    user.save!
    user
  end

  def beautifulcode_mail
    return unless email
    return unless email.split('@')[1] != 'beautifulcode.in'
    errors.add(:email, 'must be a beautifulcode.in email')

    # TODO: email.split('@')[1] == 'beautifulcode.in' ? nil : errors.add(:email, 'must be a beautifulcode.in email')
  end

  # TODO: Rename to remaining_leaves_count
  def remaining_leaves(financial_year, exclude_leave_id)
    years = financial_year.split('-')
    start_date = Date.new(years[0].to_i, 4, 1)
    end_date = Date.new(years[1].to_i, 3, -1)
    leaves = Leave.where('user_id = ? & start_date >= ? & start_date <= ?',
                         id, start_date, end_date)
    leaves_used = 0
    leaves.each do |leave|
      next if leave.id == exclude_leave_id
      if leave.end_date > end_date
        leaves_used += leave.business_days_between(leave.start_date, end_date)
      else
        leaves_used += leave.number_of_days
      end
    end
    total_leaves(financial_year) - leaves_used
  end

  # TODO: Use nil for exclude_leave_id
  # Use count
  def leaves_used(financial_year)
    total_leaves(financial_year) - remaining_leaves(financial_year, 0)
  end

  def wfhs_used(financial_year, quarter)
    total_wfhs(financial_year, quarter) -
      remaining_wfhs(financial_year, quarter, 0)
  end

  def remaining_wfhs(financial_year, quarter, exclude_wfh_id)
    start_date = get_start_date(financial_year, quarter)
    end_date = get_end_date(financial_year, quarter)
    wfhs = Wfh.where('user_id = ? AND start_date >= ? AND start_date <= ?',
                     id, start_date, end_date)

    #TODO user.wfhs.where(...)

    wfhs_used = 0
    wfhs.each do |wfh|
      next if wfh.id == exclude_wfh_id
      if wfh.end_date > end_date
        wfhs_used += calculate_number_of_days_in_wfh(wfh, end_date)
      else
        wfhs_used += wfh.number_of_days
      end
    end
    total_wfhs(financial_year, quarter) - wfhs_used
  end

  # TODO: Rename to number_of_wfhs_to_deduct(wfh, quarter_end_date)
  # Move this to the WFH class
  def calculate_number_of_days_in_wfh(wfh, end_date)
    number_of_days = wfh.business_days_between(wfh.start_date, end_date)
    if wfh.start_date.to_datetime - 450.minutes < wfh.updated_at
      number_of_days + 1
    else
      number_of_days
    end
  end


=begin
  class WFH
    def number_of_wfhs_to_deduct
      # Call another method in WFH to check this.
      wfh_spanning_two_quaters = true/false

      end_date = nil
      if wfh_spanning_two_quaters
        end_date = FQ.end_date
      end

      wfh.business_days_between(end_date)

      +1 logic
    end
  end

class FinancialYear
  attr_accessor :start_date, :end_date

  def init(str)
    start_date =
    end_date =
  end

  def is_date_in_between?(date)

  
end

class FinacialQuarter

  def init(str)
  end

end
=end



  def get_start_date(financial_year, quarter)
    years = financial_year.split('-')
    year = quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers(quarter)[0], 1)
  end

  def get_end_date(financial_year, quarter)
    years = financial_year.split('-')
    year = quarter != 4 ? years[0] : years[1]
    Date.new(year.to_i, quarter_month_numbers(quarter)[2], -1)
  end

  def current_quarter
    quarters = [4, 1, 2, 3]
    quarters[(Date.today.month - 1) / 3]
  end

  # TODO: total_leave_count
  def total_leaves(financial_year)
    return 0 if get_end_date(financial_year, 4) < joining_date

    # return 0 if FinacialYear.new(financial_year).end_date < joining_date

    # did_user_join_in_between_the_given_fy =
    did_user_join_in_between_given_fy =
      (get_start_date(financial_year, 1) < joining_date) &&
      (joining_date < get_end_date(financial_year, 4))

    if did_user_join_in_between_given_fy
      (
        (
         get_end_date(financial_year, 4) - joining_date
        ) * ooo_config(financial_year).leaves_count / 365
      ).ceil
    else
      # TODO: FinacialYear.new(financial_year).get_configured_leaves_count
      ooo_config(financial_year).leaves_count
    end
  end

  def total_wfhs(financial_year, quarter)
    return 0 if get_end_date(financial_year, quarter) < joining_date
    if did_user_join_in_given_quarter(financial_year, quarter)
      (
        (
         get_end_date(financial_year, quarter) - joining_date
        ) * ooo_config(financial_year).wfhs_count / 90
      ).ceil
    else
      # TODO: FinacialYear.new(financial_year).get_configured_wfhs_count
      ooo_config(financial_year).wfhs_count
    end
  end

  # This method should go away.
  def ooo_config(financial_year)
    OOOConfig.find_by('financial_year = ?', financial_year)
  end

  # Move this method to a non-User class
  def did_user_join_in_given_quarter(financial_year, quarter)
    get_start_date(financial_year, quarter) <= joining_date &&
      joining_date <= get_end_date(financial_year, quarter)
  end

  # Move this method to a non-User class
  def quarter_month_numbers(quarter)
    month_numbers = [[4, 5, 6], [7, 8, 9], [10, 11, 12], [1, 2, 3]]
    month_numbers[quarter - 1]
  end
end
