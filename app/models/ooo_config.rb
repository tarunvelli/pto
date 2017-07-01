# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  validates :leaves_count, :wfhs_count, presence: :true
  validates :financial_year, uniqueness: true

  def self.financial_year
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 1 : Date.current.year
    "#{start_year_of_fy}-#{start_year_of_fy + 1}"
  end
end
