class CreatePtos < ActiveRecord::Migration[5.0]
  def change
    create_table :ptos do |t|
      t.string :no_of_pto

      t.timestamps
    end
  end
end
