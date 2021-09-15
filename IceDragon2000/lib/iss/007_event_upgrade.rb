#encoding:UTF-8
# ISS007 - Event Upgrade 1.6
#==============================================================================#
# ** ISS - Event Upgrade
#==============================================================================#
# ** Date Created  : 04/28/2011
# ** Date Modified : 08/26/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 007
# ** Version       : 1.6
# ** Requires      : ISS000 - Core 1.7 (or above)
#==============================================================================#
# // Event Comments - place these in event comments (D: yeah)
#==============================================================================#
# // <temp_event>, <temp event>, <tempevent>
# //   A prototype function.
# //   Any changes made to this event's self switches will not be permanent.
# //
# // <copyevent: map_id, event_id>
# // <copyevent: event_id>
# //   Copies an event(event_id) from map(map_id) into the selected event
# //   The event that calls this has all its pages overwritten
# //   Any following comments and commands will not be processed
# //   The second copy event, copies event(event_id) from the COPY_MAP
# //
# // <screen_z: z>, <screen z: z>, <screenz: z>
# //   Overrides the default screen_z position
# //   The higher the value the more UPFRONT the event will be shown
# //
# // <water_move>, <water move>, <watermove>
# //   Forces the event to only move on water.
# //
#==============================================================================#
($imported ||= {})["ISS-EventUpgrade"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(7, :event)
  module EV_UPGRADE
    RESET_TEMP_ON_PAGE = false
    COPY_MAP = 39
  end
  module MixIns::ISS007 ; end
end

#==============================================================================#
# ** ISS::REGEXP::ISS007
#==============================================================================#
module ISS
  module REGEXP
    module ISS007
      module EVENT
        TEMP     = /<(TEMP_EVENT|TEMP EVENT|TEMPEVENT)>/i
        COPY1    = /<(?:COPY_EVENT|COPY EVENT|COPYEVENT):[ ]*(\d+)[ ]*,[ ]*(\d+)>/i
        COPY2    = /<(?:COPY_EVENT|COPY EVENT|COPYEVENT):[ ]*(\d+)>/i
        SCREEN_Z1= /<(?:SCREEN_Z|SCREEN Z|SCREENZ):[ ]*(\d+)>/i
        SCREEN_Z2= /<(?:SCREEN_Z|SCREEN Z|SCREENZ):[ ]*(\w+)>/i
        WATER    = /<(?:WATER_MOVE|WATER MOVE|WATERMOVE)>/i
      end
    end
  end
end

#==============================================================================#
# ** ISS::MixIns::ISS007::Event
#==============================================================================#
module ISS::MixIns::ISS007::Event

  #--------------------------------------------------------------------------#
  # * ISS Event Cache Setup
  #--------------------------------------------------------------------------#
  iss_cachedummies :event, 7

  #--------------------------------------------------------------------------#
  # * new-method :iss007_initcache
  #--------------------------------------------------------------------------#
  def iss007_initcache()
    @self_switches = {}
    @self_switches["A"] = false
    @self_switches["B"] = false
    @self_switches["C"] = false
    @self_switches["D"] = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_self_switch
  #--------------------------------------------------------------------------#
  def set_self_switch(swi, bool)
    if @temp_event # // Temp Event Internal Self Switch
      @self_switches[ swi.upcase ] = bool
    else
      key = [ @map_id, @id, swi.upcase ]
      $game_self_switches[ key ] = bool
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss007_eventcache_start
  #--------------------------------------------------------------------------#
  def iss007_eventcache_start()
    @z_over = nil
    @temp_event = false if @reset_temp_on_page
    @water_event= false
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss007_eventcache_check
  #--------------------------------------------------------------------------#
  def iss007_eventcache_check(comment)
    case comment
    when ISS::REGEXP::ISS007::EVENT::WATER
      @water_event= true
    when ISS::REGEXP::ISS007::EVENT::TEMP
      @temp_event = true
    when ISS::REGEXP::ISS007::EVENT::SCREEN_Z1
      @z_over = $1.to_i
    when ISS::REGEXP::ISS007::EVENT::SCREEN_Z2

    when ISS::REGEXP::ISS007::EVENT::COPY1
      @event = $game_map.get_event($1.to_i, $2.to_i).clone
      @event.id = @id
      return refresh()
    when ISS::REGEXP::ISS007::EVENT::COPY2
      @event = $game_map.get_event(ISS::EV_UPGRADE::COPY_MAP, $1.to_i).clone
      @event.id = @id
      @event.parse_lists() unless @event.lists_parsed if $imported["ISS-CEC"]
      return refresh()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss007_eventcache_end
  #--------------------------------------------------------------------------#
  def iss007_eventcache_end() ; end

end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :reset_temp_on_page

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss007_gsys_initialize :initialize unless $@
  def initialize()
    iss007_gsys_initialize()
    @reset_temp_on_page = ::ISS::EV_UPGRADE::RESET_TEMP_ON_PAGE
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * Include Module(s)
  #--------------------------------------------------------------------------#
  include ISS::MixIns::ISS007::Event

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :temp_event

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss007_ge_initialize :initialize unless $@
  def initialize(map_id, event)
    @temp_event = false
    @z_over = nil
    @reset_temp_on_page = $game_system.reset_temp_on_page
    iss007_ge_initialize(map_id, event)
    iss007_initcache()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :conditions_met?
  #--------------------------------------------------------------------------#
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid      # Switch 1
      return false if $game_switches[c.switch1_id] == false
    end
    if c.switch2_valid      # Switch 2
      return false if $game_switches[c.switch2_id] == false
    end
    if c.variable_valid     # Variable
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if @temp_event # // Temp Event Internal Self Switch
      return false unless @self_switches[c.self_switch_ch] if c.self_switch_valid
    else
      if c.self_switch_valid  # Self switch
        key = [@map_id, @event.id, c.self_switch_ch]
        return false if $game_self_switches[key] != true
      end
    end
    if c.item_valid         # Item
      item = $data_items[c.item_id]
      return false if $game_party.item_number(item) == 0
    end
    if c.actor_valid        # Actor
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true   # Conditions met
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss007_ge_setup :setup unless $@
  def setup(new_page)
    iss007_ge_setup(new_page)
    iss007_eventcache()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :screen_z
  #--------------------------------------------------------------------------#
  alias :iss007_ge_screen_z :screen_z unless $@
  def screen_z(*args, &block)
    return @z_over.nil?() ? iss007_ge_screen_z(*args, &block) : @z_over
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :map_passable?
  #--------------------------------------------------------------------------#
  def map_passable?(x, y)
    return $game_map.ship_passable?(x, y) if @water_event
    return super(x, y)
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * overwrite-method :command_123
  #--------------------------------------------------------------------------#
  def command_123()
    if @original_event_id > 0
      ev = get_character(@original_event_id)
      if !ev.nil?() && ev.temp_event && ev.map_id == $game_map.map_id
        ev.set_self_switch(@params[0], @params[1] == 0)
      else
        key = [@map_id, @original_event_id, @params[0]]
        $game_self_switches[key] = (@params[1] == 0)
      end
    end
    $game_map.need_refresh = true
    return true
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
