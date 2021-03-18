class AddStartAndEndDatesToOooConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :ooo_configs, :start_date, :date
    add_column :ooo_configs, :end_date, :date
  end
end
