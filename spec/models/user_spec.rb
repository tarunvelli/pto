# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(name: 'test', email: 'test@beautifulcode.in') }

  describe 'validations' do
    it 'should have valid name' do
      user.update_attributes(name: nil)
      expect(user.errors).to include(:name)
    end

    it 'should have valid email' do
      user.update_attributes(email: nil)
      expect(user.errors).to include(:email)
    end
  end

  describe :no_of_leaves_used do
    it 'should return number of leaves used by user' do
      user.update_attributes(total_leaves: 16, remaining_leaves: 11)
      expect(user.no_of_leaves_used).to eq(5)
    end
  end

  describe :financial_year do
    it 'should return current financial year' do
      allow(user).to receive(:current_date).and_return(Date.new(2017, 7, 1))
      user = User.new(total_leaves: 16, remaining_leaves: 11)
      expect(user.send(:financial_year)).to eq(2017)
    end

    it 'should return correct financial year' do
      allow(user).to receive(:current_date).and_return(Date.new(2017, 3, 1))
      expect(user.send(:financial_year)).to eq(2016)
    end
  end

  describe :number_of_leaves do
    it 'should return total number of leaves for user' do
      user.update_attributes(start_date: '2017-02-16')
      expect(user.send(:number_of_leaves)).to eq(16)
    end

    it 'should have less number of leaves if startdate is in current year' do
      user.update_attributes(start_date: Date.new(Time.zone.today.year, 6, 1))
      expect(user.send(:number_of_leaves)).to eq(13)
    end
  end

  describe :touch_no_of_leaves do
    it 'should return total number of leaves for user' do
      allow(user).to receive(:number_of_leaves).and_return(16)
      user.update_attributes(start_date: '2017-02-16')
      user.send(:touch_no_of_leaves)
      expect(user.total_leaves).to eq(16)
      expect(user.remaining_leaves).to eq(16)
    end
  end

  describe :from_omniauth do
    it 'should fetch all the user details succesfully' do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123',
        info: {
          name: 'test',
          email: 'test@test.com'
        },
        credentials: {
          token: 'test',
          expires_at: '123456'
        }
      )

      user = User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2])
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('123')
      expect(user.name).to eq('test')
      expect(user.email).to eq('test@test.com')
      expect(user.oauth_token).to eq('test')
      expect(user.token_expires_at).to eq(123_456)
    end
  end
end
