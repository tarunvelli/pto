class CreateHolidayLists < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_lists do |t|
      t.date :date
      t.string :occasion

      t.timestamps
    end
  end
end
