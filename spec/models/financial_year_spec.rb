# frozen_string_literal: true

require 'rails_helper'
RSpec.describe FinancialYear, type: :model do
  let(:financial_year) { FinancialYear.new }
  describe :should_return_financial_year_for_given_date do
    it 'should return 2017-2018 for 2017-05-01' do
      expect(FinancialYear.get_financial_year('2017-05-01'.to_date)).to eq('2017-2018')
    end

    it 'should return 2017-2018 for 2018-01-01' do
      expect(FinancialYear.get_financial_year('2018-01-01'.to_date)).to eq('2017-2018')
    end

    it 'should return 2018-2019 for 2018-05-01' do
      expect(FinancialYear.get_financial_year('2018-05-01'.to_date)).to eq('2018-2019')
    end

    it 'should return 2018-2019 for 2019-01-01' do
      expect(FinancialYear.get_financial_year('2019-01-01'.to_date)).to eq('2018-2019')
    end
  end

  describe :start_date do
    it 'should return 2017-04-01 for 2017-2018' do
      expect(FinancialYear.new('2017-2018').start_date.strftime('%Y-%m-%d')).to eq('2017-04-01')
    end

    it 'should return 2018-04-01 for 2018-2019' do
      expect(FinancialYear.new('2018-2019').start_date.strftime('%Y-%m-%d')).to eq('2018-04-01')
    end
  end

  describe :end_date do
    it 'should return 2018-03-31 for 2017-2018' do
      expect(FinancialYear.new('2017-2018').end_date.strftime('%Y-%m-%d')).to eq('2018-03-31')
    end

    it 'should return 2019-03-31 for 2018-2019' do
      expect(FinancialYear.new('2018-2019').end_date.strftime('%Y-%m-%d')).to eq('2019-03-31')
    end
  end

  describe :did_user_join_in_between_the_given_fy do
    it 'should return true if date is in between give fy' do
      expect(FinancialYear.new('2017-2018').did_user_join_in_between_the_given_fy('20170827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in between given fy' do
      expect(FinancialYear.new('2017-2018').did_user_join_in_between_the_given_fy('20160527'.to_date)).to eq(false)
    end
  end

  describe :date_in_previous_fy? do
    it 'should return true if date is in previous fy' do
      expect(FinancialYear.new('2017-2018').date_in_previous_fy?('20160527'.to_date)).to eq(true)
    end

    it 'should return false if date is not in previous fy' do
      expect(FinancialYear.new('2017-2018').date_in_previous_fy?('20170827'.to_date)).to eq(false)
    end
  end

  describe :date_in_next_fy? do
    it 'should return true if date is in next fy' do
      expect(FinancialYear.new('2017-2018').date_in_next_fy?('20180827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in next fy' do
      expect(FinancialYear.new('2017-2018').date_in_next_fy?('20170527'.to_date)).to eq(false)
    end
  end
end
