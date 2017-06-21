# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinancialQuarter, type: :model do
  let(:financial_quarter) { FinancialQuarter.new }
  describe :should_return_start_date_of_given_fy_and_given_quarter do
    it 'should return 2017-04-01 if fy is 2017-2018 and quarter 1' do
      expect(financial_quarter.start_date('2017-2018', 1).strftime('%Y-%m-%d'))
        .to eq('2017-04-01')
    end

    it 'should return 2017-07-01 if fy is 2017-2018 and quarter 2' do
      expect(financial_quarter.start_date('2017-2018', 2).strftime('%Y-%m-%d'))
        .to eq('2017-07-01')
    end

    it 'should return 2017-10-01 if fy is 2017-2018 and quarter 3' do
      expect(financial_quarter.start_date('2017-2018', 3).strftime('%Y-%m-%d'))
        .to eq('2017-10-01')
    end

    it 'should return 2018-01-01 if fy is 2017-2018 and quarter 4' do
      expect(financial_quarter.start_date('2017-2018', 4).strftime('%Y-%m-%d'))
        .to eq('2018-01-01')
    end
  end

  describe :should_return_end_date_of_given_fy_and_given_quarter do
    it 'should return 2017-06-30 if fy is 2017-2018 and quarter 1' do
      expect(financial_quarter.end_date('2017-2018', 1).strftime('%Y-%m-%d'))
        .to eq('2017-06-30')
    end

    it 'should return 2017-09-30 if fy is 2017-2018 and quarter 2' do
      expect(financial_quarter.end_date('2017-2018', 2).strftime('%Y-%m-%d'))
        .to eq('2017-09-30')
    end

    it 'should return 2017-12-31 if fy is 2017-2018 and quarter 3' do
      expect(financial_quarter.end_date('2017-2018', 3).strftime('%Y-%m-%d'))
        .to eq('2017-12-31')
    end

    it 'should return 2018-03-31 if fy is 2017-2018 and quarter 4' do
      expect(financial_quarter.end_date('2017-2018', 4).strftime('%Y-%m-%d'))
        .to eq('2018-03-31')
    end
  end

  describe :quarter_month_numbers do
    it 'should return 4,5,6 for quarter 1' do
      expect(financial_quarter.quarter_month_numbers(1)).to eq([4, 5, 6])
    end

    it 'should return 7,8,9 for quarter 2' do
      expect(financial_quarter.quarter_month_numbers(2)).to eq([7, 8, 9])
    end

    it 'should return 10,11,12 for quarter 3' do
      expect(financial_quarter.quarter_month_numbers(3)).to eq([10, 11, 12])
    end

    it 'should return 1,2,3 for quarter 4' do
      expect(financial_quarter.quarter_month_numbers(4)).to eq([1, 2, 3])
    end
  end

  describe :year_and_quarter do
    it 'should return 2017-2018q1 for 20170630' do
      expect(financial_quarter.year_and_quarter('20170630'.to_date))
        .to eq('2017-2018q1')
    end

    it 'should return 2017-2018q2 for 20170930' do
      expect(financial_quarter.year_and_quarter('20170930'.to_date))
        .to eq('2017-2018q2')
    end

    it 'should return 2017-2018q3 for 20171230' do
      expect(financial_quarter.year_and_quarter('20171230'.to_date))
        .to eq('2017-2018q3')
    end

    it 'should return 2017-2018q4 for 20180330' do
      expect(financial_quarter.year_and_quarter('20180330'.to_date))
        .to eq('2017-2018q4')
    end
  end

  describe :end_month_of_quarter do
    it 'should return 3 for 20170227' do
      expect(financial_quarter.end_month_of_quarter('20170227'.to_date))
        .to eq(3)
    end

    it 'should return 6 for 20170527' do
      expect(financial_quarter.end_month_of_quarter('20170527'.to_date))
        .to eq(6)
    end

    it 'should return 9 for 20170827' do
      expect(financial_quarter.end_month_of_quarter('20170827'.to_date))
        .to eq(9)
    end

    it 'should return 12 for 20171127' do
      expect(financial_quarter.end_month_of_quarter('20171127'.to_date))
        .to eq(12)
    end
  end

  describe :start_month_of_quarter do
    it 'should return 1 for 20170227' do
      expect(financial_quarter.start_month_of_quarter('20170227'.to_date))
        .to eq(1)
    end

    it 'should return 4 for 20170527' do
      expect(financial_quarter.start_month_of_quarter('20170527'.to_date))
        .to eq(4)
    end

    it 'should return 7 for 20170827' do
      expect(financial_quarter.start_month_of_quarter('20170827'.to_date))
        .to eq(7)
    end

    it 'should return 10 for 20171127' do
      expect(financial_quarter.start_month_of_quarter('20171127'.to_date))
        .to eq(10)
    end
  end
end
