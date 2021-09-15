$simport.r 'iek/event_manager', '1.0.0', 'Provides a Event import interface' do |h|
  h.depend 'iek/map_manager', '>= 1.0.0'
end

module EventManager
  def self.get_by_id(map_id, event_id)
    map = MapManager.get_by_id(map_id)
    map.events.fetch(event_id)
  end
end
