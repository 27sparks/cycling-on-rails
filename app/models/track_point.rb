class TrackPoint < ActiveRecord::Base
  belongs_to :track
  has_one :position, :dependent => :destroy
end
