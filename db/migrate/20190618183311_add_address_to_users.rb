class AddAddressToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mailing_address, :string
    add_column :users, :personal_email, :string
    add_column :users, :contact_number, :string
    add_column :users, :passport_number, :string
  end
end
