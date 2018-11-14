# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  has_many :holidays
  validates :leaves_count, :wfhs_count, :wfh_headsup_hours, :wfh_penalty_coefficient, presence: :true
  validates :financial_year, uniqueness: true
  validate :check_format_of_financial_year

  has_paper_trail
  acts_as_paranoid

  def self.current_financial_year
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 1 : Date.current.year
    "#{start_year_of_fy}-#{start_year_of_fy + 1}"
  end

  def self.previous_financial_year
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 2 : Date.current.year - 1
    "#{start_year_of_fy}-#{start_year_of_fy + 1}"
  end

  def check_format_of_financial_year
    return unless financial_year && financial_year.split('-').size != 2
    errors.add(:financial_year, 'please enter valid financial year, financial year should be in format of yyyy-yyyy')
  end
end
