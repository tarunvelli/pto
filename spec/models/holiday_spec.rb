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
    before do
      @holiday = Holiday.new(date: '', occasion: '')
    end

    it 'should have valid occasion' do
      expect(@holiday.valid?).to eq(false)
      expect(@holiday.errors).to include(:occasion)
    end

    it 'should check uniqueness of date' do
      Holiday.create(date: '20170412', occasion: 'RANDOM')
      holiday = Holiday.create(date: '20170412', occasion: 'RANDOM_HOLIDAY')
      expect(holiday.errors.messages[:date]).to include('has already been taken')
      expect(holiday.errors.messages[:date].present?).to eq(true)
      expect(holiday.errors.messages[:date].include?('has already been taken')).to eq(true)
    end
  end

  describe :set_default_values do
    it 'should set default date upon initialization' do
      holiday = Holiday.new
      expect(holiday.date).to eq(Date.today)
    end
  end
end
