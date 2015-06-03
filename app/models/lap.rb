class Lap < ActiveRecord::Base
  belongs_to :activity
  has_many :tracks
end
