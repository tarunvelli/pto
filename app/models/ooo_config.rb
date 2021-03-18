# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  has_many :holidays

  before_validation :set_financial_year

  validates :leaves_count, :wfhs_count, :wfh_headsup_hours, :wfh_penalty_coefficient, :start_date, :end_date,
            :financial_year, presence: true
  validates :financial_year, uniqueness: true
  validate :check_format_of_financial_year

  has_paper_trail
  acts_as_paranoid

  def self.get_config_from_financial_year(financial_year: nil)
    if financial_year.present?
      OOOConfig.find_by(financial_year: financial_year)
    else
      OOOConfig.get_config_from_date(date: Date.current)
    end
  end

  def self.get_config_from_date(date: Date.current)
    OOOConfig.where('start_date <= ? and end_date >= ?', date, date).last
  end

  def self.get_financial_year_from_date(date)
    OOOConfig.get_config_from_date(date: date)&.financial_year
  end

  def did_user_join_in_between_the_given_fy(joining_date)
    start_date <= joining_date && joining_date <= end_date
  end

  def date_in_previous_fy?(date)
    date < start_date
  end

  def date_in_next_fy?(date)
    date > end_date
  end

  private

  def set_financial_year
    self.financial_year = "#{start_date&.strftime('%Y/%m')}-#{end_date&.strftime('%Y/%m')}"
  end

  def check_format_of_financial_year
    return unless financial_year && financial_year.split('-').size != 2

    errors.add(:financial_year, 'financial year should be in format of yyyy/mm-yyyy/mm')
  end
end
