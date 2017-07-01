# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OOOPeriod, type: :model do
  user_params = { name: 'test',
                  email: 'test@beautifulcode.in',
                  joining_date: '2017-02-16',
                  oauth_token: 'test',
                  token_expires_at: 123 }
  let(:user) { User.create(user_params) }
  leave_params = { start_date: '20170412', end_date: '20170413', type: 'Leave' }
  let(:leave) { user.ooo_periods.create(leave_params) }
  wfh_params = { start_date: '20170414', end_date: '20170415', type: 'Wfh' }
  let(:wfh) { user.ooo_periods.create(wfh_params) }

  before do
    ooo_config_params = { financial_year: '2017-2018',
                          leaves_count: 16,
                          wfhs_count: 13 }
    @ooo_config = OOOConfig.create(ooo_config_params)
  end

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
      expect(leave.business_days_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 29)
      )).to eq(2)
    end

    it 'should return 4 for a input of Mon to Thurs' do
      expect(leave.business_days_between(
               Date.new(2017, 5, 22),
               Date.new(2017, 5, 25)
      )).to eq(4)
    end

    it 'should return 1 if the start and end dates are the same' do
      expect(leave.business_days_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 26)
      )).to eq(1)
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

  describe :check_user_attributes do
    it 'should check user leaves if type is leave' do
      allow(leave).to receive(:check_user_leaves).and_return(true)
      allow(leave).to receive(:check_user_wfhs).and_return(false)
      expect(leave.send(:check_user_attributes)).to eq(true)
    end

    it 'should check user wfhs if type is wfh' do
      allow(wfh).to receive(:check_user_leaves).and_return(true)
      allow(wfh).to receive(:check_user_wfhs).and_return(false)
      expect(wfh.send(:check_user_attributes)).to eq(false)
    end
  end

  describe :set_number_of_business_days do
    it 'should set number of days for that leave' do
      leave.send(:set_number_of_business_days)
      expect(leave.number_of_days).to eq(2)
    end

    it 'should return one day more if he does not apply wfh before 7hr 30 min\
     of start date' do
      wfh.update_attributes(start_date: '20170414',
                            end_date: '20170414',
                            updated_at: '20170414',
                            google_event_id: 'test')
      wfh.send(:set_number_of_business_days)
      expect(wfh.number_of_days).to eq(2)
    end
  end

  describe :check_user_leaves do
    context 'leave spans over two financial years' do
      before do
        @ooo_config.update_attributes!(leaves_count: 3)
        OOOConfig.create(financial_year: '2018-2019',
                         leaves_count: 10,
                         wfhs_count: 5)
      end
      it 'should add to error if number of days for current leave\
      are more than remaining leaves' do
        leave = user.leaves.create(start_date: '20180327', end_date: '20180407')
        expect(leave.errors[:generic]).to include(
          'you dont have enough Leaves to apply this Leave'
        )
      end

      it 'should not add to errors if number of days for current leave\
      are less than remaining leaves' do
        leave = user.leaves.create(start_date: '20180331', end_date: '20180402')
        expect(leave.errors[:generic]).not_to include(
          'you dont have enough Leaves to apply this Leave'
        )
      end
    end

    context 'leave is in one financial year' do
      it 'should add to error if number of days for current leave\
      are more than remaining leaves' do
        @ooo_config.update_attributes!(leaves_count: 3)
        leave = user.leaves.create(start_date: '20170404', end_date: '20170407')
        expect(leave.errors[:generic]).to include(
          'you dont have enough Leaves to apply this Leave'
        )
      end

      it 'should not add to errors if number of days for current leave\
      are less than remaining leaves' do
        expect(leave.errors[:generic]).not_to include(
          'you dont have enough Leaves to apply this Leave'
        )
      end
    end
  end

  describe :check_user_wfhs do
    before do
      @ooo_config.update_attributes!(wfhs_count: 3)
    end
    context 'wfh spans over two quarters' do
      it 'should add to error if number of days for current wfh\
      are more than remaining wfhs' do
        wfh = user.wfhs.create(start_date: '20170627', end_date: '20170707')
        expect(wfh.errors[:generic]).to include(
          'you dont have enough Wfhs to apply this Wfh'
        )
      end

      it 'should not add to errors if number of days for current leave\
      are less than remaining leaves' do
        wfh = user.wfhs.create(start_date: '20170630', end_date: '20170702')
        expect(wfh.errors[:generic]).not_to include(
          'you dont have enough Wfhs to apply this Wfh'
        )
      end
    end

    context 'Wfh is in one financial year' do
      it 'should add to error if number of days for current wfh\
      are more than remaining wfhs' do
        wfh = user.wfhs.create(start_date: '20170627', end_date: '20170630')
        expect(wfh.errors[:generic]).to include(
          'you dont have enough Wfhs to apply this Wfh'
        )
      end

      it 'should not add to errors if number of days for current wfh\
      are less than remaining Wfhs' do
        expect(wfh.errors[:generic]).not_to include(
          'you dont have enough Wfhs to apply this Wfh'
        )
      end
    end
  end

  describe :year_and_quarter do
    it 'should return 2017-2018q1 for 20170630' do
      expect(wfh.year_and_quarter('20170630'.to_date)).to eq('2017-2018q1')
    end

    it 'should return 2017-2018q2 for 20170930' do
      expect(wfh.year_and_quarter('20170930'.to_date)).to eq('2017-2018q2')
    end

    it 'should return 2017-2018q3 for 20171230' do
      expect(wfh.year_and_quarter('20171230'.to_date)).to eq('2017-2018q3')
    end

    it 'should return 2017-2018q4 for 20180330' do
      expect(wfh.year_and_quarter('20180330'.to_date)).to eq('2017-2018q4')
    end
  end

  describe :end_month_of_quarter do
    it 'should return 3 for 20170227' do
      expect(wfh.end_month_of_quarter('20170227'.to_date)).to eq(3)
    end

    it 'should return 6 for 20170527' do
      expect(wfh.end_month_of_quarter('20170527'.to_date)).to eq(6)
    end

    it 'should return 9 for 20170827' do
      expect(wfh.end_month_of_quarter('20170827'.to_date)).to eq(9)
    end

    it 'should return 12 for 20171127' do
      expect(wfh.end_month_of_quarter('20171127'.to_date)).to eq(12)
    end
  end

  describe :start_month_of_quarter do
    it 'should return 1 for 20170227' do
      expect(wfh.start_month_of_quarter('20170227'.to_date)).to eq(1)
    end

    it 'should return 4 for 20170527' do
      expect(wfh.start_month_of_quarter('20170527'.to_date)).to eq(4)
    end

    it 'should return 7 for 20170827' do
      expect(wfh.start_month_of_quarter('20170827'.to_date)).to eq(7)
    end

    it 'should return 10 for 20171127' do
      expect(wfh.start_month_of_quarter('20171127'.to_date)).to eq(10)
    end
  end

  describe :type_change do
    context 'if leave is changed to wfh' do
      it 'only if type is changed but not dates' do
        leave.update_attributes(type: 'Wfh')
      end

      it 'if both type and dates are changed' do
        leave.update_attributes(type: 'Wfh', start_date: '20170411')
      end
    end

    context 'if wfh is changed to leave' do
      it 'only if type is changed but not dates' do
        wfh.update_attributes(type: 'Leave')
      end

      it 'if both type and dates are changed' do
        wfh.update_attributes(type: 'Leave', end_date: '20170417')
      end
    end
  end
end
