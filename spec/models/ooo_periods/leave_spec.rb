# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Leave, type: :model do
  user_params = { name: 'test',
                  email: 'test@beautifulcode.in',
                  joining_date: '2017-02-16',
                  oauth_token: 'test',
                  token_expires_at: 123 }
  let(:user) { User.create(user_params) }
  leave_params = { start_date: '20170412', end_date: '20170413', type: 'Leave' }
  let(:leave) { user.ooo_periods.create(leave_params) }
  before do
    ooo_config_params = { financial_year: '2017-2018',
                          leaves_count: 16,
                          wfhs_count: 13,
                          wfh_headsup_hours: 7.5,
                          wfh_penalty_coefficient: 1 }
    @ooo_config = OOOConfig.create(ooo_config_params)
  end

  describe :check_user_leaves do
    context 'leave spans over two financial years' do
      before do
        @ooo_config.update_attributes!(leaves_count: 3)
        OOOConfig.create(financial_year: '2018-2019',
                         leaves_count: 10,
                         wfhs_count: 5,
                         wfh_headsup_hours: 7.5,
                         wfh_penalty_coefficient: 1)
      end
      it 'should add to error if number of days for current leave\
      are more than remaining leaves' do
        leave = user.leaves.create(start_date: '20180302', end_date: '20180407')
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
        @ooo_config.update_attributes!(wfhs_count: 0)
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
end
