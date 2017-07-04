# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OooconfigsController, type: :controller do
  before :each do
    @config_params = { financial_year: OOOConfig.current_financial_year,
                       leaves_count: 20,
                       wfhs_count: 15,
                       wfh_headsup_hours: 7.5,
                       wfh_penalty_coefficient: 1 }

    allow_any_instance_of(Admin::OooconfigsController).to receive(
      :admin_user
    ).and_return(true)
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new ooo configurations for new year' do
        expect { post :create, params: { ooo_config: @config_params } }
          .to change(OOOConfig, :count)
        expect(assigns(:ooo_config).persisted?).to eq(true)
        expect(response).to redirect_to admin_users_path
      end
    end

    context 'with invalid attributes' do
      it 'does not create the new leave' do
        expect { post :create, params: { ooo_config: { leaves_count: nil } } }
          .not_to change(OOOConfig, :count)
        expect(assigns(:ooo_config).errors.present?).to eq(true)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    before do
      @ooo_config = OOOConfig.create(@config_params)
    end
    context 'with valid attributes' do
      it 'updates a existing OOO Config' do
        expect { patch :update, params: { ooo_config: @config_params, id: @ooo_config.id } }
          .not_to change(OOOConfig, :count)
        expect(assigns(:ooo_config).persisted?).to eq(true)
        expect(response).to redirect_to admin_users_path
      end
    end

    context 'with invalid attributes' do
      it 'does not update the existing pto count' do
        expect { patch :update, params: { ooo_config: { leaves_count: nil }, id: @ooo_config.id } }
          .not_to change(OOOConfig, :count)
        expect(assigns(:ooo_config).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end
end
