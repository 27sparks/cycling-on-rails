class CreateLaps < ActiveRecord::Migration
  def change
    create_table :laps do |t|
      t.references :activity, index: true, foreign_key: true
      t.decimal :total_time_seconds
      t.decimal :distance_meters
      t.decimal :maximum_speed
      t.integer :calories
      t.integer :average_heart_rate_bpm
      t.integer :maximum_heart_rate_bpm
      t.string :intensity
      t.integer :cadence
      t.string :trigger_method
      t.string :notes

      t.timestamps null: false
    end
  end
end
