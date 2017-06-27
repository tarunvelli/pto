# frozen_string_literal: true

class OooPeriodsInfo < ApplicationRecord
  belongs_to :user
  validates :financial_year, :total_leaves, :remaining_leaves,
            :user_id, presence: true
  serialize :total_wfhs, Hash
  serialize :remaining_wfhs, Hash

  def self.get_user_info_by_fy(financial_year)
    OooPeriodsInfo.where('financial_year = ? ', financial_year)
  end
end
