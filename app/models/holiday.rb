# frozen_string_literal: true

class Holiday < ApplicationRecord
  validates :date, :occasion, presence: true
  validates :date, uniqueness: true
  after_initialize :set_default_values, if: :new_record?

  def set_default_values
    self.date = Time.zone.now.strftime('%Y-%m-%d') if date.blank?
  end
end
