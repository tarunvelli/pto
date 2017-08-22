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
end
