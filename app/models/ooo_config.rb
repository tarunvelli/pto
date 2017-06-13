# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  before_save :update_user_leave_attributes
  before_save :update_user_wfh_attributes
  serialize :wfhs_count, Hash

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
      user.total_leaves += leaves_count - leaves_count_was
      user.remaining_leaves += leaves_count - leaves_count_was
      user.save(validate: false)
    end
  end

  def update_user_wfh_attributes
    return unless changes.keys.include?('wfhs_count') &&
                  financial_year == OOOConfig.financial_year
    return unless wfhs_count_was[current_quarter] != wfhs_count[current_quarter]
    User.all.each do |user|
      user.total_wfhs += wfhs_count[current_quarter].to_i -
        wfhs_count_was[current_quarter].to_i
      user.remaining_wfhs += wfhs_count[current_quarter].to_i -
        wfhs_count_was[current_quarter].to_i
      user.save(validate: false)
    end
  end

  def current_quarter
    quarters = ['quarter4', 'quarter1', 'quarter2', 'quarter3']
    quarters[(Date.today.month - 1) / 3]
  end
end
