class Leave < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :leave_start_from, :leave_end_at
  validate :dates

  private

  def dates
  	errors.add(:leave_start_from, "must be before end date") unless leave_start_from <= leave_end_at
  end
end
