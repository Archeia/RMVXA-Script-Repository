#encoding:UTF-8
# ISS014 - SEE 1.2
#==============================================================================#
# ** ISS - SEE (Sub Event Engine)
#==============================================================================#
# ** Date Created  : 07/16/2011
# ** Date Modified : 08/10/2011
# ** Created By    : IceDragon
# ** For Game      : Code JIFZ
# ** ID            : 014
# ** Version       : 1.2
# ** Requires      : ISS000 - Core(1.1 or above), IST - MoreRubyStuff(1.4 or above)
#==============================================================================#
# // Event Comments - place these in event comments (D: yeah)
#==============================================================================#
# // <see: event_id>
# //   Will copy event (event_id) from the SEE map and use it as the Subevent.
# //
# // <see: event_id, map_id>
# //   Will copy event (event_id) from the map (map_id) and use it as the Subevent
# //
#==============================================================================#
($imported ||= {})["ISS-SEE"] = true
#==============================================================================#
# ** ISS::SEE
#==============================================================================#
module ISS
  install_script(14, :event)
  module SEE
    # // Sub Event Map
    SEE_MAP_ID = 11
    # // If the parent event is erased, should the subevent follow?
    ERASE_SUBEVENT = true
  end
end

#==============================================================================#
# ** ISS::REGEXP::ISS014
#==============================================================================#
module ISS
  module REGEXP
    module ISS014
      module EVENT
        SEE2 = /<(?:SEE|SUBEVENT|SUB EVENT|SUB_EVENT):[ ]*(\d+),[ ](\d+)>/i
        SEE1 = /<(?:SEE|SUBEVENT|SUB EVENT|SUB_EVENT):[ ]*(\d+)>/i
      end
    end
  end
end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :parent_event

  #--------------------------------------------------------------------------#
  # * alias-method :get_character
  #--------------------------------------------------------------------------#
  alias :iss014_gi_get_character :get_character unless $@
  def get_character(*args, &block)
    ev = self.parent_event.nil?() ? $game_map.events[@event_id] : self.parent_event()
    return iss014_gi_get_character(ev.refocus_id, &block) unless ev.refocus_id.nil?() unless ev.nil?()
    iss014_gi_get_character(*args, &block)
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * ISS Event Cache Setup
  #--------------------------------------------------------------------------#
  iss_cachedummies :event, 14

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  ERASE_SUBEVENT = ISS::SEE::ERASE_SUBEVENT

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :sub_event
  attr_accessor :disable_subevent
  attr_accessor :refocus_id
  attr_accessor :is_subevent
  attr_accessor :parent_event
  attr_accessor :interpreter

  #--------------------------------------------------------------------------#
  # * new-method :is_a_subsevent?
  #--------------------------------------------------------------------------#
  def is_a_subsevent?()
    return self.is_subevent()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss014_ge_setup :setup unless $@
  def setup(*args, &block)
    iss014_ge_setup(*args, &block)
    iss014_eventcache()
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_subevent_settings
  #--------------------------------------------------------------------------#
  def set_subevent_settings()
    self.disable_subevent = true
    self.is_subevent      = true
    self.interpreter.parent_event = self
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_sub_event
  #--------------------------------------------------------------------------#
  def setup_sub_event(ev_id, mp_id)
    ev = $game_map.get_event(mp_id, ev_id).deep_clone
    ev.pages.each { |p| p.trigger = 4 } # // Forced to Parallel
    @sub_event                  = Game_Event.new(@map_id, ev)
    @sub_event.set_subevent_settings()
    @sub_event.parent_event     = self
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss014_eventcache_start
  #--------------------------------------------------------------------------#
  def iss014_eventcache_start()
    @sub_event = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss014_eventcache_check
  #--------------------------------------------------------------------------#
  def iss014_eventcache_check(comment)
    case comment
    when ISS::REGEXP::ISS014::EVENT::SEE2
      setup_sub_event($1.to_i, $2.to_i)
    when ISS::REGEXP::ISS014::EVENT::SEE1
      setup_sub_event($1.to_i, ISS::SEE::SEE_MAP_ID)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss014_eventcache_end
  #--------------------------------------------------------------------------#
  def iss014_eventcache_end() ; end

  #--------------------------------------------------------------------------#
  # * alias-method :erase
  #--------------------------------------------------------------------------#
  alias :iss014_ge_erase :erase unless $@
  def erase(*args, &block)
    iss014_ge_erase(*args, &block)
    @sub_event.erase() unless @sub_event.nil?() unless self.disable_subevent() if ERASE_SUBEVENT
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss014_ge_update :update unless $@
  def update(*args, &block)
    iss014_ge_update(*args, &block)
    @sub_event.update() unless self.sub_event().nil?() unless self.disable_subevent()
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
