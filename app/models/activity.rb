class Activity < ActiveRecord::Base
  belongs_to :user

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
    end
  end

  def parse_lap node
    node.elements.each do |node|
      if node.node_name != 'Track'
        puts node.node_name + ' = ' + node.text.to_s
      end
    end
  end

  def parse_author node
    #puts "AUTHOR"
    #puts node
  end
end
