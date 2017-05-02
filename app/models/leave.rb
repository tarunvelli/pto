class Leave < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :leave_start_from, :leave_end_at
  validate :dates
  before_validation :check_date_conflicts
  before_save :days_count
  after_save :post_to_slack
  before_destroy :user_leaves
  after_destroy :save_user

  def self.business_days_between(date1, date2)
    business_days = 0
    date = date2
    while date >= date1
      business_days = business_days + 1 unless date.saturday? or date.sunday? or holiday(date)
      date = date - 1.day
    end
    business_days
  end

  def self.holiday(date)
    holidays = Holiday.all
    holidays.each do |holiday|
      if holiday.date == date
        return true
      end
    end
    return false
  end




  private

  def dates
  	errors.add(:leave_start_from, "must be before end date") unless
                              leave_start_from <= leave_end_at
  end

  def days_count
    self.number_of_days = Leave.business_days_between(self.leave_start_from.to_date,
                                                      self.leave_end_at.to_date)
  end

  def post_to_slack
    current_user = self.user
    current_user.remaining_leaves = remaining_leaves_count
    current_user.save
    Slacked.post " #{current_user.name} will be on leave from" +
                          " #{self.leave_start_from} to #{self.leave_end_at} "
  end

  def user_leaves
    current_user = self.user
    current_user.remaining_leaves =  current_user.remaining_leaves.to_i + self.number_of_days.to_i
  end

  def save_user
    self.user.save
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
    if (self.changes[:number_of_days])
      self.changes[:number_of_days][0] ?
          current_user.remaining_leaves.to_i + self.changes[:number_of_days][0] - self.changes[:number_of_days][1].to_i :
          current_user.remaining_leaves.to_i - self.changes[:number_of_days][1].to_i
    else
      current_user.remaining_leaves.to_i
    end

  end

end
