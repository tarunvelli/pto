class ChangeColumnTypeToLeave < ActiveRecord::Migration[5.0]
  def up
    change_column :leaves, :number_of_days, :float
  end

  def down
    change_column :leaves, :number_of_days, :integer
  end
end
