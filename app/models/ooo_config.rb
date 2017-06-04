# frozen_string_literal: true

class OOOConfig < ApplicationRecord
  validates :no_of_pto, presence: true
end
