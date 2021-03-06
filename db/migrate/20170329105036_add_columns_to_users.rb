# frozen_string_literal: true

class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email, :string
    add_column :users, :remaining_leaves, :integer
    add_column :users, :total_leaves, :integer
  end
end
