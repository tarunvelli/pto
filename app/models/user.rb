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

  def touch_no_of_leaves
    return unless previous_changes.keys.include?('start_date')

    self.total_leaves = self.remaining_leaves = number_of_leaves
    save!
  end

  def financial_year
    current_year = Date.current.year

    if Date.current < Date.new(current_year, 3, 31)
      current_year - 1
    else
      current_year
    end
  end

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
end
