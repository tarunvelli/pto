# frozen_string_literal: true

class User < ApplicationRecord
  has_many :o_o_o_periods
  has_many :ooo_periods_infos, dependent: :destroy, autosave: true
  has_many :leaves, dependent: :destroy
  has_many :wfhs, dependent: :destroy
  validates :name, :email, presence: true
  validate :check_remaining_leaves
  validate :check_remaining_wfhs

  after_commit :initialize_leave_attributes_and_wfh_attributes

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

  def no_of_leaves_used
    total_leaves - remaining_leaves
  end

  def no_of_wfhs_used
    total_wfhs - remaining_wfhs
  end

  private

  def initialize_leave_attributes_and_wfh_attributes
    return unless previous_changes.keys.include?('joining_date')
    # TODO: To figure out a better solution for solving LineLength
    total_leaves =
      remaining_leaves =
        compute_number_of_leaves_for_a_new_user
    total_wfhs = remaining_wfhs = form_wfhs_hash
    ooo_periods_infos.create(
      financial_year: OOOConfig.financial_year,
      remaining_leaves: remaining_leaves,
      total_leaves: total_leaves,
      total_wfhs: total_wfhs,
      remaining_wfhs: remaining_wfhs
    )
    save!
  end

  def form_wfhs_hash
    wfhs_count = compute_number_of_wfhs_for_a_new_user
    wfhs_hash = {}
    for i in 1..4
      if i < current_quarter
        wfhs_hash["q#{i}"] = 0
      elsif i == current_quarter
        wfhs_hash["q#{i}"] = wfhs_count
      else
        wfhs_hash["q#{i}"] = ooo_config.wfhs_count
      end
    end
    wfhs_hash
  end

  def current_quarter
    quarters = [4, 1, 2, 3]
    quarters[(Date.today.month - 1) / 3]
  end

  def start_year_of_indian_financial_year
    current_year = current_date.year
    check_date = current_date < Date.new(current_year, 3, 31)
    check_date ? current_year - 1 : current_year
  end

  def current_date
    Date.current
  end

  def compute_number_of_leaves_for_a_new_user
    did_user_join_in_between_this_fy =
      (Date.new(start_year_of_indian_financial_year, 4, 1) < joining_date) &&
      (joining_date < Date.new(start_year_of_indian_financial_year + 1, 3, 31))

    if did_user_join_in_between_this_fy
      (
        (
         Date.new(start_year_of_indian_financial_year + 1, 3, 31) - joining_date
        ) * ooo_config.leaves_count / 365
      ).ceil
    else
      ooo_config.leaves_count
    end
  end

  def compute_number_of_wfhs_for_a_new_user
    if did_user_join_in_current_quarter
      (
        (
         Date.new(current_date.year, quarter_month_numbers(Date.today)[2], 30) -
         joining_date
        ) * ooo_config.wfhs_count.to_i / 90
      ).ceil
    else
      ooo_config.wfhs_count.to_i
    end
  end

  def ooo_config
    OOOConfig.find_by('financial_year = ?', OOOConfig.financial_year)
  end

  def did_user_join_in_current_quarter
    (Date.today.year == joining_date.year) &&
      (quarter_month_numbers(Date.today) == quarter_month_numbers(joining_date))
  end

  def quarter_month_numbers(date)
    quarters = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
    quarters[(date.month - 1) / 3]
  end

  def check_remaining_leaves
    return unless remaining_leaves && remaining_leaves.negative?
    errors.add(:generic, 'remaining leaves cant be negative')
  end

  def check_remaining_wfhs
    return unless remaining_wfhs && remaining_wfhs.negative?
    errors.add(:generic, 'remaining wfhs cant be negative')
  end
end
