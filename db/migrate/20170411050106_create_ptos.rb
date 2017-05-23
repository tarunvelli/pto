# frozen_string_literal: true

class CreatePtos < ActiveRecord::Migration[5.0]
  def change
    create_table :ptos do |t|
      t.integer :no_of_pto

      t.timestamps
    end
  end
end
