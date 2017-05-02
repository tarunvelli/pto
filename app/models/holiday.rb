class Holiday < ApplicationRecord
  validates_presence_of :date, :occasion
  validates_uniqueness_of :date
  after_initialize :set_default_values, if: :new_record?

  def set_default_values
    self.date = Time.now.strftime('%Y-%m-%d') unless self.date.present?
  end

end
