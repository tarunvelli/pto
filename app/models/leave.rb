# frozen_string_literal: true

# Rename Leave to OOOPeriod
class Leave < ApplicationRecord
  belongs_to :user
  validates :user_id, :leave_start_from, :leave_end_at, presence: true

  validate :dates
  validate :check_date_conflicts

  before_save :days_count
  after_save :post_to_slack
  before_destroy :user_leaves
  after_destroy :save_user

  def self.business_days_between(date1, date2)
    business_days = 0
    date = date2
    while date >= date1
      business_days += 1 unless holiday(date)
      date -= 1.day
    end
    business_days
  end

  # TODO: Use this simplified logic.
  #def self.ravi_business_days_between start_date, end_date
    #days.filter{|d| d.is_sat? or d.is_sun? or OOOConfig.is_holiday?(d)}
  #end

  def self.holiday(date)
    holidays = Holiday.all
    return true if date.saturday? || date.sunday?
    holidays.each do |holiday|
      return true if holiday.date == date
    end
    false
  end

  private

  # TODO: Rename to verify_dates
  def dates
    return unless leave_start_from && leave_end_at &&
                  leave_start_from > leave_end_at
    errors.add(:leave_start_from, 'must be before end date')
  end

  # TODO: Rename to set_number_of_business_days
  def days_count
    self.number_of_days = Leave.business_days_between(
      leave_start_from.to_date,
      leave_end_at.to_date
    )
  end

  def post_to_slack
    user.remaining_leaves = remaining_leaves_count
    user.save!
  end

  # TODO: Rename to update_remaining_leaves
  def user_leaves
    user.remaining_leaves = current_remaining_leaves + number_of_days.to_i
  end

  def save_user
    user.save!
  end

  # TODO: Write a comment defining date conflict.
  def check_date_conflicts
    return unless leave_start_from && leave_end_at

    leaves = user.leaves
    leaves.each do |leave|
      leave_start_conflict = start_date <= leave.leave_end_at
      leave_end_conflict = leave.leave_start_from <= end_date
      if leave == self

      elsif leave_start_conflict && leave_end_conflict
        errors.add(:leave_start_from,
                   ':There are date conflicts .please check Leave History')
        break
      end
    end
  end

  def ravi_check_date_conflicts
    return unless leave_start_from && leave_end_at
    user.leaves.each do |leave|
      if leave.days & self.days
        # Add error if my past leave overlaps with the current leave
        errors.add(:generic,
                   'Leave dates are overlapping with previous leave dates. Please correct.')
      end
    end
  end

  # TODO: Ugly. Dont have this method. Rushil to review.
  def start_date
    if changes[:leave_start_from]
      changes[:leave_start_from][1]
    else
      self[:leave_start_from]
    end
  end

  # TODO: Ugly. Dont have this method. Rushil to review.
  def end_date
    changes[:leave_end_at] ? changes[:leave_end_at][1] : self[:leave_end_at]
  end

  def remaining_leaves_count
    if changes[:number_of_days]
      calculate_remaining_leaves
    else
      current_remaining_leaves
    end
  end

  def calculate_remaining_leaves
    old_days_count ? edit_no_of_days : new_no_of_days
  end

  def edit_no_of_days
    current_remaining_leaves + old_days_count - new_days_count
  end

  def new_no_of_days
    current_remaining_leaves - new_days_count
  end

  def old_days_count
    changes[:number_of_days][0]
  end

  def new_days_count
    changes[:number_of_days][1].to_i
  end

  def current_remaining_leaves
    user.remaining_leaves.to_i
  end
end
