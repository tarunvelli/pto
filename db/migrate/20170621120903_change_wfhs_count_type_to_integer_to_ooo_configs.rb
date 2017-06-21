class ChangeWfhsCountTypeToIntegerToOooConfigs < ActiveRecord::Migration[5.0]
  def change
    remove_column :ooo_configs, :wfhs_count
    add_column :ooo_configs, :wfhs_count, :integer
  end
end
