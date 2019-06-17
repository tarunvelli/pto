# frozen_string_literal: true

class OOOPeriod < ApplicationRecord
  include GoogleCalendar
  include OooPeriodValidations

  belongs_to :user

  has_paper_trail
  acts_as_paranoid

  after_initialize :set_default_values, if: :new_record?

  def self.business_days_count_between(start_date, end_date, holidays: nil)
    if holidays.nil?
      (start_date..end_date).select { |d| (1..5).cover?(d.wday) && !Holiday.holiday?(d) }.size
    else
      (start_date..end_date).select { |d| (1..5).cover?(d.wday) && !holidays.pluck(:date).include?(d) }.size
    end
  end

  def set_default_values
    self.start_date = Time.zone.now.strftime('%Y-%m-%d') if start_date.blank?
    self.end_date = Time.zone.now.strftime('%Y-%m-%d') if end_date.blank?
  end

  def add_error
    errors[:base] << "You dont have enough #{type}s to apply for this #{type}"
  end

  def leave?
    type == 'Leave'
  end
end
