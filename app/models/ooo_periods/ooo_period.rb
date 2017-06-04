# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  belongs_to :user
  validates :user_id, :start_date, :end_date, presence: true

  validate :verify_dates
  validate :check_date_conflicts

  before_save :set_number_of_business_days
  after_save :post_to_slack
  before_destroy :update_remaining_leaves
  after_destroy :save_user

  def self.business_days_between start_date, end_date
    business_days = 0
    while end_date >= start_date
      business_days += 1 unless is_holiday?(end_date)
      end_date -= 1.day
    end
    business_days
  end

  def self.is_holiday?(date)
    holidays = Holiday.all
    return true if date.saturday? || date.sunday?
    holidays.each do |holiday|
      return true if holiday.date == date
    end
    false
  end

  private

  def verify_dates
    return unless start_date && end_date &&
                  start_date > end_date
    errors.add(:start_date, 'must be before end date')
  end

  def set_number_of_business_days
    self.number_of_days = OOOPeriod.business_days_between(
      start_date.to_date,
      end_date.to_date
    )
  end

  def post_to_slack
    user.remaining_leaves = remaining_leaves_count
    user.save!
  end

  def update_remaining_leaves
    user.remaining_leaves = user.remaining_leaves + number_of_days.to_i
  end

  def save_user
    user.save!
  end

  # checks whether current leave has any conflicts with previous leaves
  def check_date_conflicts
    return unless start_date && end_date
    user.leaves.each do |leave|
      next if leave == self
      next unless start_date <= leave.end_date &&
                  leave.start_date <= end_date
      errors.add(:generic,
                 'Leave dates are overlapping with previous leave dates.
                  Please correct.')
      break
    end
  end

  def remaining_leaves_count
    if changes.key?(:number_of_days)
      calculate_remaining_leaves
    else
      user.remaining_leaves
    end
  end

  def calculate_remaining_leaves
    number_of_days_was ? edit_no_of_days : new_no_of_days
  end

  def edit_no_of_days
    user.remaining_leaves + number_of_days_was - number_of_days
  end

  def new_no_of_days
    user.remaining_leaves - number_of_days
  end
end
