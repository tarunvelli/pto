# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  user_params = { name: 'test',
                  email: 'test@beautifulcode.in',
                  joining_date: '2017-02-16',
                  oauth_token: 'test',
                  token_expires_at: 123 }
  let(:user) { User.create(user_params) }
  before:each do
    config_params = { financial_year: '2017-2018',
                      leaves_count: 16,
                      wfhs_count: 13 }
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

    it 'should have valid oauth token' do
      user.update_attributes(oauth_token: nil)
      expect(user.errors).to include(:oauth_token)
    end

    it 'should have valid token expires at' do
      user.update_attributes(token_expires_at: nil)
      expect(user.errors).to include(:token_expires_at)
    end
  end

  describe :beautifulcode_mail do
    it 'add error if email does not belong to beautifulcode domain' do
      user.update_attributes(email: 'test@test.com')
      expect(user.errors).to include(:email)
      expect(user.errors[:email]).to include('must be a beautifulcode.in email')
    end

    it 'should not add error if email belongs to beautifulcode domain' do
      user.update_attributes(email: 'test@beautifulcode.in')
      expect(user.errors).not_to include(:email)
    end
  end

  describe :leaves_used do
    it 'should return number of leaves used by user for given financial year' do
      allow(user).to receive(:total_leaves).and_return(10)
      allow(user).to receive(:remaining_leaves).and_return(5)
      expect(user.leaves_used('2016-2017')).to eq(5)
    end
  end

  describe :wfhs_used do
    it 'should return number of wfh used by user in given quarter\
    of financial year' do
      allow(user).to receive(:total_wfhs).and_return(10)
      allow(user).to receive(:remaining_wfhs).and_return(5)
      expect(user.wfhs_used('2016-2017', 1)).to eq(5)
    end
  end

  describe :remaining_leaves do
    before do
      @leave = user.leaves.create(start_date: '2017-06-29',
                                  end_date: '2017-06-29')
    end

    context 'does not exclude any leave' do
      it 'should return remaining leaves for given financial year' do
        expect(user.remaining_leaves('2017-2018', 0)).to eq(15)
      end

      it 'should return remaining leaves for given financial year even \
      if leave spans over two financial years' do
        config_params = { financial_year: '2018-2019',
                          leaves_count: 16,
                          wfhs_count: 13 }
        OOOConfig.create(config_params)
        user.leaves.create(start_date: '2018-03-30', end_date: '2018-04-02')
        expect(user.remaining_leaves('2017-2018', 0)).to eq(14)
      end
    end

    context 'exclude one leave' do
      it 'should return remaining leaves for given financial year by\
      excluding given leave' do
        expect(user.remaining_leaves('2017-2018', @leave.id)).to eq(16)
      end
    end
  end

  describe :remaining_wfhs do
    before do
      @wfh = user.wfhs.create(start_date: '2017-06-29',
                              end_date: '2017-06-29')
    end

    context 'does not exclude any wfh' do
      it 'should return remaining wfhs for given financial year and \
      given quarter' do
        expect(user.remaining_wfhs('2017-2018', 1, 0)).to eq(11)
      end

      it 'should return remaining wfhs for given financial year\
      and given quarter even if wfh spans over two quarters' do
        user.wfhs.create(start_date: '2017-06-30', end_date: '2017-07-03')
        expect(user.remaining_wfhs('2017-2018', 1, 0)).to eq(9)
      end
    end

    context 'exclude one wfh' do
      it 'should return remaining wfhs for given financial year and\
      given quarter by excluding given wfh' do
        expect(user.remaining_wfhs('2017-2018', 1, @wfh.id)).to eq(13)
      end
    end
  end

  describe :calculate_number_of_days_in_wfh do
    it 'should return number of days for given wfh and end date' do
      wfh = user.wfhs.create(start_date: '2017-06-29',
                             end_date: '2017-06-29',
                             updated_at: '2017-06-27')
      allow(wfh).to receive(:business_days_between).and_return(1)
      expect(user.calculate_number_of_days_in_wfh(wfh, '2017-06-30')).to eq(1)
    end

    it 'should return one day more if he does not apply wfh before 7hr 30 min\
    of start date' do
      wfh = user.wfhs.create(start_date: '2017-06-29',
                             end_date: '2017-06-29',
                             updated_at: '2017-06-29')
      allow(wfh).to receive(:business_days_between).and_return(1)
      expect(user.calculate_number_of_days_in_wfh(wfh, '2017-06-30')).to eq(2)
    end
  end

  describe :should_return_start_date_of_given_fy_and_given_quarter do
    it 'should return 2017-04-01 if fy is 2017-2018 and quarter 1' do
      expect(user.get_start_date('2017-2018', 1).strftime('%Y-%m-%d'))
        .to eq('2017-04-01')
    end

    it 'should return 2017-07-01 if fy is 2017-2018 and quarter 2' do
      expect(user.get_start_date('2017-2018', 2).strftime('%Y-%m-%d'))
        .to eq('2017-07-01')
    end

    it 'should return 2017-10-01 if fy is 2017-2018 and quarter 3' do
      expect(user.get_start_date('2017-2018', 3).strftime('%Y-%m-%d'))
        .to eq('2017-10-01')
    end

    it 'should return 2018-01-01 if fy is 2017-2018 and quarter 4' do
      expect(user.get_start_date('2017-2018', 4).strftime('%Y-%m-%d'))
        .to eq('2018-01-01')
    end
  end

  describe :should_return_end_date_of_given_fy_and_given_quarter do
    it 'should return 2017-06-30 if fy is 2017-2018 and quarter 1' do
      expect(user.get_end_date('2017-2018', 1).strftime('%Y-%m-%d'))
        .to eq('2017-06-30')
    end

    it 'should return 2017-09-30 if fy is 2017-2018 and quarter 2' do
      expect(user.get_end_date('2017-2018', 2).strftime('%Y-%m-%d'))
        .to eq('2017-09-30')
    end

    it 'should return 2017-12-31 if fy is 2017-2018 and quarter 3' do
      expect(user.get_end_date('2017-2018', 3).strftime('%Y-%m-%d'))
        .to eq('2017-12-31')
    end

    it 'should return 2018-03-31 if fy is 2017-2018 and quarter 4' do
      expect(user.get_end_date('2017-2018', 4).strftime('%Y-%m-%d'))
        .to eq('2018-03-31')
    end
  end

  describe :total_leaves do
    it 'should return 0 if user joined after given financial year' do
      user.update_attributes(joining_date: '2018-10-01')
      expect(user.total_leaves('2017-2018')).to eq(0)
    end

    it 'should return the maximum number of leaves/year if the \
    user has already joined before given financial year' do
      expect(user.total_leaves('2017-2018')).to eq(16)
    end

    it 'should return the half of the maximum leaves if \
    the user joined exactly mid financial year' do
      user.update_attributes(joining_date: '2017-10-01')
      expect(user.total_leaves('2017-2018')).to eq(8)
    end

    it 'should return the quarter of the maximum leaves if the user \
    joined in the last quarter of the financial year' do
      user.update_attributes(joining_date: '2018-01-01')
      expect(user.total_leaves('2017-2018')).to eq(4)
    end

    it 'should return ceiling of the fractional value if the user \
    joined in the second month of the first quarter' do
      user.update_attributes(joining_date: '2018-02-01')
      expect(user.total_leaves('2017-2018')).to eq(3)
    end
  end

  describe :total_wfhs do
    it 'should return 0 if user joined after given fy and quarter' do
      user.update_attributes(joining_date: '2018-10-01')
      expect(user.total_wfhs('2017-2018', 1)).to eq(0)
    end

    it 'should return the maximum number of wfhs/quarter if the \
    user has already joined before given fy and quarter' do
      expect(user.total_wfhs('2017-2018', 1)).to eq(13)
    end

    it 'should return the half of the maximum wfhs if \
    the user joined exactly mid quarter' do
      user.update_attributes(joining_date: '2017-05-15')
      expect(user.total_wfhs('2017-2018', 1)).to eq(7)
    end
  end

  describe :quarter_month_numbers do
    it 'should return 4,5,6 for quarter 1' do
      expect(user.quarter_month_numbers(1)).to eq([4, 5, 6])
    end

    it 'should return 7,8,9 for quarter 2' do
      expect(user.quarter_month_numbers(2)).to eq([7, 8, 9])
    end

    it 'should return 10,11,12 for quarter 3' do
      expect(user.quarter_month_numbers(3)).to eq([10, 11, 12])
    end

    it 'should return 1,2,3 for quarter 4' do
      expect(user.quarter_month_numbers(4)).to eq([1, 2, 3])
    end
  end

  describe :from_omniauth do
    it 'should fetch all the user details succesfully' do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123',
        info: {
          name: 'test',
          email: 'test@beautifulcode.in'
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
      expect(user.email).to eq('test@beautifulcode.in')
      expect(user.oauth_token).to eq('test')
      expect(user.token_expires_at).to eq(123_456)
    end
  end
end
