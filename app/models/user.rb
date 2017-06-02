# frozen_string_literal: true

class User < ApplicationRecord
  has_many :leaves, dependent: :destroy
  validates :name, :email, presence: true

  after_commit :touch_no_of_leaves

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

  # TODO: Rename to initialize_total_leaves_and_remaining_leaves
  def touch_no_of_leaves
    return unless previous_changes.keys.include?('start_date')
    self.total_leaves = self.remaining_leaves = number_of_leaves
    save!
  end

  # TODO: Move financial year type to config (ex: Indian FY, US FY) and use that value 
  # 2017-2018
  # TODO: Rename to start_year_of_financial_year
  def financial_year
    current_year = current_date.year

    # TODO: Remove hardcoding of financial year.
    if current_date < Date.new(current_year, 3, 31)
      current_year - 1
    else
      current_year
    end
  end

  # TODO: Try to get rid of this method.
  def current_date
    Date.current
  end

  # TODO: Rename to compute_number_of_leaves_for_a_new_user
  def number_of_leaves
    past_year = Date.new(financial_year, 4, 1) < start_date
    future_year = start_date < Date.new(financial_year + 1, 3, 31)
    if past_year && future_year
      (
        (
          Date.new(financial_year + 1, 3, 31) - start_date
        ).to_i * NO_OF_PTO / 365
      ).ceil
    else
      NO_OF_PTO
    end
  end

  def number_of_leaves
    did_user_join_in_between_this_fy =
      (Date.new(financial_year, 4, 1) < start_date) &&
      (start_date < Date.new(financial_year + 1, 3, 31))

    if did_user_join_in_between_this_fy
      (
        (
          Date.new(financial_year + 1, 3, 31) - start_date
        ).to_i * NO_OF_PTO / 365
      ).ceil
    else
      NO_OF_PTO
    end
  end

end
