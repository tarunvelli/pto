class AddPenaltyCoefficientAndSafeTimeToOooConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.date :date
      t.string :occasion
      t.references :ooo_config, foreign_key: true

      t.timestamps
    end
    add_column :ooo_configs, :wfh_penalty_coefficient, :integer
    add_column :ooo_configs, :wfh_headsup_hours, :float
  end
end
