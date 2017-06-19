class AddEventIdToLeaves < ActiveRecord::Migration[5.0]
  def change
    add_column :leaves, :google_event_id, :string
  end
end
