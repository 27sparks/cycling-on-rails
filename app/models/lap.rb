class Lap < ActiveRecord::Base
  belongs_to :activity
  has_one :track
end
