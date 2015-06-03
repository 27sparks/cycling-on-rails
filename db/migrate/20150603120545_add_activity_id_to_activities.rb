class AddActivityIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :activity_id, :string
  end
end
