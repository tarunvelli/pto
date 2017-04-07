require 'rails_helper'

RSpec.describe Holiday, type: :model do

  

  describe "validations" do

    let(:holiday) { Holiday.create(date:'2017-04-12', occasion:'inaugural') }

    it "should have valid date" do
      holiday.update_attributes(date: nil)
      expect(holiday.errors).to include(:date)
    end   

    it "should have valid occasion" do
      holiday.update_attributes(occasion: nil)
      expect(holiday.errors).to include(:occasion)
    end 

    it "should check uniqueness of date" do
      holiday2 = Holiday.create(date:'2017-04-12', occasion:'inaugural')
      expect(holiday2.errors.messages[:date]).to include("Date has already been taken")
    end
  end
end
