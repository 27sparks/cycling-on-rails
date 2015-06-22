class AddAvgHeartRateToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :avg_heart_rate, :integer
  end
end
