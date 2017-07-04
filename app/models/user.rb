# frozen_string_literal: true

class User < ApplicationRecord
  include OooPeriodCounts

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
    email.split('@')[1] == 'beautifulcode.in' ? nil : errors.add(:email, 'must be a beautifulcode.in email')
  end
end
