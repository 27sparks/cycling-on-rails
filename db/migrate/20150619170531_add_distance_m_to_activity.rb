class AddDistanceMToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :distance_m, :integer
  end
end
