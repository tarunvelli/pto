# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST #create' do
    before :each do
      @user = User.create(name: 'test',
                          email: 'test@beautifulcode.in',
                          joining_date: '2017-02-16',
                          oauth_token: 'test',
                          token_expires_at: 123)
      allow(User).to receive(
        :from_omniauth
      ).and_return(@user)
    end
    it 'should create new user session' do
      @user.update_attributes(joining_date: nil)
      post :create
      expect(session[:user_id]).to eq(@user.id)
      expect(response).to redirect_to edit_user_url(@user.id)
    end

    it 'should redirect to leaves index for existing user' do
      post :create
      expect(session[:user_id]).to eq(@user.id)
      expect(response).to redirect_to oooperiods_path
    end
  end

  describe 'DELETE #destroy' do
    it 'should destroy user session' do
      delete :destroy
      expect(session[:user_id]).to eq(nil)
      expect(response).to redirect_to root_path
    end
  end
end
