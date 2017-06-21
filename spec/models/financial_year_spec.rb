# frozen_string_literal: true

require 'rails_helper'
RSpec.describe FinancialYear, type: :model do
  let(:financial_year) { FinancialYear.new }
  describe :should_return_financial_year_for_given_date do
    it 'should return 2017-2018 for 2017-05-01' do
      expect(financial_year.get_financial_year('2017-05-01'.to_date))
        .to eq('2017-2018')
    end

    it 'should return 2017-2018 for 2018-01-01' do
      expect(financial_year.get_financial_year('2018-01-01'.to_date))
        .to eq('2017-2018')
    end
  end

  describe :start_date do
    it 'should return 2017-04-01 for 2017-2018' do
      expect(financial_year.start_date('2017-2018').strftime('%Y-%m-%d'))
        .to eq('2017-04-01')
    end
  end

  describe :end_date do
    it 'should return 2018-03-31 for 2017-2018' do
      expect(financial_year.end_date('2017-2018').strftime('%Y-%m-%d'))
        .to eq('2018-03-31')
    end
  end
end
