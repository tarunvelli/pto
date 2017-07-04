# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OOOPeriod, type: :model do
  user_params = { name: 'test',
                  email: 'test@beautifulcode.in',
                  joining_date: '2017-02-16',
                  oauth_token: 'test',
                  token_expires_at: 123 }
  let(:user) { User.create(user_params) }
  wfh_params = { start_date: '20170413', end_date: '20170414', type: 'Wfh' }
  let(:wfh) { user.ooo_periods.create(wfh_params) }

  before do
    ooo_config_params = { financial_year: '2017-2018',
                          leaves_count: 16,
                          wfhs_count: 13,
                          wfh_headsup_hours: 7.5,
                          wfh_penalty_coefficient: 1 }

    @ooo_config = OOOConfig.create(ooo_config_params)
  end

  describe :days_count_between do
    it 'should return number of days for given wfh and end date' do
      expect(Wfh.days_count_between(wfh.start_date, wfh.end_date, '20170412'))
        .to eq(2)
    end

    it 'should return one day more if he does not apply wfh before 7hr 30 min\
    of start date' do
      expect(Wfh.days_count_between(wfh.start_date, wfh.end_date, '20170414'))
        .to eq(3)
    end
  end

  describe :check_user_wfhs_count do
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
end
