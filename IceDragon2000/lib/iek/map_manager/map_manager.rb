$simport.r 'iek/map_manager', '1.0.0', 'Provides a Map management interface'

module MapManager
  def self.load_file(filename)
    load_data(filename)
  end

  def self.load_map_by_id(map_id)
    load_file('Data/Map%03d.rvdata2' % map_id)
  end

  def self.get_by_id(map_id)
    @data[map_id] ||= load_map_by_id(map_id)
  end

  def self.clear
    @data = {}
  end

  clear
end
