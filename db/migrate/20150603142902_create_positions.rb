class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.references :track_point, index: true, foreign_key: true
      t.decimal :longitude_degrees
      t.decimal :latitude_degrees

      t.timestamps null: false
    end
  end
end
