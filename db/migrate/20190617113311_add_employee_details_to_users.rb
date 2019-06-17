class AddEmployeeDetailsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :employee_id, :string, unique:true
    add_column :users, :DOB, :date
    add_column :users, :leaving_date, :date
    add_column :users, :fathers_name, :string
    add_column :users, :adhaar_number, :string, unique:true
    add_column :users, :PAN_number, :string, unique:true
    add_column :users, :blood_group, :string
    add_column :users, :emergency_contact_number, :string
  end
end
