# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  validates :leaves_count, :wfhs_count, presence: :true
  before_save :update_user_leave_attributes
  before_save :update_user_wfh_attributes

  def self.financial_year
    check_date = Date.current < Date.new(Date.current.year, 3, 31)
    start_year_of_fy = check_date ? Date.current.year - 1 : Date.current.year
    "#{start_year_of_fy}-#{start_year_of_fy + 1}"
  end

  private

  def update_user_leave_attributes
    return unless changes.keys.include?('leaves_count') &&
                  financial_year == OOOConfig.financial_year
    User.all.each do |user|
      user.total_leaves = leaves_count
      if leaves_count_was.present?
        user.remaining_leaves += leaves_count - leaves_count_was.to_i
      else
        user.remaining_leaves = leaves_count
      end
      user.save(validate: false)
    end
  end

  def update_user_wfh_attributes
    return unless changes.keys.include?('wfhs_count') &&
                  financial_year == OOOConfig.financial_year
    User.all.each do |user|
      user.total_wfhs = wfhs_count.to_i
      if wfhs_count_was.present?
        user.remaining_wfhs +=
          wfhs_count.to_i - wfhs_count_was.to_i
      else
        user.remaining_wfhs = wfhs_count.to_i
      end
      user.save(validate: false)
    end
  end
end
