# frozen_string_literal: true

require 'rails_helper'
RSpec.describe OOOConfig, type: :model do
  let(:ooo_config) { OOOConfig.new }

  describe :check_format_of_financial_year do
    context 'with valid financial year' do
      before { ooo_config.financial_year = '2018-2019' }
      it 'should return nil' do
        expect(ooo_config.check_format_of_financial_year).to eq(nil)
      end
    end

    context 'with invalid financial year' do
      before { ooo_config.financial_year = '20-18-2019' }
      it 'should return array of errors' do
        expect(ooo_config.check_format_of_financial_year.is_a?(Array)).to eq(true)
      end
    end
  end
end
