class Game_Character
  # update
  alias :iek_cmev_reg_update :update
  def update
    iek_cmev_reg_update
    if @cmevlast != (n = [self.x, self.y])
      @cmevlast = n
      on_position_changed
    end
  end

  ##
  # on_position_changed
  def on_position_changed
    return unless @cmevlast
    x, y = @cmevlast
    $game_map.alert_tile(x, y, self)
  end
end

class Game_Map
  attr_reader :alert_map # Array<Array<Array<ID>>>

  ##
  # setup(Integer id)
  alias :iek_cmev_reg_setup :setup
  def setup(*args)
    iek_cmev_reg_setup(*args)
    init_alert_map
    (@child_interpreters ||= []).clear
    (@removal ||= []).clear
  end

  ##
  # init_alert_map
  def init_alert_map
    @alert_map = Array.new(@map.height) { Array.new(@map.width) { [] } }
  end

  ##
  # update
  alias :iek_cmev_reg_update :update
  def update(*args)
    iek_cmev_reg_update(*args)
    if @child_interpreters
      @child_interpreters.each do |intp|
        intp.update
        @removal.push(inpt) if !inpt.running?
      end

      if !@removal.empty?
        @removal.each do |intp|
          @child_interpreters.delete(intp)
        end
        @removal.clear
      end
    end
  end

  ##
  # register_tile_event(Integer x, Integer y, Integer id)
  def register_tile_event(x, y, id)
    init_alert_map unless @alert_map
    a = @alert_map[y][x]
    a.push(id) unless a.include?(id)
  end

  ##
  # clear_tile_event(Integer x, Integer y)
  def clear_tile_event(x, y)
    return unless @alert_map
    @alert_map[y][x].clear
  end

  ##
  # clear_tile_events
  def clear_tile_events
    return unless @alert_map
    for y in 0...height
      for x in 0...width
        clear_tile_event(x, y)
      end
    end
  end

  ##
  # alert_tile(Integer x, Integer y, Game_Character character)
  def alert_tile(x, y, character)
    init_alert_map unless @alert_map
    return if x < 0 || x >= width || y < 0 || y >= height
    array = @alert_map[y][x]
    ev_id = character ? (character.is_a?(Game_Player) ? -1 : character.id) : 0
    array.each do |cmev_id|
      if common_event = $data_common_events[cmev_id]
        child = Game_Interpreter.new(0)
        child.setup(common_event.list, ev_id)
        child.run
        @child_interpreters.push(child)
      end
    end
  end

end

class Game_Interpreter

  ##
  # register_tile_event(Integer x, Integer y, Integer id)
  def register_tile_event(x, y, id)
    $game_map.register_tile_event(x, y, id)
  end

  ##
  # clear_tile_event(Integer x, Integer y)
  def clear_tile_event(x, y)
    $game_map.clear_tile_event(x, y)
  end

  ##
  # clear_tile_events
  def clear_tile_events
    $game_map.clear_tile_events
  end

end
