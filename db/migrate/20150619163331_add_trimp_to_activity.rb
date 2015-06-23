class AddTrimpToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :trimp, :numeric
  end
end
