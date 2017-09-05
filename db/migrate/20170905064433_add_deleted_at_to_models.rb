class AddDeletedAtToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :ooo_periods, :deleted_at, :datetime
    add_column :holidays, :deleted_at, :datetime
    add_column :ooo_configs, :deleted_at, :datetime
  end
end
