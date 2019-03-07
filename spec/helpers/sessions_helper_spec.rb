# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  before :each do
    @user = User.create(
      name: 'test',
      email: 'test@s.com',
      token_expires_at: Time.now.to_i + 500,
      admin: true
    )
    allow_any_instance_of(SessionsHelper).to receive(
      :current_user
    ).and_return(@user)
  end

  describe :signed_in do
    it 'should return true for valid user' do
      expect(signed_in?).to eq(true)
    end

    it 'should return false for invalid user' do
      @user.update(token_expires_at: Time.now.to_i + 200)
      expect(signed_in?).to eq(false)
    end
  end

  describe :admin_user do
    it 'should not redirect and return nill for admin user' do
      expect(admin_user).to eq(nil)
    end
  end
end
