class AddAvgSpeedToLaps < ActiveRecord::Migration
  def change
    add_column :laps, :avg_speed, :decimal
  end
end
