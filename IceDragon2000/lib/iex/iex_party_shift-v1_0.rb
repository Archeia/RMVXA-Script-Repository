#==============================================================================#
# ** IEX(Icy Engine Xelion) - Party Shift
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon
# ** Date Created  : 10/19/2010
# ** Date Modified : 11/10/2010
# ** Version       : 1.0
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
#  >.> This is a pretty nice script, perfect for dungeon crawling.
#  Anyway, this was orignally made for use with Yggdrasil, it adds the
#  ability to shift the party while on map.
#  There is also a party recovery feature.
#  While on map the parties hp and or mp will recover at a rate you set.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# IEX - Yggdrasil (Reccommended for)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# 10/20/2010 - V1.0 Finished Script
# 11/10/2010 - V1.0 Fixed up Header
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  This script will not work with YEZ - Party System.
#  YEZ - Party System LOCKS the party order.
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Party_Shift"] = true

#==============================================================================#
# ** IEX::PARTY_SHIFT
#------------------------------------------------------------------------------#
#==============================================================================#
module IEX
  module PARTY_SHIFT
#==============================================================================
#                           Start Customization
#------------------------------------------------------------------------------
#==============================================================================
    SHIFT_ANIMATION_ID = 381 # Animation played when shifting, set to nil if unused
    SHIFT_WAIT = 120         # Time between party shifts in frames
    SHIFT_IF_DEAD = true     # If first member is dead, should a shift occur
    SKIP_DEAD = true         # If shifting and a dead member is set, should it skip?
    MOVE_ON_SHIFT = true     # Should the player move when shifting, if true a step is down
    
    RECOVER_SHIFT  = true    # Should members of the party recover slowly
    RECOVER_ACTIVE = true    # Should the first member recover also
    RECOVER_HP     = true    # Should Hp Be recovered
    RECOVER_MP     = true    # Should Mp Be recovered
    RECOVER_DEAD   = false   # If dead, should they recover, this is not reccommended for ABS
    NO_RECOVER_MOVE= true    # If moving, the party will not recover
    RECOVER_PERCENT= 1       # Percentage to recover each time
    RECOVER_TIME   = 20      # In frames
    
    SHIFT_BUTTON_L = Input::L
    SHIFT_BUTTON_R = Input::R
#==============================================================================
#                           End Customization
#------------------------------------------------------------------------------
#==============================================================================     
  end
end

#==============================================================================#
# ** Game_System
#------------------------------------------------------------------------------#
#==============================================================================#
class Game_System
  
  attr_accessor :shift_recover_time
  
  alias iex_party_shift_gs_initialize initialize unless $@
  def initialize(*args)
    iex_party_shift_gs_initialize(*args)
    @shift_recover_time = 0
  end
  
end

#==============================================================================#
# ** Game_Party
#------------------------------------------------------------------------------#
#==============================================================================#
class Game_Party < Game_Unit
  
  def iex_party_shift
    @actors.push(@actors.shift)
  end
  
  def iex_party_unshift
    @actors.unshift(@actors.pop)
  end
  
  def iex_party_swap(actor_id)
  end
  
  def iex_party_shift_party_recover_percent(active_rec = false, percent = 0, hp_recover = true, mp_recover = false, dead_recover = true)
    for act in members
      unless active_rec
        next if act == members[0] 
      end          
      next if act.dead? and dead_recover == false 
      if hp_recover
        act.hp += [(percent * act.maxhp / 100).to_i, 1].max
      end  
      if mp_recover
        act.mp += [(percent * act.maxmp / 100).to_i, 1].max
      end  
    end 
  end
  
end

