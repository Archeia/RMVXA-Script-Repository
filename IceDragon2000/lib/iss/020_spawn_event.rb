# ISS020 - Spawn Event 1.0
#==============================================================================#
# ** ISS - Spawn Event
#==============================================================================#
# ** Date Created  : 08/10/2011
# ** Date Modified : 08/10/2011
# ** Created By    : IceDragon
# ** For Game      : Kye-VX
# ** ID            : 020
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(1.9 or above)
#==============================================================================#
$simport.r 'iss/spawn_event', '1.0.0', 'Event Spawning' do |d|
  d.depend! 'forma', '~> 1.0'
  d.depend! 'iss/core', '>= 1.9'
end
#==============================================================================#
# ** ISS::SpawnEvent
#==============================================================================#
module ISS
  install_script(20, :map)
  module SpawnEvent
    CONFIG = Forma.configure('iss/spawn_event') do |config|
      config.default(:spawn_map, 2)
      config.default(:spawn_offset, 200)
    end

    def self.get_event(eid, map_id = $game_map.map_id)
      $game_map.get_event(CONFIG[:spawn_map], eid)
    end

    def self.spawn_event(eid)
      $game_map.spawn_event(get_event(eid))
    end

    def self.remove_event(eid)
      $game_map.remove_event(eid)
    end
  end
end

#==============================================================================#
# ** Spawner
#==============================================================================#
Spawner = ISS::SpawnEvent

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character
  def dead_event?
    false
  end

  def remove_sprite?
    false
  end
end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event
  #--------------------------------------------------------------------------#
  # * new-method :dead_event?
  #--------------------------------------------------------------------------#
  def dead_event?
    @erased && @remove_sprite
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_sprite?
  #--------------------------------------------------------------------------#
  def remove_sprite?
    @remove_sprite
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_this
  #--------------------------------------------------------------------------#
  def remove_this
    if $imported['ISS-PositionRegister']
      update_pos(:clear)
      @use_posreg = false
    end
    erase
    @remove_sprite = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_id
  #--------------------------------------------------------------------------#
  def set_id(new_id)
    @id = new_id
    @event.id = new_id
  end
end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map
  attr_accessor :new_events

  alias :iss020_gmm_initialize :initialize
  def initialize(*args, &block)
    @new_events ||= []
    iss020_gmm_initialize(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup
  #--------------------------------------------------------------------------#
  alias :iss020_gmm_setup :setup
  def setup(*args, &block)
    iss020_gmm_setup(*args, &block)
    (@new_events ||= []).clear
    @new_events.clear
  end

  #--------------------------------------------------------------------------#
  # * new-method :spawn_event
  #--------------------------------------------------------------------------#
  def spawn_event(rpgevr)
    event_id = ISS::SpawnEvent::CONFIG[:spawn_offset]
    while @events[event_id]
      event_id += 1
    end
    rpgev = rpgevr.clone
    rpgev.id = event_id
    event = Game_Event.new(self.map_id, rpgev)
    event.set_id(event_id)
    @events[event_id] = event
    @new_events << event if $scene.is_a?(Scene_Map)
    event
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_event
  #--------------------------------------------------------------------------#
  def remove_event(event_id)
    ev = @events[event_id]
    @events[event_id].remove_this
    @events[event_id] = nil
    @events.delete(event_id)
    ev
  end
end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss020_spm_initialize :initialize
  def initialize(*args, &block)
    $game_map.new_events.clear ; iss020_spm_initialize(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_characters
  #--------------------------------------------------------------------------#
  def update_characters
    @character_sprites = @character_sprites.reduce([]) do |result, sprite|
      sprite.update
      if sprite.character.remove_sprite?
        sprite.dispose
      else
        result << sprite
        result
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss020_spm_update :update
  def update(*args, &block)
    unless $game_map.new_events.empty?
      $game_map.new_events.each { |ev|
        @character_sprites << Sprite_Character.new( @viewport1, ev) }
      $game_map.new_events.clear
    end
    iss020_spm_update(*args, &block)
  end
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
