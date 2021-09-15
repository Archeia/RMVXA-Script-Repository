#encoding:UTF-8
# 03/16/2011
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_BattleAction
#     new-method :battle_vocab
#     new-method :battle_commands
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-WorldMapSelection"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[26, "WorldMapSelection"]] = 1.0
#-*--------------------------------------------------------------------------*-#
module IEO
  module ICYROSE_WORLDMAP

    module_function

    def update
      availd = $game_map.worldevents.keys.uniq.sort
      lim    = [$game_map.worldevents.keys.compact.size-1, 0].max
      looping= false
      if Input.trigger?(Input::LEFT)
        $game_map.worldevindex = ($game_map.worldevindex-1)
        if looping
          $game_map.worldevindex %= availd.size
        else
          $game_map.worldevindex = [[$game_map.worldevindex, lim].min, 0].max
        end
        $game_variables[3] = availd[$game_map.worldevindex]
      elsif Input.trigger?(Input::RIGHT)
        $game_map.worldevindex = ($game_map.worldevindex+1)
        if looping
          $game_map.worldevindex %= availd.size
        else
          $game_map.worldevindex = [[$game_map.worldevindex, lim].min, 0].max
        end
        $game_variables[3] = availd[$game_map.worldevindex]
      end
    end

    def text_subs(text)
      text.gsub!(/\\n\[(\d+)\]/i) { $game_actors[$1.to_i].name }
    end

  end
end
#==============================================================================#
# IEO::REGEX::RIVIERA_MAPNAVIGATION
#==============================================================================#
module IEO
  module REGEXP
    module ICYROSE_WORLDMAP
      module EVENT
        WORLD_EVENT = /<WORLDEVENT>/i
        LOCAT_NAME  = /<(?:LOCATNAME|LCN):[ ](.*)>/i
        LOCAT_TEXT  = /<(?:LOCATTEXT|LCT):[ ](.*)>/i
        LOCAT_PICT  = /<(?:LOCATPIC|LCP):[ ](.*)>/i
      end
    end
  end
end

#==============================================================================#
# Game_System
#==============================================================================#
class Game_System

  attr_accessor :worldmap_mode

end

#==============================================================================#
# Game_Map
#==============================================================================#
class Game_Map

  attr_accessor :worldevents
  attr_accessor :currentwlocation
  attr_accessor :worldevindex

  alias ieo026_initialize initialize unless $@
  def initialize
    ieo026_initialize
    @worldevents      = {}
    @dual_scroll      = false
    @dual_direction   = []
    @dual_rest        = []
    @currentwlocation = nil
    @worldevindex     = 0
  end

  alias ieo026_refresh refresh unless $@
  def refresh
    ieo026_refresh
    setup_worldevents
  end

  def get_display_xy
    return @display_x, @display_y
  end

  def correct_xy(x, y)
    return x*256, y*256
  end

  def start_dualscroll(d1=[0,0], d2=[0,0], speed=5)
    @dual_direction = [d1[0], d2[0]]
    @dual_rest = [d1[1]*256, d2[1]*256]
    @scroll_rest = 0 ; @dual_rest.each { |a| @scroll_rest += a }
    @scroll_speed = speed
    print @dual_rest
    @dual_scroll = true
  end

  alias ieo026_scrolling? scrolling? unless $@
  def scrolling?
    @dual_rest = [] if @dual_rest.nil?
    if @dual_scroll
      return @dual_rest.all? { |a| a > 0}
    end
    return ieo026_scrolling?
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias ieo026_update update unless $@
  def update
    ieo026_update
    update_dualscroll
  end
  #--------------------------------------------------------------------------
  # * Update Scroll
  #--------------------------------------------------------------------------
  def update_dualscroll
    if @scroll_rest > 0                 # If scrolling
      distance = 2 ** @scroll_speed     # Convert to distance
      for i in 0..@dual_direction.size
        dd = @dual_direction[i]
        @scroll_rest -= distance
        next if dd == nil
        next if @dual_rest[i] <= 0
        case dd
        when 2  # Down
          scroll_down(distance)
        when 4  # Left
          scroll_left(distance)
        when 6  # Right
          scroll_right(distance)
        when 8  # Up
          scroll_up(distance)
        end
        @dual_rest[i] -= distance          # Subtract scrolled distance
      end
    end
    if @dual_rest.all? { |a| a <= 0}
      @dual_rest.clear
      @dual_scroll = false
    end
  end

  def setup_worldevents
    @worldevents = {} if @worldevents.nil?
    @worldevents.clear
    for ev in @events.values.compact
      @worldevents[ev.id] = ev if ev.worldevent
    end
  end

  def set_currentlocation(ev)
    @currentwlocation = ev
  end

end