#==============================================================================#
# ** Game_Player
#------------------------------------------------------------------------------#
#==============================================================================#
class Game_Player < Game_Character
  
  attr_accessor :iex_shift_wait
  
  alias iex_party_shift_initialize initialize unless $@
  def initialize(*args)
    iex_party_shift_initialize(*args)
    @iex_shift_wait = 0
  end
  
  def can_perform_shift?
    return false if $game_map.interpreter.running?
    return false if $game_message.visible
    return true
  end
  
  alias iex_party_shift_update update unless $@
  def update(*args)
    iex_party_shift_update(*args)
    if $game_party.members[0] != nil
      if can_perform_shift?
        iex_perform_shift
      end  
      if IEX::PARTY_SHIFT::SHIFT_IF_DEAD
        if $game_party.members[0].dead? and not $game_party.all_dead?
          iex_party_shift
        end
      end  
    end 
  end
  
  def iex_perform_shift
    @iex_shift_wait -= 1 unless @iex_shift_wait == 0
    return unless @iex_shift_wait <= 0    
    if Input.trigger?(IEX::PARTY_SHIFT::SHIFT_BUTTON_R)
      iex_party_shift
      @iex_shift_wait = IEX::PARTY_SHIFT::SHIFT_WAIT
    elsif Input.trigger?(IEX::PARTY_SHIFT::SHIFT_BUTTON_L)
      iex_party_unshift
      @iex_shift_wait = IEX::PARTY_SHIFT::SHIFT_WAIT
    end

  end

  def iex_party_shift
    Sound.play_cursor
    if IEX::PARTY_SHIFT::SHIFT_ANIMATION_ID != nil
      @animation_id = IEX::PARTY_SHIFT::SHIFT_ANIMATION_ID
    end 
    iex_half_backward if IEX::PARTY_SHIFT::MOVE_ON_SHIFT
    $game_party.iex_party_shift 
    refresh
    iex_half_forward if IEX::PARTY_SHIFT::MOVE_ON_SHIFT
  end
  
  def iex_party_unshift
    Sound.play_cursor
    if IEX::PARTY_SHIFT::SHIFT_ANIMATION_ID != nil
      @animation_id = IEX::PARTY_SHIFT::SHIFT_ANIMATION_ID
    end  
    iex_half_backward if IEX::PARTY_SHIFT::MOVE_ON_SHIFT
    $game_party.iex_party_unshift
    refresh
    iex_half_forward if IEX::PARTY_SHIFT::MOVE_ON_SHIFT
  end
  
  #--------------------------------------------------------------------------
  # * Half Down
  #--------------------------------------------------------------------------
  def iex_half_down(turn_ok = true)
    turn_down if turn_ok
    @y = $game_map.round_y(@y + 0.5)
    @real_y = ((@y - 0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------
  # * Half Left
  #--------------------------------------------------------------------------
  def iex_half_left(turn_ok = true)
    turn_left if turn_ok
    @x = $game_map.round_x(@x-0.5)
    @real_x = ((@x+0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------
  # * Half Right
  #--------------------------------------------------------------------------
  def iex_half_right(turn_ok = true)
    turn_right if turn_ok
    @x = $game_map.round_x(@x+0.5)
    @real_x = ((@x-0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------
  # * Half Up
  #--------------------------------------------------------------------------
  def iex_half_up(turn_ok = true)
    turn_up if turn_ok
    @y = $game_map.round_y(@y-0.5)
    @real_y = ((@y+0.5)*256)
    @move_failed = false
  end
  
  #--------------------------------------------------------------------------
  # * Half Forward
  #--------------------------------------------------------------------------
  def iex_half_forward
    case @direction
    when 2;  iex_half_down
    when 4;  iex_half_left
    when 6;  iex_half_right
    when 8;  iex_half_up
    end
  end
  #--------------------------------------------------------------------------
  # * Half Backward
  #--------------------------------------------------------------------------
  def iex_half_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  iex_half_up
    when 4;  iex_half_right
    when 6;  iex_half_left
    when 8;  iex_half_down
    end
    @direction_fix = last_direction_fix
  end
  
end

#==============================================================================#
# ** Scene_Map
#------------------------------------------------------------------------------#
#==============================================================================#
class Scene_Map < Scene_Base
  
  alias iex_party_shift_anim_scm_update update unless $@
  def update(*args) 
    iex_party_shift_anim_scm_update(*args)       
    if IEX::PARTY_SHIFT::RECOVER_SHIFT 
      $game_system.shift_recover_time -= 1 unless $game_system.shift_recover_time == 0
      if $game_system.shift_recover_time == 0
        unless $game_message.visible 
          if $game_player.moving? and IEX::PARTY_SHIFT::NO_RECOVER_MOVE
            can_rec = false
          else
            can_rec = true
          end
          if can_rec 
            $game_party.iex_party_shift_party_recover_percent(IEX::PARTY_SHIFT::RECOVER_ACTIVE, IEX::PARTY_SHIFT::RECOVER_PERCENT, IEX::PARTY_SHIFT::RECOVER_HP, IEX::PARTY_SHIFT::RECOVER_MP, IEX::PARTY_SHIFT::RECOVER_DEAD)
            $game_system.shift_recover_time = IEX::PARTY_SHIFT::RECOVER_TIME
          end  
        end  
      end  
    end
  end
  
end

