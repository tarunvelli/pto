# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OOOPeriod, type: :model do
  user_params = { name: 'test',
                  email: 'test@test.com',
                  remaining_leaves: 15,
                  remaining_wfhs: 13 }
  let(:user) { User.create(user_params) }
  leave_params = { start_date: '20170412', end_date: '20170413', type: 'Leave' }
  let(:leave) { user.o_o_o_periods.create(leave_params) }
  wfh_params = { start_date: '20170414', end_date: '20170415', type: 'Wfh' }
  let(:wfh) { user.o_o_o_periods.create(wfh_params) }

  describe :validations do
    it 'should belong to user' do
      expect(leave.user.id).not_to eq(nil)
    end

    it 'should have valid start_date' do
      leave.update_attributes(start_date: nil)
      expect(leave.errors).to include(:start_date)
    end

    it 'should have valid end_date' do
      leave.update_attributes(end_date: nil)
      expect(leave.errors).to include(:end_date)
    end

    it 'start date should be before end date' do
      leave.update_attributes(start_date: '20170414')
      expect(leave.errors).to include(:start_date)
    end
  end

  describe :business_days_between do
    it 'should return 2 for a input of Fri to Mon' do
      expect(Leave.business_days_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 29)
      )).to eq(2)
    end

    it 'should return 4 for a input of Mon to Thurs' do
      expect(Leave.business_days_between(
               Date.new(2017, 5, 22),
               Date.new(2017, 5, 25)
      )).to eq(4)
    end

    it 'should return 1 if the start and end dates are the same' do
      expect(Leave.business_days_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 26)
      )).to eq(1)
    end
  end

  describe :holiday? do
    it 'should return false for weekday unless it is holiday' do
      expect(Leave.holiday?(Date.new(2017, 5, 26))).to eq(false)
    end

    it 'should return true for holiday' do
      @holiday = Holiday.create(date: '2017-02-14', occasion: 'testing')
      expect(Leave.holiday?(Date.new(2017, 2, 14))).to eq(true)
    end

    it 'should return true for saturday' do
      expect(Leave.holiday?(Date.new(2017, 6, 3))).to eq(true)
    end

    it 'should return true for sunday' do
      expect(Leave.holiday?(Date.new(2017, 6, 4))).to eq(true)
    end
  end

  describe :verify_dates do
    it 'should not add to errors if start date is before end date' do
      leave.update_attributes(
        start_date: '20170412',
        end_date: '20170413'
      )
      expect(leave.errors).not_to include(:generic)
    end

    it 'should add to errors if start date is before end date' do
      leave.update_attributes(start_date: '20170414')
      expect(leave.errors).to include(:start_date)
      expect(leave.errors[:start_date])
        .to include('must be before end date')
    end

    it 'should not add to errors if end_date is empty' do
      leave.update_attributes(end_date: nil)
      expect(leave.errors[:start_date])
        .not_to include('must be before end date')
    end
  end

  describe :set_number_of_business_days do
    it 'should set number of days for that leave' do
      leave.send(:set_number_of_business_days)
      expect(leave.number_of_days).to eq(2)
    end
  end

  describe :update_user_attributes do
    it 'should set remaining leaves if OOO period type is Leave' do
      leave.send(:update_user_attributes)
      expect(user.remaining_leaves).to eq(13)
    end

    it 'should add to errors if remaining leaves count becomes negative' do
      user.update_attributes(remaining_leaves: 2)
      leave.update_attributes(start_date: '20170409')
      leave.send(:update_user_attributes)
      expect(leave.errors[:generic])
        .to include('you dont have enough remaining leaves to apply this leave')
    end

    it 'should set remaining wfhs if OOO period type is wfh' do
      wfh.send(:update_user_attributes)
      expect(user.remaining_wfhs).to eq(11)
    end

    it 'should add to errors if remaining wfhs count becomes negative' do
      user.update_attributes(remaining_wfhs: 2)
      wfh.update_attributes(start_date: '20170409')
      wfh.send(:update_user_attributes)
      expect(wfh.errors[:generic])
        .to include('you dont have enough remaining wfhs to apply this wfh')
    end

    it 'should set remaining_wfhs on editing wfh' do
      wfh.update_attributes(start_date: '20170415', google_event_id: 'test')
      expect(user.remaining_wfhs).to eq(12)
    end
  end

  describe :save_user do
    it 'should save the user' do
      leave.send(:save_user)
      expected_user = User.where("name = 'test'")[0]
      expect(expected_user.email).to eq('test@test.com')
    end
  end

  describe :edit_no_of_days do
    it 'should return new number of days' do
      allow(leave).to receive(:number_of_days_was).and_return(2)

      allow(leave).to receive(:number_of_days).and_return(3)

      expect(leave.send(:edit_no_of_days)).to eq(12)
    end
  end

  describe :update_user_remaining_attributes do
    it 'should update user remaining leaves when a leave is deleted' do
      leave.destroy
      expect(user.remaining_leaves).to eq(15)
    end

    it 'should update user remaining wfhs when a wfh is deleted' do
      wfh.destroy
      expect(user.remaining_wfhs).to eq(13)
    end
  end

  describe :check_date_conflicts do
    it 'should add to errors if there is date conflit' do
      allow(leave).to receive(:update_google_calendar).and_return(true)
      conflict_leave = user.leaves.create(
        start_date: '20170413',
        end_date: '20170414'
      )
      conflict_leave.send(:check_date_conflicts)
      expect(conflict_leave.errors[:generic]).to include(
        'dates are overlapping with previous OOO Period dates. Please correct.'
      )
    end

    it 'should not add to errors if there is no date conflict' do
      allow(leave).to receive(:update_google_calendar).and_return(true)
      normal_leave = user.leaves.create(
        start_date: '20170414',
        end_date: '20170415'
      )
      normal_leave.send(:check_date_conflicts)
      expect(normal_leave.errors[:generic])
        .not_to include('dates are overlapping with previous OOO Period dates.
                         Please correct.')
    end
  end
end
