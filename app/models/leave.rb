# frozen_string_literal: true

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

  def self.holiday(date)
    holidays = Holiday.all
    holidays.each do |holiday|
      return true if holiday.date == date || date.saturday? || date.sunday?
    end
    false
  end

  private

  def dates
    return unless leave_start_from && leave_end_at &&
                  leave_start_from >= leave_end_at
    errors.add(:leave_start_from, 'must be before end date')
  end

  def days_count
    self.number_of_days = Leave.business_days_between(
      leave_start_from.to_date,
      leave_end_at.to_date
    )
  end

  def post_to_slack
    current_user = user
    current_user.remaining_leaves = remaining_leaves_count
    current_user.save!
    Slacked.post(
      " #{current_user.name} will be on leave from" \
      " #{leave_start_from} to #{leave_end_at} "
    )
  end

  def user_leaves
    user.remaining_leaves = current_remaining_leaves + number_of_days.to_i
  end

  def save_user
    user.save!
  end

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

  def start_date
    if changes[:leave_start_from]
      changes[:leave_start_from][1]
    else
      self[:leave_start_from]
    end
  end

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
