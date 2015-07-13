class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :laps, :dependent => :destroy

  scope :this_week, -> { where(:start_time => Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :this_month, -> { where(:start_time => Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :this_year, -> { where(:start_time => Time.now.beginning_of_year..Time.now.end_of_year) }
  scope :by_month, ->(month){ where(:start_time => Date.new(Date.now.year, month, 1).beginning_of_month..Date.new(Date.now.year,month,1).end_of_month) }
  scope :by_year, ->(year){ where(:start_time => Date.new(year, 1, 1).beginning_of_year..Date.new(year,1,1).end_of_year) }
  scope :by_year_and_month, ->(year, month){ where(:start_time => Date.new(year, month, 1).beginning_of_month..Date.new(year,month,1).end_of_month) }

  def avghr_bpm
    self.avg_heart_rate
  end

  def duration_s
    duration_seconds = 0
    self.laps.each do |lap|
      duration_seconds += lap.total_time_seconds
    end
    duration_seconds.to_f
  end

  def duration_min
    (duration_s / 60).to_f
  end

  def duration_h
    (duration_min / 60).to_f
  end

  def duration_hours # returns a string value for views
    "#{(duration_min / 60).to_i}:#{(duration_min % 60).to_i} h"
  end

  def distance_km
    (distance_m/1000).to_f
  end

  def distance_mi
    ((distance_m/1000)/1.609344).to_f
  end

  def intensity
    self.avg_heart_rate.fdiv(self.user.lactate_threshold) / 100 * 90
  end

  def hf_per_rest
    (self.avg_heart_rate - self.user.min_heart_rate).fdiv(self.user.max_heart_rate - self.user.min_heart_rate)
  end

  def calculate_trimp
    rpe = 7 #cycling
    a = 0.64
    b = 1.92
    #a, b: Faktoren (für Männer: a = 0.64, b = 1.92 - für Frauen: a = 0.86, b = 1.67)
    duration_min * (hf_per_rest * a * (Math::E ** (b * hf_per_rest))) * rpe.fdiv(10)
  end

  def trimp_imp
    trimp
  end

  ### The following is all about parsing/importing the tcx/xml ###
  def save_with_all_properties data
    @heart_rate_array = []
    self.laps = []
    self.distance_m = 0
    self.sport = data['Activities']['Activity']['Sport']
    self.activity_id = data['Activities']['Activity']['Id']
    self[:start_time] ||= DateTime.parse(data['Activities']['Activity']['Id'])
    if data['Activities']['Activity']['Lap'].class == Array
      data['Activities']['Activity']['Lap'].each do |lap|
        parse_lap lap
      end
    else
      parse_lap data['Activities']['Activity']['Lap']
    end
    self.avg_heart_rate = @heart_rate_array.sum / @heart_rate_array.count
    self.trimp = calculate_trimp
  end

  def parse_lap lap
    tmp_lap = Lap.new
    tmp_lap[:start_time] = DateTime.parse(lap['StartTime'])
    tmp_lap[:total_time_seconds] = lap['TotalTimeSeconds'].to_f
    tmp_lap[:distance_meters] = lap['DistanceMeters']
    tmp_lap[:calories] = lap['Calories']
    tmp_lap[:cadence] = lap['Cadence']
    tmp_lap[:average_heart_rate_bpm] = lap['AverageHeartRateBpm']
    tmp_lap[:maximum_heart_rate_bpm] = lap['MaximumHeartRateBpm']
    tmp_lap[:maximum_speed] = lap['MaximumSpeed']
    tmp_lap[:intensity] = lap['Intensity']
    tmp_lap[:trigger_method] = lap['TriggerMethod']
    self.distance_m += tmp_lap[:distance_meters]
    tmp_track = Track.new
    lap['Track']['Trackpoint'].each do |trackpoint|
      puts trackpoint['DistanceMeters']
      tmp_track_point = TrackPoint.new
      tmp_track_point[:time] = trackpoint['Time']
      tmp_track_point[:altitude_meters] = trackpoint['AltitudeMeters']
      tmp_track_point[:distance_meters] = trackpoint['DistanceMeters']
      tmp_track_point[:heart_rate_bpm] = trackpoint['HeartRateBpm'] ? trackpoint['HeartRateBpm']['Value'] : 0
      @heart_rate_array << tmp_track_point[:heart_rate_bpm].to_i
      tmp_track_point[:sensor_state] = trackpoint['SensorState']
      if trackpoint[:Position].present?
        tmp_position = Position.new
        tmp_position[:latitude_degrees] = trackpoint['Position']['LatitudeDegrees']
        tmp_position[:longitude_degrees] = trackpoint['Position']['LongitudeDegrees']
        tmp_track_point.position = tmp_position
      end
      tmp_track.track_points << tmp_track_point
    end
    tmp_lap.track = tmp_track
    self.laps << tmp_lap
    # parse_extension TODO
    # parse_training ['Activities']['Activity']['Training'] TODO
    # parse_creator ['Activities']['Activity']['Creator'] TODO
  end
end
