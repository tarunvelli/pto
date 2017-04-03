class AddStartDateToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :start_date, :date
  end
end
