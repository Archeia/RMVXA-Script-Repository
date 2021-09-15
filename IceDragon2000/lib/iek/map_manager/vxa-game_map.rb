$simport.depend! 'iek/map_manager', '>= 1.0.0'

class Game_Map
  ##
  # @overwrite
  # @param [Integer] map_id
  def setup(map_id)
    @map_id = map_id
    @map = MapManager.get_by_id(@map_id)
    @tileset_id = @map.tileset_id
    @display_x = 0
    @display_y = 0
    refresh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    setup_battleback
    @need_refresh = false
  end
end
