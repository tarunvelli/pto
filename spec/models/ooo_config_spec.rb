# frozen_string_literal: true

require 'rails_helper'
RSpec.describe OOOConfig, type: :model do
  let(:ooo_config) { OOOConfig.new }
  before :each do
    OOOConfig.create(
      leaves_count: 16,
      wfhs_count: 13,
      wfh_headsup_hours: 7.5,
      wfh_penalty_coefficient: 1,
      start_date: '2017-04-01',
      end_date: '2018-03-31'
    )
    OOOConfig.create(
      leaves_count: 16,
      wfhs_count: 13,
      wfh_headsup_hours: 7.5,
      wfh_penalty_coefficient: 1,
      start_date: '2018-04-01',
      end_date: '2019-03-31'
    )
  end

  describe :should_return_financial_year_for_given_date do
    it 'should return 2017-2018 for 2017-05-01' do
      expect(OOOConfig.get_financial_year_from_date('2017-05-01'.to_date)).to eq('2017/04-2018/03')
    end

    it 'should return 2017-2018 for 2018-01-01' do
      expect(OOOConfig.get_financial_year_from_date('2018-01-01'.to_date)).to eq('2017/04-2018/03')
    end

    it 'should return 2018-2019 for 2018-05-01' do
      expect(OOOConfig.get_financial_year_from_date('2018-05-01'.to_date)).to eq('2018/04-2019/03')
    end

    it 'should return 2018-2019 for 2019-01-01' do
      expect(OOOConfig.get_financial_year_from_date('2019-01-01'.to_date)).to eq('2018/04-2019/03')
    end
  end

  describe :did_user_join_in_between_the_given_fy do
    it 'should return true if date is in between give fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .did_user_join_in_between_the_given_fy('20170827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in between given fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .did_user_join_in_between_the_given_fy('20160527'.to_date)).to eq(false)
    end
  end

  describe :date_in_previous_fy? do
    it 'should return true if date is in previous fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .date_in_previous_fy?('20160527'.to_date)).to eq(true)
    end

    it 'should return false if date is not in previous fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .date_in_previous_fy?('20170827'.to_date)).to eq(false)
    end
  end

  describe :date_in_next_fy? do
    it 'should return true if date is in next fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .date_in_next_fy?('20180827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in next fy' do
      expect(OOOConfig.get_config_from_financial_year(financial_year: '2017/04-2018/03')
        .date_in_next_fy?('20170527'.to_date)).to eq(false)
    end
  end

  describe :check_format_of_financial_year do
    context 'with valid financial year' do
      before { ooo_config.financial_year = '2018-2019' }
      it 'should return nil' do
        expect(ooo_config.send(:check_format_of_financial_year)).to eq(nil)
      end
    end

    context 'with invalid financial year' do
      before { ooo_config.financial_year = '20-18-2019' }
      it 'should return array of errors' do
        expect(ooo_config.send(:check_format_of_financial_year).is_a?(Array)).to eq(true)
      end
    end
  end
end
