# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OooperiodsController, type: :controller do
  before :each do
    allow_any_instance_of(Admin::OooperiodsController)
      .to receive(:ensure_signed_in).and_return(true)

    @user = User.create(name: 'test',
                        email: 'test@beautifulcode.in',
                        joining_date: '2017-02-16',
                        oauth_token: 'test',
                        token_expires_at: 123)
    OOOConfig.create(financial_year: '2017-2018',
                     leaves_count: 16,
                     wfhs_count: 13,
                     wfh_headsup_hours: 7.5,
                     wfh_penalty_coefficient: 1)

    allow_any_instance_of(Admin::OooperiodsController)
      .to receive(:admin_user).and_return(true)

    @leave = @user.ooo_periods.create(
      start_date: '20170412',
      end_date: '20170413',
      type: 'Leave'
    )
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:leave_params) do
        { start_date: '20170414', end_date: '20170415', type: 'Leave' }
      end

      it 'creates a new leave' do
        params = { user_id: @user.id, ooo_period: leave_params }
        expect { post :create, params: params }
          .to change(Leave, :count).by(1)

        expect(assigns(:ooo_period).persisted?).to eq(true)
      end

      it 'redirects to the oooperiods#index page' do
        post :create, params: { user_id: @user.id, ooo_period: leave_params }
        expect(response).to redirect_to admin_user_url(@user)
      end
    end

    context 'with invalid attributes' do
      let(:leave_params) do
        { start_date: '20170414', end_date: '20170413', type: 'Leave' }
      end

      it 'does not create the new leave' do
        params = { user_id: @user.id, ooo_period: leave_params }
        expect { post :create, params: params }
          .to_not change(Leave, :count)
        expect(assigns(:ooo_period).persisted?).to eq(false)
      end

      it 're-renders the :new template with validation errors' do
        post :create, params: { user_id: @user.id, ooo_period: leave_params }
        expect(assigns(:ooo_period).errors.present?).to eq(true)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:leave_params) do
        { start_date: '20170413', end_date: '20170414', type: 'Leave' }
      end

      it 'updates a existing leave' do
        params = { user_id: @user.id, ooo_period: leave_params, id: @leave.id }
        expect { patch :update, params: params }
          .not_to change(Leave, :count)
        @leave.reload
        expect(assigns(:ooo_period).persisted?).to eq(true)
        expect(@leave.start_date).to eq('20170413'.to_date)
        expect(@leave.end_date).to eq('20170414'.to_date)
      end

      it 'redirects to the leaves#index page' do
        params = { user_id: @user.id, ooo_period: leave_params, id: @leave.id }
        patch :update, params: params
        expect(response).to redirect_to admin_user_url(@user)
      end

      it 'update leave to wfh' do
        wfh_params = { start_date: '20170413',
                       end_date: '20170414',
                       type: 'Wfh' }
        params = { user_id: @user.id, ooo_period: wfh_params, id: @leave.id }
        expect { patch :update, params: params }
          .to change(Leave, :count).by(-1)
        expect(assigns(:ooo_period).persisted?).to eq(true)
      end
    end

    context 'with invalid attributes' do
      let(:leave_params) do
        { start_date: '20170413', end_date: nil, type: 'Leave' }
      end

      it 'does not update the leave' do
        params = { user_id: @user.id, ooo_period: leave_params, id: @leave.id }
        expect { patch :update, params: params }
          .to_not change(Leave, :count)
        @leave.reload
        expect(assigns(:ooo_period).errors.present?).to eq(true)
        expect(@leave.start_date).to eq('20170412'.to_date)
      end

      it 're-renders the :edit template with validation errors' do
        params = { user_id: @user.id, ooo_period: leave_params, id: @leave.id }
        patch :update, params: params
        expect(assigns(:ooo_period).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'delete #destroy' do
    it 'deletes the existing leave for user' do
      expect { delete :destroy, params: { user_id: @user.id, id: @leave.id } }
        .to change(Leave, :count).by(-1)
      expect(response).to redirect_to admin_user_url(@user)
    end
  end
end
