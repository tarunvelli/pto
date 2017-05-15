class User < ApplicationRecord
  has_many :leaves, dependent: :destroy
  validates_presence_of :name, :email

  after_commit :touch_no_of_leaves

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  private
  def touch_no_of_leaves
    if self.previous_changes.keys.include?('start_date')
      self.total_leaves = self.remaining_leaves = number_of_leaves
      self.save
    end
  end

  def number_of_leaves
    leaves_count = 0
    current_year = Date.current.year
    financial_year = Date.current < Date.new(current_year,3,31) ? current_year-1 : current_year
    if (Date.new(financial_year,4,1) < self.start_date.to_date && self.start_date.to_date < Date.new(financial_year+1,3,31))
    	leaves_count = ((Date.new(financial_year+1,3,31) -
                      self.start_date.to_date).to_i * Pto.first.no_of_pto / 365 ).ceil
    else
      leaves_count = Pto.first.no_of_pto
    end
    leaves_count
  end
end
