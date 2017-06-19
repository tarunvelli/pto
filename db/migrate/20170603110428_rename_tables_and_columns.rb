class RenameTablesAndColumns < ActiveRecord::Migration[5.0]
  def change
    rename_table :ptos, :ooo_configs
    remove_foreign_key :leaves, :users
    remove_column :leaves, :number_of_half_days
    remove_column :leaves, :reason
    remove_index :leaves, :user_id
    rename_table :leaves, :ooo_periods
    add_index :ooo_periods, :user_id
    add_column :ooo_periods, :type, :string
    add_foreign_key :ooo_periods, :users
    rename_column :ooo_periods, :leave_start_from, :start_date
    rename_column :ooo_periods, :leave_end_at, :end_date
    rename_column :users, :start_date, :joining_date
  end
end
