class RemoveUnnecessaryAttributes < ActiveRecord::Migration[5.0]
  def change
    change_column :ooo_periods, :number_of_days, :integer
    add_index :ooo_configs, :financial_year, unique:true
    drop_table :holidays
    remove_column :users, :remaining_leaves
    remove_column :users, :total_leaves
    remove_column :users, :remaining_wfhs
    remove_column :users, :total_wfhs
  end
end
