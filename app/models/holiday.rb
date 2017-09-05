# frozen_string_literal: true

class Holiday < ApplicationRecord
  belongs_to :ooo_config, class_name: 'OOOConfig'
  validates :date, :occasion, presence: true
  validates :date, uniqueness: true
  after_initialize :set_default_values, if: :new_record?

  has_paper_trail
  acts_as_paranoid

  def self.holiday?(date)
    Holiday.all.pluck('date').include?(date)
  end

  def set_default_values
    self.date = Time.zone.now.strftime('%Y-%m-%d') if date.blank?
  end
end
