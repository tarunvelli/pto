# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holiday, type: :model do
  %w[
    date occasion
  ].each do |message|
    it 'should respond to :#{message}' do
      expect(Holiday.new).to respond_to(message.to_sym)
    end
  end

  describe :validations do
    it 'should have valid occasion' do
      @holiday = Holiday.new(date: '', occasion: '')
      expect(@holiday.valid?).to eq(false)
      expect(@holiday.errors).to include(:occasion)
    end

    it 'should check uniqueness of date' do
      config_params = { financial_year: '2017-2018',
                        leaves_count: 16,
                        wfhs_count: 13,
                        wfh_headsup_hours: 7.5,
                        wfh_penalty_coefficient: 1 }
      ooo_config = OOOConfig.create!(config_params)
      ooo_config.holidays.create(date: '20170412'.to_date, occasion: 'RANDOM')
      holiday = ooo_config.holidays.create(date: '20170412', occasion: 'RANDOM_HOLIDAY')
      expect(holiday.errors.messages[:date])
        .to include('has already been taken')
    end
  end

  describe :set_default_values do
    it 'should set default date upon initialization' do
      holiday = Holiday.new
      expect(holiday.date).to eq(Time.zone.today)
    end
  end
end
