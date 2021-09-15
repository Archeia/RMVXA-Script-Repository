#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - CacheMapEx"
#-define HDR_GDC :dc=>"04/15/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
($imported||={})['IEI::MapCache'] = 0x10000

$simport.r 'iei/uniq_maps', '0.1.0', 'IEI Unique Maps'

#-inject gen_class_header 'IEI::CacheMapEx'
module IEI
  class CacheMapEx

    class ExCache

      attr_accessor :self_switches, :variables, :switches

      def initialize(map_id)
        @map_id = map_id
        @self_switches = Game::SelfSwitches.new
        @variables     = Game::Variables.new
        @switches      = Game::Switches.new
      end

    end

    def initialize(game_map)
      @game_map = game_map
      @caches = {}
    end

    def cache(map_id=@game_map.map_id)
      (@caches[map_id] ||= ExCache.new(map_id))
    end

    def variables(map_id=@game_map.map_id)
      cache(map_id).variables
    end

    def switches(map_id=@game_map.map_id)
      cache(map_id).switches
    end

    def self_switches(map_id=@game_map.map_id)
      cache(map_id).self_switches
    end

  end
end

#-inject gen_class_header 'Game::Map'
class Game::Map

  alias iei_gmp_initialize initialize
  def initialize()
    iei_gmp_initialize()
    excache()
  end

  def excache()
    @excache ||= IEI::CacheMapEx.new(self)
  end

end

#-inject gen_class_header 'Game::Event'
class Game::Event

  def is_unique_event?()
    !!(@event.name =~ /\[UNIQ\]/i)
  end

  def conditions_met?(page)
    c = page.condition
    if is_unique_event?
      excache = _map.excache
      switches      = excache.switches
      variables     = excache.variables
      self_switches = excache.self_switches
    else
      switches      = $game.switches
      variables     = $game.variables
      self_switches = $game.self_switches
    end
    if c.switch1_valid
      return false unless(switches[c.switch1_id])
    end
    if c.switch2_valid
      return false unless(switches[c.switch2_id])
    end
    if c.variable_valid
      return false if(variables[c.variable_id] < c.variable_value)
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if(self_switches[key] != true)
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless($game.party.has_item?(item))
    end
    if c.actor_valid
      actor = $game.actors[c.actor_id]
      return false unless($game.party.members.include?(actor))
    end
    return true
  end

end

#-inject gen_class_header 'Game::Interpreter'
class Game::Interpreter
  def ex_variable(id)
    _map.excache.variables[id] = yield _map.excache.variables[id]
  end

  def ex_switch(id)
    _map.excache.switches[id] = yield _map.excache.switches[id]
  end

  def ex_self_switch(map_id,event_id,switch_ch)
    key = [map_id,event_id,switch_ch]
    _map.excache.self_switches[key] = yield _map.excache.self_switches[key]
  end
end
#-inject gen_script_footer
