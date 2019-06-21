class AddSkipPenaltyToWfhs < ActiveRecord::Migration[5.0]
  def change
    add_column :ooo_periods, :skip_penalty, :boolean, default: false
  end
end
