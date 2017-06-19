class ModifyAttributesToOooConfigs < ActiveRecord::Migration[5.0]
  def change
    remove_column :ooo_configs, :no_of_pto
    add_column :ooo_configs, :financial_year, :string
    add_column :ooo_configs, :leaves_count, :integer
    add_column :ooo_configs, :wfhs_count, :text
  end
end
