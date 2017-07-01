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
  end

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

  def calculate_number_of_days_in_wfh(wfh, end_date)
    number_of_days = wfh.business_days_between(wfh.start_date, end_date)
    if wfh.start_date.to_datetime - 450.minutes < wfh.updated_at
      number_of_days + 1
    else
      number_of_days
    end
  end

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

  def total_leaves(financial_year)
    return 0 if get_end_date(financial_year, 4) < joining_date
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
      ooo_config(financial_year).wfhs_count
    end
  end

  def ooo_config(financial_year)
    OOOConfig.find_by('financial_year = ?', financial_year)
  end

  def did_user_join_in_given_quarter(financial_year, quarter)
    get_start_date(financial_year, quarter) <= joining_date &&
      joining_date <= get_end_date(financial_year, quarter)
  end

  def quarter_month_numbers(quarter)
    month_numbers = [[4, 5, 6], [7, 8, 9], [10, 11, 12], [1, 2, 3]]
    month_numbers[quarter - 1]
  end
end
