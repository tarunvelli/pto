# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OOOConfig, type: :model do
  before:each do
    user_params = { name: 'test',
                    email: 'test@test.com',
                    total_leaves: 15,
                    remaining_leaves: 13,
                    total_wfhs: 13,
                    remaining_wfhs: 11 }
    @user = User.create(user_params)
    config_params = { financial_year: OOOConfig.financial_year,
                      leaves_count: 20,
                      wfhs_count: {
                        "quarter1": 15,
                        "quarter2": 15,
                        "quarter3": 15,
                        "quarter4": 15
                      } }
    @ooo_config = OOOConfig.create(config_params)
  end

  describe :should_update_user_attributes do
    context 'when you insert OOOConfig for new financial year' do
      it 'should update all user leaves and wfhs' do
        user = User.find(@user.id)
        expect(user.total_leaves).to eq(20)
        expect(user.remaining_leaves).to eq(20)
        expect(user.total_wfhs).to eq(15)
        expect(user.remaining_wfhs).to eq(15)
      end
    end

    context 'when you update OOOConfig for current financial year' do
      it 'should update all user leaves and wfhs' do
        @user.update_attributes(remaining_leaves: 10, remaining_wfhs: 10)
        config_params = { leaves_count: 22,
                          wfhs_count: { "quarter1": 18,
                                        "quarter2": 18,
                                        "quarter3": 18,
                                        "quarter4": 18 } }

        @ooo_config.update_attributes(config_params)

        user = User.find(@user.id)
        expect(user.total_leaves).to eq(22)
        expect(user.remaining_leaves).to eq(12)
        expect(user.total_wfhs).to eq(18)
        expect(user.remaining_wfhs).to eq(13)
      end
    end
  end
end
