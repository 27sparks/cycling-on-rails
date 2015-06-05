class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :laps

  tmp = {}

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
    self.sport = node.attr('Sport') # Activity.sport
    node.elements.each do |node|
      self.activity_id = node.text.to_s if node.node_name.eql? 'Id' # Activity.activity_id
      parse_lap node if node.node_name.eql? 'Lap'
      parse_training node if node.node_name.eql? 'Training'
      parse_creator node if node.node_name.eql? 'Creator'
    end
  end

  def parse_lap node
    tmp_lap = Lap.new
    tmp_lap[:start_time] = node.attr('StartTime')
    node.elements.each do |node|
      case node.node_name
        when 'TotalTimeSeconds' then tmp_lap[:total_time_seconds] = node.text
        when 'DistanceMeters' then tmp_lap[:distance_meters] = node.text
        when 'Calories' then tmp_lap[:calories] = node.text
        when 'AverageHeartRateBpm' then tmp_lap[:average_heart_rate_bpm] = node.text
        when 'MaximumHeartRateBpm' then tmp_lap[:maximum_heart_rate_bpm] = node.text
        when 'Intensity' then tmp_lap[:intensity] = node.text
        when 'TriggerMethod' then tmp_lap[:trigger_method] = node.text
        when 'Track' then parse_track node, tmp_lap
        when 'Extension' then parse_extension node, tmp_lap #Extension holds the avg_speed for a lap
      end
    end
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

  def parse_extension node, tmp_lap
    tmp_lap[:avg_speed] << node.text
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
