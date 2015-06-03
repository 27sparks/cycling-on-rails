class Track < ActiveRecord::Base
  belongs_to :lap
  has_many :track_points
end
