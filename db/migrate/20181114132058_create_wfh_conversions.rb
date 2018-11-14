class CreateWfhConversions < ActiveRecord::Migration[5.0]
  def change
    create_table :wfh_conversions do |t|
      t.integer :user_id
      t.string :financial_year
      t.float :count, default:0

      t.timestamps
    end
  end
end
