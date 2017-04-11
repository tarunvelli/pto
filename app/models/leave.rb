class Leave < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :leave_start_from, :leave_end_at
  validate :dates
  validates :number_of_days, :numericality => { :greater_than => 0 }
  before_validation :check_date_conflicts
  after_save :post_to_slack


  private

  def dates
  	errors.add(:leave_start_from, "must be before end date") unless 
                              leave_start_from <= leave_end_at
  end

  def post_to_slack
    current_user = self.user
    current_user.remaining_leaves = remaining_leaves_count
    current_user.save
    #Slacked.post " #{current_user.name} will be on leave from" + 
                          #{}" #{self.leave_start_from} to #{self.leave_end_at} " 
  end 

  def check_date_conflicts
    leaves = self.user.leaves
    start_date = self.changes[:leave_start_from] ? self.changes[:leave_start_from][1] : 
                                                   self[:leave_start_from]
    end_date = self.changes[:leave_end_at] ? self.changes[:leave_end_at][1] : self[:leave_end_at]
    leaves.each do |leave|
      if(leave == self)

      elsif((leave.leave_start_from <= end_date) && (start_date <= leave.leave_end_at))
        errors.add(:leave_start_from, " :There are date conflicts .please check Leave History")
        break
      end
     end
  end


  def remaining_leaves_count
    current_user = self.user
    self.changes[:number_of_days] ? 
          current_user.remaining_leaves.to_i - self.changes[:number_of_days][0] + self.changes[:number_of_days][1].to_i :
          current_user.remaining_leaves.to_i - self.changes[:number_of_days][1].to_i
  end
end
