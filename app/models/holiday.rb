class Holiday < ApplicationRecord
  validates_presence_of :date, :occasion
  validates_uniqueness_of :date

  #TODO
  # 1. Initialise date to current day by default for any instance
end
