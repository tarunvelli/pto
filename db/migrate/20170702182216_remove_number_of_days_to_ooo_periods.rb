class RemoveNumberOfDaysToOooPeriods < ActiveRecord::Migration[5.0]
  def change
    remove_column :ooo_periods, :number_of_days
  end
end
