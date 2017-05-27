# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeavesController, type: :controller do
  before :each do
    allow_any_instance_of(LeavesController).to receive(:ensure_signed_in).and_return(true)
    user = User.create(name: 'test', email: 'test@test.com', remaining_leaves: 15)
    allow_any_instance_of(LeavesController).to receive(:current_user).and_return(user)
    @leave = user.leaves.create(leave_start_from: '20170412', leave_end_at: '20170413')
  end

  describe 'GET #index' do
    before :each do
      get :index
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @leaves' do
      expect(assigns(:leaves)).to eq([@leave])
    end

    it 'renders the #index view' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    before :each do
      get :new
    end

    it 'assigns a new Leave to @leave' do
      expect(assigns(:leave).new_record?).to eq(true)
    end

    it 'renders the :new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new leave' do
        expect {
          post :create, params: { leave: { leave_start_from: '20170412', leave_end_at: '20170413' } }
        }.to change(Leave, :count).by(1)

        expect(assigns(:leave).persisted?).to eq(true)
      end

      it 'redirects to the leaves#index page' do
        post :create, params: { leave: { leave_start_from: '20170412', leave_end_at: '20170413' } }
        expect(response).to redirect_to leaves_url
      end
    end

    context 'with invalid attributes' do
      it 'does not create the new leave' do
        expect {
          post :create, params: { leave: { leave_start_from: '20170412' } }
        }.to_not change(Leave, :count)
        expect(assigns(:leave).persisted?).to eq(false)
      end

      it 're-renders the :new template with validation errors' do
        post :create, params: { leave: { leave_start_from: '20170412' } }
        expect(assigns(:leave).errors.present?).to eq(true)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates a existing leave' do
        expect {
          patch :update, params: { leave: { leave_start_from: '20170413', leave_end_at: '20170414' }, id: @leave.id }
        }.not_to change(Leave, :count)
        @leave.reload
        expect(assigns(:leave).persisted?).to eq(true)
        expect(@leave.leave_start_from).to eq('20170413'.to_date)
        expect(@leave.leave_end_at).to eq('20170414'.to_date)
      end

      it 'redirects to the leaves#index page' do
        patch :update, params: { leave: { leave_start_from: '20170413', leave_end_at: '20170414' }, id: @leave.id }
        expect(response).to redirect_to leaves_url
      end
    end

    context 'with invalid attributes' do
      it 'does not update the leave' do
        expect {
          patch :update, params: { leave: { leave_start_from: '20170412', leave_end_at: nil }, id: @leave.id }
        }.to_not change(Leave, :count)
        @leave.reload
        expect(assigns(:leave).errors.present?).to eq(true)
        expect(@leave.leave_start_from).to eq('20170412'.to_date)
      end

      it 're-renders the :edit template with validation errors' do
        patch :update, params: { leave: { leave_start_from: '20170412', leave_end_at: nil }, id: @leave.id }
        expect(assigns(:leave).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'delete #destroy' do
    it 'deletes the existing leave for user' do
      expect {
        delete :destroy, params: { id: @leave.id }
      }.to change(Leave, :count).by(-1)
    end
  end
end
