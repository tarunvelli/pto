class Leave < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :leave_start_from, :leave_end_at
  validate :dates

  after_save :post_to_slack


  private

  def dates
  	errors.add(:leave_start_from, "must be before end date") unless leave_start_from <= leave_end_at
  end

  def post_to_slack 
  	current_user = self.user
  	current_user.remaining_leaves = self.changes[:number_of_days][0] ? 
                        current_user.remaining_leaves.to_i - self.changes[:number_of_days][0] + self.changes[:number_of_days][1].to_i :
                        current_user.remaining_leaves.to_i - self.changes[:number_of_days][1].to_i
    current_user.save
    Slacked.post " #{current_user.name} will be on leave from" + 
                            " #{self.leave_start_from} to #{self.leave_end_at} "
      
  end 
end
