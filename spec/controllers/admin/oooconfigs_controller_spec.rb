# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OooconfigsController, type: :controller do
  before :each do
    @config_params = { financial_year: OOOConfig.financial_year,
                       leaves_count: 20,
                       wfhs_count: { "quarter1": 15,
                                     "quarter2": 15,
                                     "quarter3": 15,
                                     "quarter4": 15 } }
    @ooo_config = OOOConfig.create(@config_params)
    allow_any_instance_of(Admin::OooconfigsController).to receive(
      :admin_user
    ).and_return(true)
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates a existing OOO Config' do
        expect { patch :update, params: { ooo_config: @config_params } }
          .not_to change(OOOConfig, :count)
        expect(assigns(:ooo_config).persisted?).to eq(true)
        expect(response).to redirect_to admin_users_path
      end
    end

    context 'with invalid attributes' do
      it 'does not update the existing pto count' do
        expect { patch :update, params: { ooo_config: { leaves_count: nil } } }
          .not_to change(OOOConfig, :count)
        expect(assigns(:ooo_config).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end
end
