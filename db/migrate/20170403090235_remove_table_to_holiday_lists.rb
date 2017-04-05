class RemoveTableToHolidayLists < ActiveRecord::Migration[5.0]
  def change
  	drop_table :holiday_lists
  end
end
