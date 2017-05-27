# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before:each do
    allow_any_instance_of(UsersController).to receive(:ensure_signed_in).and_return(true)
    @user = User.create(name: 'test', email: 'test@test.com', remaining_leaves: 15, start_date: '20170216')
    allow_any_instance_of(UsersController).to receive(:current_user).and_return(@user)
  end

  describe 'PATCH #update' do
    it 'should update the user profile succesfully' do
      expect {
        patch :update, params: { user: { name: 'updated test', email: 'email@updated.com' }, id: @user.id }
      }.not_to change(User, :count)
      @user.reload
      expect(assigns(:user).persisted?).to eq(true)
      expect(@user.name).to eq('updated test')
      expect(@user.email).to eq('email@updated.com')
    end

    it 'should redirect to user page' do
      patch :update, params: { user: { name: 'updated test', email: 'email@updated.com' }, id: @user.id }
      expect(response).to redirect_to @user
    end

    it 'should redirect to edit page upon unsuccessful update' do
      patch :update, params: { user: { name: 'updated test', email: nil }, id: @user.id }
      expect(assigns(:user).errors.present?).to eq(true)
      expect(response).to render_template(:edit)
    end
  end
end
