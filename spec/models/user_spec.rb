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

  describe :validations do
    %w[
      name email oauth_token token_expires_at
    ].each do |message|
      it 'should respond to :#{message}' do
        expect(User.new).to respond_to(message.to_sym)
      end
    end
  end

  describe :beautifulcode_mail do
    it 'should add an error if email does not belong to beautifulcode domain' do
      user.update_attributes(email: 'test@test.com')
      expect(user.errors).to include(:email)
      expect(user.errors[:email]).to include('must be a beautifulcode.in email')
    end

    it 'should not add error if email belongs to beautifulcode domain' do
      user.update_attributes(email: 'test@beautifulcode.in')
      expect(user.errors).not_to include(:email)
    end
  end

  describe :leaves_used_count do
    it 'should return number of leaves used by user for given financial year' do
      allow(user).to receive(:total_leaves_count).and_return(10)
      allow(user).to receive(:remaining_leaves_count).and_return(5)
      expect(user.leaves_used_count('2016-2017')).to eq(5)
    end
  end

  describe :wfhs_used_count do
    it 'should return number of wfh used by user in given quarter\
    of financial year' do
      allow(user).to receive(:total_wfhs_count).and_return(10)
      allow(user).to receive(:remaining_wfhs_count).and_return(5)
      expect(user.wfhs_used_count('2016-2017', 1)).to eq(5)
    end
  end

  describe :remaining_leaves_count do
    before do
      @leave = user.leaves.create(start_date: '2017-06-29',
                                  end_date: '2017-06-29')
    end

    context 'when it does not exclude any leave' do
      it 'should return remaining leaves for given financial year' do
        expect(user.remaining_leaves_count('2017-2018', 0)).to eq(15)
      end

      it 'should return remaining leaves for given financial year even \
      if leave spans over two financial years' do
        config_params = { financial_year: '2018-2019',
                          leaves_count: 16,
                          wfhs_count: 13 }
        OOOConfig.create(config_params)
        user.leaves.create(start_date: '2018-03-30', end_date: '2018-04-02')
        expect(user.remaining_leaves_count('2017-2018', 0)).to eq(14)
      end
    end

    context 'when it excludes one leave' do
      it 'should return remaining leaves for given financial year by\
      excluding given leave' do
        expect(user.remaining_leaves_count('2017-2018', @leave.id)).to eq(16)
      end
    end
  end

  describe :remaining_wfhs_count do
    before do
      @wfh = user.wfhs.create(start_date: '2017-06-29',
                              end_date: '2017-06-29')
    end

    context 'does not exclude any wfh' do
      it 'should return remaining wfhs for given financial year and \
      given quarter' do
        expect(user.remaining_wfhs_count('2017-2018', 1, 0)).to eq(11)
      end

      it 'should return remaining wfhs for given financial year\
      and given quarter even if wfh spans over two quarters' do
        user.wfhs.create(start_date: '2017-06-30', end_date: '2017-07-03')
        expect(user.remaining_wfhs_count('2017-2018', 1, 0)).to eq(9)
      end
    end

    context 'exclude one wfh' do
      it 'should return remaining wfhs for given financial year and\
      given quarter by excluding given wfh' do
        expect(user.remaining_wfhs_count('2017-2018', 1, @wfh.id)).to eq(13)
      end
    end
  end

  describe :total_leaves_count do
    it 'should return 0 if user joined after given financial year' do
      user.update_attributes(joining_date: '2018-10-01')
      expect(user.total_leaves_count('2017-2018')).to eq(0)
    end

    it 'should return the maximum number of leaves/year if the \
    user has already joined before given financial year' do
      expect(user.total_leaves_count('2017-2018')).to eq(16)
    end

    it 'should return the half of the maximum leaves if \
    the user joined exactly mid financial year' do
      user.update_attributes(joining_date: '2017-10-01')
      expect(user.total_leaves_count('2017-2018')).to eq(8)
    end

    it 'should return the quarter of the maximum leaves if the user \
    joined in the last quarter of the financial year' do
      user.update_attributes(joining_date: '2018-01-01')
      expect(user.total_leaves_count('2017-2018')).to eq(4)
    end

    it 'should return ceiling of the fractional value if the user \
    joined in the second month of the first quarter' do
      user.update_attributes(joining_date: '2018-02-01')
      expect(user.total_leaves_count('2017-2018')).to eq(3)
    end
  end

  describe :total_wfhs_count do
    it 'should return 0 if user joined after given fy and quarter' do
      user.update_attributes(joining_date: '2018-10-01')
      expect(user.total_wfhs_count('2017-2018', 1)).to eq(0)
    end

    it 'should return the maximum number of wfhs/quarter if the \
    user has already joined before given fy and quarter' do
      expect(user.total_wfhs_count('2017-2018', 1)).to eq(13)
    end

    it 'should return the half of the maximum wfhs if \
    the user joined exactly mid quarter' do
      user.update_attributes(joining_date: '2017-05-15')
      expect(user.total_wfhs_count('2017-2018', 1)).to eq(7)
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
