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

  def remaining_leaves_count(financial_year, exclude_leave_id)
    start_date = FinancialYear.new.start_date(financial_year)
    end_date = FinancialYear.new.end_date(financial_year)
    leaves = self.leaves.where('(start_date >= ? & start_date <= ?) ||
                                (end_date >= ? & end_date <= ?)',
                               start_date, end_date, start_date, end_date)
    leaves_used = 0
    leaves.each do |leave|
      next if leave.id == exclude_leave_id
      if leave.dates_in_same_fy?
        leaves_used += leave.business_days_count_between(
          leave.start_date,
          leave.end_date
        )
      elsif leave.end_date > end_date
        leaves_used += leave.business_days_count_between(
          leave.start_date,
          end_date
        )
      else
        leaves_used += leave.business_days_count_between(
          start_date,
          leave.end_date
        )
      end
    end
    total_leaves_count(financial_year) - leaves_used
  end

  def leaves_used_count(financial_year)
    total_leaves_count(financial_year) -
      remaining_leaves_count(financial_year, nil)
  end

  def wfhs_used_count(financial_year, quarter)
    total_wfhs_count(financial_year, quarter) -
      remaining_wfhs_count(financial_year, quarter, nil)
  end

  def remaining_wfhs_count(financial_year, quarter, exclude_wfh_id)
    start_date = FinancialQuarter.new.start_date(financial_year, quarter)
    end_date = FinancialQuarter.new.end_date(financial_year, quarter)
    wfhs = self.wfhs.where('(start_date >= ? AND start_date <= ?) ||
                            (end_date >= ? AND end_date <= ?)',
                           start_date, end_date, start_date, end_date)

    wfhs_used = 0
    wfhs.each do |wfh|
      next if wfh.id == exclude_wfh_id
      if wfh.dates_in_same_quarter?
        wfhs_used += wfh.days_count_between(
          wfh.start_date,
          wfh.end_date,
          wfh.updated_at
        )
      elsif wfh.end_date > end_date
        wfhs_used += wfh.days_count_between(
          wfh.start_date,
          end_date,
          wfh.updated_at
        )
      else
        wfhs_used += wfh.days_count_between(
          start_date,
          wfh.end_date,
          start_date - 451.minutes
        )
      end
    end
    total_wfhs_count(financial_year, quarter) - wfhs_used
  end

  def total_leaves_count(financial_year)
    return 0 if FinancialYear.new.end_date(financial_year) < joining_date
    did_user_join_in_between_the_given_fy =
      FinancialYear.new.did_user_join_in_between_the_given_fy(
        financial_year,
        joining_date
      )
    if did_user_join_in_between_the_given_fy
      (
        (
          FinancialYear.new.end_date(financial_year) - joining_date
        ) * FinancialYear.new.get_configured_leaves_count(financial_year) / 365
      ).ceil
    else
      FinancialYear.new.get_configured_leaves_count(financial_year)
    end
  end

  def total_wfhs_count(financial_year, quarter)
    return 0 if joining_date > FinancialQuarter.new.end_date(
      financial_year, quarter
    )
    did_user_join_in_given_quarter =
      FinancialQuarter.new.did_user_join_in_given_quarter(
        financial_year,
        quarter,
        joining_date
      )
    if did_user_join_in_given_quarter
      (
        (
          FinancialQuarter.new.end_date(financial_year, quarter) -
          joining_date
        ) * FinancialYear.new.get_configured_wfhs_count(financial_year) / 90
      ).ceil
    else
      FinancialYear.new.get_configured_wfhs_count(financial_year)
    end
  end
end
