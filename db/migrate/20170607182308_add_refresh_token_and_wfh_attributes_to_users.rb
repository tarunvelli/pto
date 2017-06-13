class AddRefreshTokenAndWfhAttributesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :refresh_token, :string
    add_column :users, :total_wfhs, :integer
    add_column :users, :remaining_wfhs, :integer
  end
end
