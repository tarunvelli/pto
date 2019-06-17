# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  before :each do
    allow_any_instance_of(Admin::UsersController)
      .to receive(:admin_user).and_return(true)
    @user = User.create(name: 'test',
                        email: 'test@beautifulcode.in',
                        joining_date: '2017-02-16',
                        oauth_token: 'test',
                        token_expires_at: 123)
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

  describe 'GET #show' do
    before :each do
      get :show, params: { id: @user.id }
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the #show view' do
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:user_params) do
        { active: false }
      end

      it 'updates a user' do
        params = { user: user_params, id: @user.id }
        expect { patch :update, params: params }
          .not_to change(User, :count)
        @user.reload
        expect(assigns(:user).persisted?).to eq(true)
        expect(@user.active).to eq(false)
      end

      it 'redirects to the admin#users#index page' do
        params = { user: user_params, id: @user.id }
        patch :update, params: params
        expect(response).to redirect_to admin_users_url
      end
    end

    context 'with invalid attributes' do
      before do
        allow_any_instance_of(User)
          .to receive(:update).and_return(false)
      end

      let(:user_params) do
        { active: false }
      end

      it 'redirects to the admin#users#index page' do
        params = { user: user_params, id: @user.id }
        patch :update, params: params
        expect(response).to render_template(:index)
      end
    end
  end
end
