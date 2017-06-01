# frozen_string_literal: true

class User < ApplicationRecord
  has_many :leaves, dependent: :destroy
  validates :name, :email, presence: true
  validate :check_remaining_leaves

  after_commit :initialize_total_leaves_and_remaining_leaves

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
    total_leaves - remaining_leaves.to_i
  end

  private

  def initialize_total_leaves_and_remaining_leaves
    return unless previous_changes.keys.include?('joining_date')
    self.total_leaves =
      self.remaining_leaves =
        compute_number_of_leaves_for_a_new_user
    save!
  end

  def start_year_of_indian_financial_year
    current_year = current_date.year
    if current_date < Date.new(current_year, 3, 31)
      current_year - 1
    else
      current_year
    end
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
        ) * NO_OF_PTO / 365
      ).ceil
    else
      NO_OF_PTO
    end
  end

  def check_remaining_leaves
    return unless remaining_leaves && remaining_leaves.negative?
    errors.add(:generic, 'remaining leaves cant be negative')
  end
end
