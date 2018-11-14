require 'rails_helper'

RSpec.describe WfhConversion, type: :model do
  describe :validations do
    %w[
      financial_year count user_id
    ].each do |message|
      it "should respond to :#{message}" do
        expect(WfhConversion.new).to respond_to(message.to_sym)
      end
    end
  end
end
