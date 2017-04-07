require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { User.create(name:'test', email:'test@beautifulcode.in') }

  describe "validations" do
    it "should have valid name" do
      user.update_attributes(name:nil)
      expect(user.errors).to include(:name)
    end   

    it "should have valid email" do
      user.update_attributes(email:nil)
      expect(user.errors).to include(:email)
    end 

    it "remaining_leaves shouldn't exceed 14 days" do
      user.update_attributes(remaining_leaves:15)
      expect(user.errors).to include(:remaining_leaves)
    end
  end

end