#==============================================================================#
# Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------
  # * Calculate X Distance From Event
  #--------------------------------------------------------------------------
  def distance_x_from_event(event)
    sx = @x - $game_map.events[event].x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Distance From Event
  #--------------------------------------------------------------------------
  def distance_y_from_event(event)
    sy = @y - $game_map.events[event].y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end

  #--------------------------------------------------------------------------
  # * Move toward Event
  #--------------------------------------------------------------------------
  def move_toward_event(event = 0)
    return if $game_map.events[event].nil?
    sx = distance_x_from_event(event)
    sy = distance_y_from_event(event)
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_left : move_right   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_up : move_down
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_up : move_down      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_left : move_right
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move away from Event
  #--------------------------------------------------------------------------
  def move_away_from_event(event = 0)
    return if $game_map.events[event].nil?
    sx = distance_x_from_event(event)
    sy = distance_x_from_event(event)
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? move_right : move_left   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? move_down : move_up
        end
      else                                # Vertical distance is longer
        sy > 0 ? move_down : move_up      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? move_right : move_left
        end
      end
    end
  end

end

#==============================================================================#
# Game_Event
#==============================================================================#
class Game_Event < Game_Character

  attr_accessor :worldevent
  attr_accessor :location_name
  attr_accessor :location_texts
  attr_accessor :location_picture

  alias ieo026_initialize initialize unless $@
  def initialize(map_id, event)
    @worldevent       = false
    @location_name    = ""
    @location_picture = ""
    @location_texts   = []
    ieo026_initialize(map_id, event)
  end

  alias ieo026_setup setup unless $@
  def setup(new_page)
    ieo026_setup(new_page)
    ieo026_eventcache
  end

  def ieo026_eventcache
    @worldevent       = false
    @location_texts   = []
    @location_picture = ""
    return if @list == nil
    for i in 0..@list.size
      next if @list[i] == nil
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
        case line
        when IEO::REGEXP::ICYROSE_WORLDMAP::EVENT::WORLD_EVENT
          @worldevent = true
        when IEO::REGEXP::ICYROSE_WORLDMAP::EVENT::LOCAT_NAME
          @location_name = $1
        when IEO::REGEXP::ICYROSE_WORLDMAP::EVENT::LOCAT_TEXT
          @location_texts << $1
        when IEO::REGEXP::ICYROSE_WORLDMAP::EVENT::LOCAT_PICT
          @location_picture = $1
        end
        }
      end
    end
  end

end

#==============================================================================#
# Game_Player
#==============================================================================#
class Game_Player < Game_Character

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  alias ieo026_refresh refresh unless $@
  def refresh
    ieo026_refresh
    if $game_system.worldmap_mode
      @character_name = "!$MapCursors"
      @character_index = 0
    end
  end

end

#==============================================================================#
# Game_Interpreter
#==============================================================================#
class Game_Interpreter

  def start_world_map
    $game_system.worldmap_mode = true
    $game_player.refresh
    $game_map.setup_worldevents
    $scene.create_locationwindow if $scene.is_a?(Scene_Map)
  end

  def end_world_map
    $game_system.worldmap_mode = false
    $game_player.refresh
    $scene.dispose_locationwindow if $scene.is_a?(Scene_Map)
  end

  def dual_scroll(d1=[0,0], d2=[0,0], speed=4)
    $game_map.start_dualscroll(d1, d2, speed)
  end

end

#==============================================================================#
# Window_WorldDescription
#==============================================================================#
class Window_WorldDescription < Window_Base

  include IEO::ICYROSE_WORLDMAP

  def initialize(x, y, width, height)
    super(x, y, width, height)
    @location = nil
    refresh
  end

  def update_location(new_location)
    if @location != new_location
      change_location(new_location)
    end
  end

  def change_location(new_location)
    @location = new_location
    refresh
  end

  def refresh
    self.height = 56
    if @location.nil?
      create_contents
      return
    else
      self.height = 56
      self.height += [@location.location_texts.size, 0].max * 24
      create_contents
    end
    self.contents.font.size = 18
    unless @location.location_picture.empty?
      bit = Cache.picture(@location.location_picture)
      if self.height < bit.height+32
        self.height = bit.height+32
        create_contents
      end
      self.contents.blt(self.contents.width/2, 0, bit, bit.rect)
    end
    oi = 0
    unless @location.location_name.empty?
      self.contents.font.color = system_color
      rect = Rect.new(4, 0, self.contents.width, WLH)
      tx = @location.location_name.clone
      text_subs(tx) ; self.contents.draw_text(rect, tx) ; oi += 1
    end
    self.contents.font.color = normal_color
    for i in 0...@location.location_texts.size
      rect = Rect.new(4, 0+((i+oi)*24), self.contents.width, WLH)
      tx = @location.location_texts[i].clone
      text_subs(tx) ; self.contents.draw_text(rect, tx)
    end
  end

end

#==============================================================================#
# Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  def create_locationwindow
    @locatwindow = Window_WorldDescription.new(0, 0, Graphics.width, Graphics.height/2)
  end

  def dispose_locationwindow
    @locatwindow.dispose unless @locatwindow.nil?
  end

  alias ieo026_terminate terminate unless $@
  def terminate
    dispose_locationwindow
    ieo026_terminate
  end

  alias ieo026_update update unless $@
  def update
    ieo026_update
    @locatwindow.update_location($game_map.currentwlocation) unless @locatwindow.nil?
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
