class AddTokenExpiresAtToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :token_expires_at, :integer
    remove_column :users, :oauth_expires_at
  end
end
