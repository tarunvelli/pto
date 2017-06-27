class CreateOooPeriodsInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :ooo_periods_infos do |t|
      t.string :financial_year
      t.integer :remaining_leaves
      t.integer :total_leaves
      t.text :total_wfhs
      t.text :remaining_wfhs
      t.references :user, foreign_key: true

      t.timestamps
    end
    change_column :ooo_periods, :number_of_days, :integer
    add_index :ooo_periods_infos, [:financial_year, :user_id], unique: true
    add_index :ooo_configs, :financial_year, unique:true
  end
end
