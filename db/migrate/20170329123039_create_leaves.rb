# frozen_string_literal: true

class CreateLeaves < ActiveRecord::Migration[5.0]
  def change
    create_table :leaves do |t|
      t.date :leave_start_from
      t.date :leave_end_at
      t.integer :number_of_days
      t.integer :number_of_half_days
      t.string :reason
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
