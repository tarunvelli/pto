require 'rails_helper'

RSpec.describe Leave, type: :model do


  let(:leave) { Leave.create(leave_start_from:'2017-04-12', leave_end_at:'2017-04-13', user_id:1) }

  
  describe "validations" do
    it "should belong to user" do
      expect(leave.user).to include(1)
    end   

    it "should have valid user_id" do
      leave.update_attributes(user_id: nil)
      expect(leave.errors).to include(:user_id)
    end 


    it "start date should be before end date" do
      leave.update_attributes(leave_start_from: '2017-04-14')
      expect(leave.errors).to include(:leave_start_from)
    end
  end
end
