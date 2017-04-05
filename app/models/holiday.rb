class Holiday < ApplicationRecord
  validates_presence_of :date, :occasion
  validates_uniqueness_of :date
end
