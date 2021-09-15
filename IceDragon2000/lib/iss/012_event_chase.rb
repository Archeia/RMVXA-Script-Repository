#encoding:UTF-8
# ISS012 - Event Chase
# // 06/05/2011
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  module MixIns::ISS012 ; end
end

#==============================================================================#
# ** ISS::Chase_Engine
#==============================================================================#
class ISS::Chase_Engine

  attr_accessor :parent
  attr_accessor :target
  attr_accessor :target_range
  attr_accessor :chase

  def initialize(parent, target = nil)
    @parent       = parent
    @target       = target
    @target_range = 6
    @normal_speed = nil
    @chase_speed  = 4
    @orgin_point  = ::ISS::Pos.new(@parent.x, @parent.y)
    @chase        = false
    @last_chase   = nil
    @last_target_xy  = ::ISS::Pos.new(0, 0)
  end

  def update
    return if @target.nil?()
    if distance_from(@parent.x, @parent.y, @target.x, @target.y) <= @target_range && !@target.chase_hidden
      start_chase() unless @chase
    else
      stop_chase() if @chase
    end
    if @last_chase != @chase
      @last_chase = @chase
      if @chase
        @parent.balloon_id = 1
        @parent.jump(0, 0)
        @target.animation_id = 2
      else
        @parent.balloon_id = 8
      end
    end
    if @chase
      @normal_speed ||= @parent.move_speed
      unless @parent.moving?() || (@last_target_xy.x != @target.x || @last_target_xy.y != @target.y)
        @parent.move_speed = @chase_speed
        #@parent.collision_ignore << @target
        @parent.move_toward_char(@target)
        #@parent.force_path(@target.x, @target.y, false, 0)
        #@parent.collision_ignore.delete(@target)
      end
    else
      if @normal_speed != nil
        @parent.move_speed = @normal_speed
        @normal_speed = nil
      end
      unless @parent.moving?()
        return_to_origin()
      end
    end
    @last_target_xy.set(*@target.pos_to_a)
  end

  def return_to_origin()
    @parent.force_path(@orgin_point.x, @orgin_point.y, false, 0)
  end

  def distance_from(x, y, x2, y2)
    return (x - x2).abs + (y - y2).abs
  end

  def start_chase()
    @chase = true
    @target.chase_list |= [@parent]
  end

  def stop_chase()
    @chase = false
    return_to_origin()
    @target.chase_list.delete(@target)
  end

end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  alias :iss012_gmp_setup :setup unless $@
  def setup(*args, &block)
    iss012_gmp_setup(*args, &block)
    $game_player.chase_list.clear()
  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  attr_accessor :chase_engine
  attr_accessor :move_speed
  attr_accessor :through
  attr_accessor :collision_ignore
  attr_accessor :chase_list
  attr_accessor :chase_hidden

  alias :iss012_gmc_initialize :initialize unless $@
  def initialize(*args, &block)
    iss012_gmc_initialize(*args, &block)
    @collision_ignore = []
    @chase_list = []
    @chase_hidden = false
  end

  def setup_chase(target)
    @chase_engine = ISS::Chase_Engine.new(self, target)
  end

  def erase_chase()
    @chase_engine = nil
  end

  alias :iss012_gc_update :update unless $@
  def update()
    @chase_engine.update unless @chase_engine.nil?()
    iss012_gc_update()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :collide_with_characters?
  #--------------------------------------------------------------------------#
  def collide_with_characters?(x, y)
    # Matches event position
    for event in $game_map.events_xy(x, y) - @collision_ignore
      unless event.through                          # Passage OFF?
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    if @priority_type == 1                          # Self is normal char
      for o in [$game_player, $game_map.boat, $game_map.ship] - @collision_ignore
        return true if o.pos_nt?(x, y)
      end
    end
    return false
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event

  #--------------------------------------------------------------------------#
  # * ISS Event Cache Setup
  #--------------------------------------------------------------------------#
  iss_cachedummies :event, 12

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss012_ge_setup :setup unless $@
  def setup(*args, &block)
    iss012_ge_setup(*args, &block)
    iss012_eventcache()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :erase
  #--------------------------------------------------------------------------#
  alias :iss012_ge_erase :erase unless $@
  def erase(*args, &block)
    iss012_ge_erase(*args, &block)
    erase_chase()
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss012_eventcache_start
  #--------------------------------------------------------------------------#
  def iss012_eventcache_start()
    erase_chase()
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss012_eventcache_check
  #--------------------------------------------------------------------------#
  def iss012_eventcache_check(comment)
    setup_chase($game_player) if comment.scan(/<chaser>/i).size > 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss012_eventcache_end
  #--------------------------------------------------------------------------#
  def iss012_eventcache_end()
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
