class AddSportToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :sport, :string
  end
end
