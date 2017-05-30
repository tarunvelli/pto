# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST #create' do
    before :each do
      @user = User.create(
        name: 'test',
        email: 'test@test.com'
      )
      allow(User).to receive(
        :from_omniauth
      ).and_return(@user)
    end
    it 'should create new user session' do
      post :create
      expect(session[:user_id]).to eq(@user.id)
      expect(response).to redirect_to edit_user_url(@user.id)
    end

    it 'should redirect to leaves index for existing user' do
      @user.update_attributes(remaining_leaves: 15)
      post :create
      expect(session[:user_id]).to eq(@user.id)
      expect(response).to redirect_to leaves_url
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
