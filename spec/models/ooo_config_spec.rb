# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OOOConfig, type: :model do
  user_params = { name: 'test',
                  email: 'test@test.com',
                  total_leaves: 15,
                  remaining_leaves: 13,
                  total_wfhs: 15,
                  remaining_wfhs: 13 }
  let(:user) { User.create(user_params) }
  config_params = { financial_year: OOOConfig.financial_year,
                    leaves_count: 20,
                    wfhs_count: {
                      "quarter1": 15,
                      "quarter2": 15,
                      "quarter3": 15,
                      "quarter4": 15
                    } }
  let(:ooo_config) { OOOConfig.create(config_params) }

  describe :should_update_user_attributes do
    it 'should update all user leaves and wfhs' do
      expect(user.total_leaves).to eq(16)
      expect(user.remaining_leaves).to eq(14)
      expect(user.total_wfhs).to eq(13)
      expect(user.remaining_wfhs).to eq(11)
    end
  end
end
