class AddStartTimeToLap < ActiveRecord::Migration
  def change
    add_column :laps, :start_time, :datetime
  end
end
