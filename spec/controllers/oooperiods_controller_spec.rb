# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OooperiodsController, type: :controller do
  before :each do |example|
    unless example.metadata[:skip_before]
      allow_any_instance_of(OooperiodsController)
        .to receive(:ensure_signed_in).and_return(true)
    end

    user = User.create(name: 'test',
                       email: 'test@beautifulcode.in',
                       joining_date: '2017-02-16',
                       oauth_token: 'test',
                       token_expires_at: 123)

    allow_any_instance_of(OooperiodsController)
      .to receive(:current_user).and_return(user)

    OOOConfig.create(financial_year: '2017-2018',
                     leaves_count: 16,
                     wfhs_count: 13,
                     wfh_headsup_hours: 7.5,
                     wfh_penalty_coefficient: 1)

    @leave = user.leaves.create(
      start_date: '20170412',
      end_date: '20170413'
    )
  end

  describe 'GET #index' do
    before :each do
      get :index
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the #index view' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    before :each do
      get :new
    end

    it 'assigns a new Leave to @ooo_period' do
      expect(assigns(:ooo_period).new_record?).to eq(true)
    end

    it 'renders the :new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:leave_params) do
        { start_date: '20170414', end_date: '20170415', type: 'Leave' }
      end

      it 'creates a new leave' do
        expect { post :create, params: { ooo_period: leave_params } }
          .to change(Leave, :count).by(1)

        expect(assigns(:ooo_period).persisted?).to eq(true)
      end

      it 'redirects to the oooperiods#index page' do
        post :create, params: { ooo_period: leave_params }
        expect(response).to redirect_to oooperiods_url
      end
    end

    context 'with invalid attributes' do
      let(:leave_params) do
        { start_date: '20170414', type: 'Leave' }
      end

      it 'does not create the new leave' do
        expect { post :create, params: { ooo_period: leave_params } }
          .to_not change(Leave, :count)
        expect(assigns(:ooo_period).persisted?).to eq(false)
      end

      it 're-renders the :new template with validation errors' do
        post :create, params: { ooo_period: leave_params }
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
        params = { ooo_period: leave_params, id: @leave.id }
        expect { patch :update, params: params }
          .not_to change(Leave, :count)
        @leave.reload
        expect(assigns(:ooo_period).persisted?).to eq(true)
        expect(@leave.start_date).to eq('20170413'.to_date)
        expect(@leave.end_date).to eq('20170414'.to_date)
      end

      it 'redirects to the leaves#index page' do
        patch :update, params: { ooo_period: leave_params, id: @leave.id }
        expect(response).to redirect_to oooperiods_url
      end

      it 'update leave to wfh' do
        wfh_params = { start_date: '20170413',
                       end_date: '20170414',
                       type: 'Wfh' }
        params = { ooo_period: wfh_params, id: @leave.id }
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
        params = { ooo_period: leave_params, id: @leave.id }
        expect { patch :update, params: params }
          .to_not change(Leave, :count)
        @leave.reload
        expect(assigns(:ooo_period).errors.present?).to eq(true)
        expect(@leave.start_date).to eq('20170412'.to_date)
      end

      it 're-renders the :edit template with validation errors' do
        patch :update, params: { ooo_period: leave_params, id: @leave.id }
        expect(assigns(:ooo_period).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'delete #destroy' do
    it 'deletes the existing leave for user' do
      expect { delete :destroy, params: { id: @leave.id } }
        .to change(Leave, :count).by(-1)
    end

    it 'should redirect to rootpath if not signed in', skip_before: true do
      allow_any_instance_of(OooperiodsController).to receive(
        :signed_in?
      ).and_return(false)
      delete :destroy, params: { id: @leave.id }
      expect(response).to redirect_to root_path
    end
  end
end
