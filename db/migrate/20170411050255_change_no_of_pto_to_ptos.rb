class ChangeNoOfPtoToPtos < ActiveRecord::Migration[5.0]
  def up
    change_column :ptos, :no_of_pto, :integer
  end

  def down
    change_column :ptos, :no_of_pto, :string
  end
end
