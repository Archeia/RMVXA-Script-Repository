$simport.r('vx_crossover/base_patches', '1.0.0', 'Base Patches for VX') do |d|
  d.depend('iex3/data_cache', '~> 1.0.0')
end

class Game_Map
  def load_map(map_id)
    DataCache.load_map_by_id(@map_id)
  end
  private :load_map

  def setup(map_id)
    @map_id = map_id
    @map = load_map(map_id)
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
  end
end
