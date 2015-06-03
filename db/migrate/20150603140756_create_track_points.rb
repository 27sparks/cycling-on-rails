class CreateTrackPoints < ActiveRecord::Migration
  def change
    create_table :track_points do |t|
      t.references :track, index: true, foreign_key: true
      t.datetime :time
      t.decimal :altitude_meters
      t.decimal :distance_meters
      t.integer :heart_rate_bpm
      t.string :sensor_state

      t.timestamps null: false
    end
  end
end
