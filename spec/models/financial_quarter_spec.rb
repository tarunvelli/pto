# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinancialQuarter, type: :model do
  before :each do
    @ooo_config = OOOConfig.create(
      leaves_count: 16,
      wfhs_count: 13,
      wfh_headsup_hours: 7.5,
      wfh_penalty_coefficient: 1,
      start_date: '2017-04-01',
      end_date: '2018-03-31'
    )

    allow(OOOConfig).to receive(:get_config_from_date).and_return(@ooo_config)
  end

  describe :year_and_quarter do
    it 'should return 2017/04-2018/03q1 for 20170630' do
      expect(FinancialQuarter.year_and_quarter('20170630'.to_date)).to eq(['2017/04-2018/03', 1])
    end

    it 'should return 2017/04-2018/03q2 for 20170930' do
      expect(FinancialQuarter.year_and_quarter('20170930'.to_date)).to eq(['2017/04-2018/03', 2])
    end

    it 'should return 2017/04-2018/03q3 for 20171230' do
      expect(FinancialQuarter.year_and_quarter('20171230'.to_date)).to eq(['2017/04-2018/03', 3])
    end

    it 'should return 2017/04-2018/03q4 for 20180330' do
      expect(FinancialQuarter.year_and_quarter('20180330'.to_date)).to eq(['2017/04-2018/03', 4])
    end
  end

  describe :end_month_of_quarter do
    it 'should return 3 for 20170227' do
      expect(FinancialQuarter.end_month_of_quarter('20170227'.to_date)).to eq(3)
    end

    it 'should return 6 for 20170527' do
      expect(FinancialQuarter.end_month_of_quarter('20170527'.to_date)).to eq(6)
    end

    it 'should return 9 for 20170827' do
      expect(FinancialQuarter.end_month_of_quarter('20170827'.to_date)).to eq(9)
    end

    it 'should return 12 for 20171127' do
      expect(FinancialQuarter.end_month_of_quarter('20171127'.to_date)).to eq(12)
    end
  end

  describe :start_month_of_quarter do
    it 'should return 1 for 20170227' do
      expect(FinancialQuarter.start_month_of_quarter('20170227'.to_date)).to eq(1)
    end

    it 'should return 4 for 20170527' do
      expect(FinancialQuarter.start_month_of_quarter('20170527'.to_date)).to eq(4)
    end

    it 'should return 7 for 20170827' do
      expect(FinancialQuarter.start_month_of_quarter('20170827'.to_date)).to eq(7)
    end

    it 'should return 10 for 20171127' do
      expect(FinancialQuarter.start_month_of_quarter('20171127'.to_date)).to eq(10)
    end
  end

  describe :get_quarter do
    it 'should return 4 for 20170227' do
      expect(FinancialQuarter.get_quarter('20170227'.to_date)).to eq(4)
    end

    it 'should return 1 for 20170527' do
      expect(FinancialQuarter.get_quarter('20170527'.to_date)).to eq(1)
    end

    it 'should return 2 for 20170827' do
      expect(FinancialQuarter.get_quarter('20170827'.to_date)).to eq(2)
    end

    it 'should return 3 for 20171127' do
      expect(FinancialQuarter.get_quarter('20171127'.to_date)).to eq(3)
    end
  end

  describe :should_return_start_date_of_given_fy_and_given_quarter do
    it 'should return 2017-04-01 if fy is 2017/04-2018/03 and quarter 1' do
      expect(FinancialQuarter.new(@ooo_config, 1).start_date.strftime('%Y-%m-%d')).to eq('2017-04-01')
    end

    it 'should return 2017-07-01 if fy is 2017/04-2018/03 and quarter 2' do
      expect(FinancialQuarter.new(@ooo_config, 2).start_date.strftime('%Y-%m-%d')).to eq('2017-07-01')
    end

    it 'should return 2017-10-01 if fy is 2017/04-2018/03 and quarter 3' do
      expect(FinancialQuarter.new(@ooo_config, 3).start_date.strftime('%Y-%m-%d')).to eq('2017-10-01')
    end

    it 'should return 2018-01-01 if fy is 2017/04-2018/03 and quarter 4' do
      expect(FinancialQuarter.new(@ooo_config, 4).start_date.strftime('%Y-%m-%d')).to eq('2018-01-01')
    end
  end

  describe :should_return_end_date_of_given_fy_and_given_quarter do
    it 'should return 2017-06-30 if fy is 2017/04-2018/03 and quarter 1' do
      expect(FinancialQuarter.new(@ooo_config, 1).end_date.strftime('%Y-%m-%d')).to eq('2017-06-30')
    end

    it 'should return 2017-09-30 if fy is 2017/04-2018/03 and quarter 2' do
      expect(FinancialQuarter.new(@ooo_config, 2).end_date.strftime('%Y-%m-%d')).to eq('2017-09-30')
    end

    it 'should return 2017-12-31 if fy is 2017/04-2018/03 and quarter 3' do
      expect(FinancialQuarter.new(@ooo_config, 3).end_date.strftime('%Y-%m-%d')).to eq('2017-12-31')
    end

    it 'should return 2018-03-31 if fy is 2017/04-2018/03 and quarter 4' do
      expect(FinancialQuarter.new(@ooo_config, 4).end_date.strftime('%Y-%m-%d')).to eq('2018-03-31')
    end
  end

  describe :quarter_month_numbers do
    it 'should return 4,5,6 for quarter 1' do
      expect(FinancialQuarter.new(@ooo_config, 1).quarter_month_numbers).to eq([4, 5, 6])
    end

    it 'should return 7,8,9 for quarter 2' do
      expect(FinancialQuarter.new(@ooo_config, 2).quarter_month_numbers).to eq([7, 8, 9])
    end

    it 'should return 10,11,12 for quarter 3' do
      expect(FinancialQuarter.new(@ooo_config, 3).quarter_month_numbers).to eq([10, 11, 12])
    end

    it 'should return 1,2,3 for quarter 4' do
      expect(FinancialQuarter.new(@ooo_config, 4).quarter_month_numbers).to eq([1, 2, 3])
    end
  end

  describe :did_user_join_in_between_the_quarter do
    it 'should return true if date is in between give quarter' do
      expect(FinancialQuarter.new(@ooo_config, 2)
        .did_user_join_in_between_the_quarter('20170827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in between given quarter' do
      expect(FinancialQuarter.new(@ooo_config, 2)
        .did_user_join_in_between_the_quarter('20170527'.to_date)).to eq(false)
    end
  end

  describe :date_in_previous_fq do
    it 'should return true if date is in previous quarter' do
      expect(FinancialQuarter.new(@ooo_config, 2).date_in_previous_fq('20170527'.to_date)).to eq(true)
    end

    it 'should return false if date is not in previous quarter' do
      expect(FinancialQuarter.new(@ooo_config, 2).date_in_previous_fq('20170827'.to_date)).to eq(false)
    end
  end

  describe :date_in_next_fq? do
    it 'should return true if date is in next quarter' do
      expect(FinancialQuarter.new(@ooo_config, 1).date_in_next_fq?('20170827'.to_date)).to eq(true)
    end

    it 'should return false if date is not in next quarter' do
      expect(FinancialQuarter.new(@ooo_config, 1).date_in_next_fq?('20170527'.to_date)).to eq(false)
    end
  end
end
