# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(name: 'test', email: 'test@beautifulcode.in') }
  before:each do
    config_params = { financial_year: OOOConfig.financial_year,
                      leaves_count: 16,
                      wfhs_count: {
                        "quarter1": 13,
                        "quarter2": 13,
                        "quarter3": 13,
                        "quarter4": 13
                      } }
    @ooo_config = OOOConfig.create(config_params)
  end

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

  describe :no_of_wfhs_used do
    it 'should return number of wfh used by user' do
      user.update_attributes(total_wfhs: 16, remaining_wfhs: 11)
      expect(user.no_of_wfhs_used).to eq(5)
    end
  end

  describe :current_date do
    it 'should return todays date' do
      expect(user.send(:current_date)).to eq(Date.current)
    end
  end

  describe :start_year_of_indian_financial_year do
    it 'should return 2017 when the current date is July 1st, 2017' do
      allow(user).to receive(:current_date).and_return(Date.new(2017, 7, 1))
      expect(user.send(:start_year_of_indian_financial_year)).to eq(2017)
    end

    it 'should return 2016 when the current date is March 1st, 2017' do
      allow(user).to receive(:current_date).and_return(Date.new(2017, 3, 1))
      expect(user.send(:start_year_of_indian_financial_year)).to eq(2016)
    end
  end

  describe :compute_number_of_leaves_for_a_new_user do
    it 'should return the maximum number of leaves/year if the \
    user has already joined before this financial year' do
      allow(user).to receive(:start_year_of_indian_financial_year)
        .and_return(2017)
      user.update_attributes(joining_date: '2017-02-16')
      expect(user.send(:compute_number_of_leaves_for_a_new_user)).to eq(16)
    end

    it 'should return the half of the maximum leaves if \
    the user joined exactly mid financial year' do
      allow(user).to receive(:start_year_of_indian_financial_year)
        .and_return(2017)
      user.update_attributes(joining_date: '2017-10-01')
      expect(user.send(:compute_number_of_leaves_for_a_new_user)).to eq(8)
    end

    it 'should return the quarter of the maximum leaves if the user \
    joined in the last quarter of the financial year' do
      allow(user).to receive(:start_year_of_indian_financial_year)
        .and_return(2017)
      user.update_attributes(joining_date: '2018-01-01')
      expect(user.send(:compute_number_of_leaves_for_a_new_user)).to eq(4)
    end

    it 'should return ceiling of the fractional value if the user \
    joined in the second month of the first quarter' do
      allow(user).to receive(:start_year_of_indian_financial_year)
        .and_return(2017)
      user.update_attributes(joining_date: '2018-02-01')
      expect(user.send(:compute_number_of_leaves_for_a_new_user)).to eq(3)
    end
  end

  describe :compute_number_of_wfhs_for_a_new_user do
    it 'should return the maximum number of wfhs/quarter if the \
    user has already joined before this quarter' do
      allow(user).to receive(:did_user_join_in_current_quarter)
        .and_return(false)
      user.update_attributes(joining_date: '2017-02-16')
      expect(user.send(:compute_number_of_wfhs_for_a_new_user)).to eq(13)
    end

    it 'should return the half of the maximum wfhs if \
    the user joined exactly mid quarter' do
      allow(user).to receive(:did_user_join_in_current_quarter)
        .and_return(true)
      allow(user).to receive(:current_date).and_return(Date.new(2017, 5, 15))
      user.update_attributes(joining_date: '2017-05-15')
      expect(user.send(:compute_number_of_wfhs_for_a_new_user)).to eq(7)
    end
  end

  describe :initialize_leave_attributes_and_wfh_attributes do
    it 'should set leaves attributes and wfh attributes for \
    a newly created user' do
      allow(user).to receive(
        :compute_number_of_leaves_for_a_new_user
      ).and_return(16)
      user.update_attributes(joining_date: '2017-02-16')
      user.send(:initialize_leave_attributes_and_wfh_attributes)
      expect(user.total_leaves).to eq(16)
      expect(user.remaining_leaves).to eq(16)
      expect(user.total_wfhs).to eq(13)
      expect(user.remaining_wfhs).to eq(13)
    end

    it 'should not set user attributes if there is no change \
    in joining date' do
      user.send(:initialize_leave_attributes_and_wfh_attributes)
      user.reload
      expect(user.remaining_leaves).to eq(nil)
      expect(user.remaining_wfhs).to eq(nil)
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

  describe :check_remaining_leaves do
    it 'should add to errors if remaining leaves are updating as negative' do
      user.update_attributes(remaining_leaves: 12)
      user.update_attributes(remaining_leaves: -1)
      expect(user.errors[:generic])
        .to include('remaining leaves cant be negative')
    end

    it 'should not add to errors if remaining leaves are updating\
    as positive number' do
      user.update_attributes(remaining_leaves: 12)
      expect(user.errors[:generic])
        .not_to include('remaining leaves cant be negative')
    end
  end

  describe :check_remaining_wfhs do
    it 'should add to errors if remaining leaves are updating as negative' do
      user.update_attributes(remaining_wfhs: 12)
      user.update_attributes(remaining_wfhs: -1)
      expect(user.errors[:generic])
        .to include('remaining wfhs cant be negative')
    end

    it 'should not add to errors if remaining wfhs are updating\
    as positive' do
      user.update_attributes(remaining_wfhs: 12)
      expect(user.errors[:generic])
        .not_to include('remaining wfhs cant be negative')
    end
  end
end
