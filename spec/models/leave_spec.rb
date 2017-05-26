# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Leave, type: :model do
  let(:user) { User.create(name: 'test', email: 'test@test.com', remaining_leaves: 15) }
  let(:leave) { user.leaves.create(leave_start_from: '20170412', leave_end_at: '20170413') }

  describe :validations do
    it 'should belong to user' do
      expect(leave.user.id).not_to eq(nil)
    end

    it 'should have valid user_id' do
      leave.update_attributes(user_id: nil)
      expect(leave.errors).to include(:user_id)
    end

    it 'should have valid leave_start_from' do
      leave.update_attributes(leave_start_from: nil)
      expect(leave.errors).to include(:leave_start_from)
    end

    it 'should have valid leave_end_at' do
      leave.update_attributes(leave_end_at: nil)
      expect(leave.errors).to include(:leave_end_at)
    end

    it 'start date should be before end date' do
      leave.update_attributes(leave_start_from: '20170414')
      expect(leave.errors).to include(:leave_start_from)
    end
  end

  describe :business_days_between do
    it 'should return business days between two dates' do
      expect(Leave.business_days_between(Date.new(2017, 5, 26),Date.new(2017, 5, 29))).to eq(2)
    end
  end

  describe :holiday do
    it 'should return false for normal date' do
      expect(Leave.holiday Date.new(2017, 5, 26)).to eq(false)
    end

    it 'should return true for holiday' do
      @holiday = Holiday.new(date: '2017-02-14', occasion: 'testing')
      @holiday.save!
      expect(Leave.holiday(Date.new(2017, 2, 14))).to eq(true)
    end
  end

  describe :dates do
    it 'start date should be before end date' do
      leave.update_attributes(leave_start_from: '20170412', leave_end_at: '20170413')
      expect(leave.errors).not_to include(:leave_start_from)
    end

    it 'start date should be before end date if not, add to errors' do
      leave.update_attributes(leave_start_from: '20170414')
      expect(leave.errors).to include(:leave_start_from)
    end
  end

  describe :days_count do
    it 'should set number of days for that leave' do
      leave.send(:days_count)
      expect(leave.number_of_days).to eq(2)
    end
  end

  describe :user_leaves do
    it 'should set remaining leaves to the user' do
      leave.number_of_days = 2
      leave.send(:user_leaves)
      expect(user.remaining_leaves).to eq(15)
    end
  end

  describe :save_user do
    it 'should save the user' do
      leave.send(:save_user)
      expected_user = User.where("name = 'test'")[0]
      expect(expected_user.email).to eq('test@test.com')
    end
  end

  describe :check_date_conflicts do
    it 'should add to errors if there is date conflit' do
      allow_any_instance_of(Leave).to receive(
        :post_to_slack
      ).and_return(true)
      user.leaves.create(leave_start_from: '20170412', leave_end_at: '20170413')
      conflict_leave = user.leaves.create(leave_start_from: '20170413', leave_end_at: '20170414')
      conflict_leave.send(:check_date_conflicts)
      expect(conflict_leave.errors[:leave_start_from]).to include(' :There are date conflicts .please check Leave History')
    end
  end
end
