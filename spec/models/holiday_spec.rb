require 'rails_helper'

RSpec.describe Holiday, type: :model do
  [
    'date', 'occasion'
  ].each do |message|
    it "should respond to :#{message}" do
      expect(Holiday.new).to respond_to(message.to_sym)
    end
  end

  describe :validations do
    before do
      @holiday = Holiday.new(date: '', occasion: '')
    end

    it "should have valid date" do
      expect(@holiday.valid?).to eq(false)
      expect(@holiday.errors[:date].present?).to eq(true)
    end   

    it "should have valid occasion" do
      expect(@holiday.valid?).to eq(false)
      expect(@holiday.errors).to include(:occasion)
    end 

    it "should check uniqueness of date" do
      Holiday.create(date:'2017-04-12', occasion:'RANDOM')
      holiday = Holiday.create(date:'2017-04-12', occasion: 'RANDOM_HOLIDAY')
      expect(holiday.errors.messages[:date]).to include("has already been taken")
      expect(holiday.errors.messages[:date].present?).to eq(true)
      expect(holiday.errors.messages[:date].include?("has already been taken")).to eq(true)
    end
  end
end
