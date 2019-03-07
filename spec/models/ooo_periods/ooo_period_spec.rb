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
                          wfhs_count: 13,
                          wfh_headsup_hours: 7.5,
                          wfh_penalty_coefficient: 1 }
    @ooo_config = OOOConfig.create(ooo_config_params)
  end

  describe :validations do
    %w[
      start_date end_date type user_id
    ].each do |message|
      it 'should respond to :#{message}' do
        expect(OOOPeriod.new).to respond_to(message.to_sym)
      end
    end
  end

  describe :business_days_count_between do
    it 'should return 2 for a input of Fri to Mon' do
      expect(OOOPeriod.business_days_count_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 29)
             )).to eq(2)
    end

    it 'should return 4 for a input of Mon to Thurs' do
      expect(OOOPeriod.business_days_count_between(
               Date.new(2017, 5, 22),
               Date.new(2017, 5, 25)
             )).to eq(4)
    end

    it 'should return 1 if the start and end dates are the same' do
      expect(OOOPeriod.business_days_count_between(
               Date.new(2017, 5, 26),
               Date.new(2017, 5, 26)
             )).to eq(1)
    end
  end

  describe :verify_dates do
    it 'should not add to errors if start date is before end date' do
      leave.update(
        start_date: '20170412',
        end_date: '20170413'
      )
      expect(leave.errors).not_to include(:generic)
    end

    it 'should add to errors if start date is before end date' do
      leave.update(start_date: '20170414')
      expect(leave.errors).to include(:start_date)
      expect(leave.errors[:start_date])
        .to include('must be before end date')
    end

    it 'should not add to errors if end_date is empty' do
      leave.update(end_date: nil)
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
      allow(leave).to receive(:check_user_leaves_count).and_return(true)
      expect(leave.send(:check_user_attributes)).to eq(true)
    end

    it 'should check user wfhs if type is wfh' do
      allow(wfh).to receive(:check_user_wfhs_count).and_return(false)
      expect(wfh.send(:check_user_attributes)).to eq(false)
    end
  end
end
