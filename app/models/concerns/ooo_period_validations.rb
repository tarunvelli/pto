# frozen_string_literal: true

module OooPeriodValidations
  extend ActiveSupport::Concern

  included do
    validates :user_id, :start_date, :end_date, :type, presence: true
    validate :verify_dates
    validate :check_date_conflicts
    validate :check_user_attributes
  end

  private

  def verify_dates
    return unless start_date && end_date && start_date > end_date
    errors.add(:start_date, 'must be before end date')
  end

  # checks whether current leave has any conflicts with previous leaves
  def check_date_conflicts
    return unless start_date && end_date
    user.ooo_periods.each do |ooo_period|
      next if ooo_period.id == id
      next unless start_date <= ooo_period.end_date && ooo_period.start_date <= end_date
      errors.add(:generic, 'dates are overlapping with previous OOO Period dates. Please correct.')
      break
    end
  end

  def check_user_attributes
    return unless start_date && end_date
    leave? ? check_user_leaves_count : check_user_wfhs_count
  end
end
