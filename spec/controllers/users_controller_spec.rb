# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before :each do
    allow_any_instance_of(UsersController)
      .to receive(:ensure_signed_in).and_return(true)
    @user = User.create(name: 'test',
                        email: 'test@beautifulcode.in',
                        joining_date: '2017-02-16',
                        oauth_token: 'test',
                        token_expires_at: 123)
    allow_any_instance_of(UsersController)
      .to receive(:current_user).and_return(@user)
  end

  describe 'PATCH #update' do
    it 'should update the user profile succesfully' do
      param = { user: { name: 'updated test',
                        email: 'email@beautifulcode.in' }, id: @user.id }
      expect { patch :update, params: param }
        .not_to change(User, :count)

      @user.reload
      expect(assigns(:user).persisted?).to eq(true)
      expect(@user.name).to eq('updated test')
    end

    it 'should redirect to user page' do
      param = { user: { name: 'updated test' }, id: @user.id }
      patch :update, params: param
      expect(response).to redirect_to @user
    end

    it 'should redirect to edit page upon unsuccessful update' do
      param = { user: { name: nil }, id: @user.id }
      patch :update, params: param
      expect(assigns(:user).errors.present?).to eq(true)
      expect(response).to render_template(:edit)
    end
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

  describe 'GET #download_users_details' do
    context 'when user is admin' do
      before :each do
        @user.admin = true
        get :download_users_details
      end
      it 'responds successfully with an HTTP 200 status code' do
        expect(response).to have_http_status(200)
        expect(response).to be_success
      end
    end

    context 'when user is not admin' do
      before :each do
        @user.admin = false
        get :download_users_details
      end
      it 'should redirect to user page' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to @user
      end
    end
  end
end
