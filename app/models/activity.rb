class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :laps

  scope :this_week, -> { where(:start_time => Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :this_month, -> { where(:start_time => Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :this_year, -> { where(:start_time => Time.now.beginning_of_year..Time.now.end_of_year) }
  scope :by_month, ->(month){ where(:start_time => Date.new(Date.now.year, month, 1).beginning_of_month..Date.new(Date.now.year,month,1).end_of_month) }
  scope :by_year, ->(year){ where(:start_time => Date.new(year, 1, 1).beginning_of_year..Date.new(year,1,1).end_of_year) }
  scope :by_year_and_month, ->(year, month){ where(:start_time => Date.new(year, month, 1).beginning_of_month..Date.new(year,month,1).end_of_month) }

  def calculate_avg_heart_rate
    count = 0
    heart_rate_add_up = 0
    self.laps.each do |lap|
      lap.track.track_points.each do |tp|
        count = count + 1
        heart_rate_add_up += tp.heart_rate_bpm unless tp.heart_rate_bpm.nil?
      end
    end
    count != 0 ? heart_rate_add_up / count : 0
  end

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
  def save_with_all_properties path
    xml = File.read path
    doc = Nokogiri::XML(xml)
    parse_xml(doc)
  end

  def parse_xml doc
    doc.root.elements.each do |node|
      parse_author node if node.node_name == 'Author'
      parse_activities node if node.node_name == 'Activities'
    end
  end

  def parse_activities node
    node.elements.each do |node|
      parse_activity node if node.node_name.eql? 'Activity'
    end
  end

  def parse_activity node
    self.distance_m = 0
    self.sport = node.attr('Sport') # Activity.sport
    node.elements.each do |node|
      self.activity_id = node.text.to_s if node.node_name.eql? 'Id' # Activity.activity_id
      parse_lap node if node.node_name.eql? 'Lap'
      parse_training node if node.node_name.eql? 'Training'
      parse_creator node if node.node_name.eql? 'Creator'
    end
    self.avg_heart_rate = calculate_avg_heart_rate
    self.trimp = calculate_trimp
  end

  def parse_lap node
    tmp_lap = Lap.new
    tmp_lap[:start_time] = node.attr('StartTime')
    self.start_time ||= node.attr('StartTime')
    node.elements.each do |node|
      case node.node_name
        when 'TotalTimeSeconds' then tmp_lap[:total_time_seconds] = node.text
        when 'DistanceMeters' then tmp_lap[:distance_meters] = node.text
        when 'Calories' then tmp_lap[:calories] = node.text
        when 'Cadence' then tmp_lap[:cadence] = node.text
        when 'AverageHeartRateBpm' then tmp_lap[:average_heart_rate_bpm] = node.text
        when 'MaximumHeartRateBpm' then tmp_lap[:maximum_heart_rate_bpm] = node.text
        when 'MaximumSpeed' then tmp_lap[:maximum_speed] = node.text
        when 'Intensity' then tmp_lap[:intensity] = node.text
        when 'TriggerMethod' then tmp_lap[:trigger_method] = node.text
        when 'Track' then parse_track node, tmp_lap
        when 'Extensions' then tmp_lap[:avg_speed] = 10#parse_extension_for_avg_speed node #Extension holds the avg_speed for a lap
      end
    end
    self.distance_m += tmp_lap[:distance_meters]
    self.laps << tmp_lap
  end

  def parse_training node

  end

  def parse_creator node

  end

  def parse_track node, tmp_lap
    tmp_track = Track.new
    node.elements.each do |node|
      parse_track_point node, tmp_track
    end
    tmp_lap.track = tmp_track
  end

  def parse_extension_for_avg_speed node
    node.elements
    '10'
  end

  def parse_track_point node, tmp_track
    tmp_track_point = TrackPoint.new
    node.elements.each do |node|
      case node.node_name
        when 'Time' then tmp_track_point[:time] = node.text
        when 'AltitudeMeters' then tmp_track_point[:altitude_meters] = node.text
        when 'DistanceMeters' then tmp_track_point[:distance_meters] = node.text
        when 'HeartRateBpm' then tmp_track_point[:heart_rate_bpm] = node.text
        when 'SensorState' then tmp_track_point[:sensor_state] = node.text
        when 'Position' then parse_position node, tmp_track_point
      end
    end
    tmp_track.track_points << tmp_track_point
  end

  def parse_position node, tmp_track_point
    tmp_position = Position.new
    node.elements.each do |node|
      case node.node_name
        when 'LatitudeDegrees' then tmp_position[:latitude_degrees] = node.text
        when 'LongitudeDegrees' then tmp_position[:longitude_degrees] = node.text
      end
    end
    tmp_track_point.position = tmp_position
  end

  def parse_author node
    #puts "AUTHOR"
    #puts node
  end
end
