#==============================================================================#
# ** IEX(Icy Engine Xelion) - Map Jumps
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Screen)
# ** Script Type   : Camera Movement
# ** Date Created  : 01/03/2011 (DD/MM/YYYY)
# ** Date Modified : 08/02/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Map Jumps
# ** Difficulty    : Easy
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script was ported from its older version, most methods remain intact.
# This script adds some new features to your camera movement.
# You can jump to a location, jump to an event, follow an event.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW_TO_USE
#------------------------------------------------------------------------------#
# V1.0 - Script Calls - Use in event script call
#------------------------------------------------------------------------------#
# map_jump_to( fades, x, y )
#
# This will center the screen on the given X, Y coords
# Fades is no longer a Boolean, instead its now an integer
#   0 no transition
#   1 transition
#   2 fade
# eg. map_jump_to( 0, 12, 27 )
# The screen will jump to and center on the (x 12, y 27)
# To have it center back on the player just call
# map_jump_to
# This will center the screen back on the player
#
#------------------------------------------------------------------------------#
# map_jump_to_event( event, fades )
#
# This will jump to a event and center the screen on it.
# Fades is no longer a Boolean, instead its now an integer
#   0 no transition
#   1 transition
#   2 fade
# true nothing will happen anyway..
#   -1 for player (basically works the same as calling map_jump_to)
#    0 for current event
#    1 and above for other events
# eg. map_jump_to_event(99, 1)
# This will center on event 99
#
#------------------------------------------------------------------------------#
# map_event_scroll(active, event)
#
# This causes the Screen to scroll with an event (Just like how it scrolls with
# the player)
# active is a switch while true it will scroll with the event
# while false the screen will remain in its current position
#   -1 for player (basically works the same as calling map_jump_to)
#    0 for current event
#    1 and above for other events
# eg. map_event_scroll(true, 99)
# This will scroll with event 99
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Should have no problems
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
#
# Below
#  Materials
#  Anything that makes changes to the Scene_Map Initialize.
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#------------------------------------------------------------------------------#
# Classes
#   Game_Interpreter
#     new-method :map_jump_to
#     new-method :map_jump_to_event
#     new-method :map_event_scroll
#   Game_Player
#     new-method :iex_map_jump_to
#     new-method :iex_center_on_target
#   Spriteset_Map
#     new-method :force_update_characters
#   Scene_Map
#     alias      :initialize
#     alias      :update
#     new-method :iex_scroll_target_setup
#     new-method :iex_update_scroll
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  01/03/2011 - V1.0  Ported to IEX
#  01/08/2011 - V1.0a Small Changes
#  08/02/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
#==============================================================================#
$imported ||= {}
$imported["IEX_MapJumps"] = true
#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :map_jump_to
  #--------------------------------------------------------------------------#
  def map_jump_to(fadez = 0, max = nil, may = nil)
    $game_player.iex_map_jump_to(max, may, fadez)
  end

  #--------------------------------------------------------------------------#
  # * new-method :map_jump_to_event
  #--------------------------------------------------------------------------#
  def map_jump_to_event(targetevent, fadezz = 0)
    $game_player.iex_center_on_target(targetevent, fadezz)
  end

  #--------------------------------------------------------------------------#
  # * new-method :map_event_scroll
  #--------------------------------------------------------------------------#
  def map_event_scroll(active, targetevent)
    if $scene.is_a?(Scene_Map)
      $scene.iex_scroll_target_setup(active, targetevent)
    end
  end

end

#==============================================================================#
# ** Game_Player
#==============================================================================#
class Game_Player < Game_Character

  #--------------------------------------------------------------------------#
  # * new-method :iex_map_jump_to
  #--------------------------------------------------------------------------#
  def iex_map_jump_to( max, may, fadez = 0 )
    if max == nil or may == nil
      max = self.x
      may = self.y
    end
    case fadez
    when 1 # Prepare Transition
      Graphics.freeze
    when 2 # Fade Out
      Graphics.fadeout(30)
      Graphics.wait(30)
    end
    center(max, may)
    $game_map.need_refresh = true
    $game_map.update
    if $scene.is_a?(Scene_Map)
      $scene.spriteset.update
      $scene.spriteset.force_update_characters
    end
    case fadez
    when 1 # Transition
      Graphics.transition( 30 )
    when 2 # Fade In
      Graphics.wait( 30 )
      Graphics.fadein( 30 )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_center_on_target
  #--------------------------------------------------------------------------#
  def iex_center_on_target( targetevent, fadez = 0 )
    emax = $game_map.events[targetevent].x
    emay = $game_map.events[targetevent].y
    iex_map_jump_to(emax, emay, fadez)
  end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * new-method :force_update_characters
  #--------------------------------------------------------------------------#
  def force_update_characters
    @character_sprites.each { |sprite| sprite.update }
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#==============================================================================
class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :spriteset

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :setup_event_target_scroll_initialize :initialize unless $@
  def initialize( *args, &block )
    setup_event_target_scroll_initialize( *args, &block )
    @event_target_scroll = nil
    @active_event_scroll = false
    @scrolled_event = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_scroll_target_setup
  #--------------------------------------------------------------------------#
  def iex_scroll_target_setup( active = false, tagert = nil )
    if tagert != nil and active != false
      @event_target_scroll = $game_map.events[tagert]
      @active_event_scroll = true
      $game_player.center(@event_target_scroll.x, @event_target_scroll.y)
      $game_map.need_refresh = true
      $game_map.update
      if $scene.is_a?(Scene_Map)
        $scene.spriteset.update
        $scene.spriteset.force_update_characters
      end
    elsif active == false
      @event_target_scroll = nil
    elsif tagert != nil and active == false
      @active_event_scroll = false
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iex_lock_event_scroll_update :update unless $@
  def update( *args, &block )
    if @event_target_scroll != nil and @active_event_scroll == true
      iexold_real_x = @event_target_scroll.real_x
      iexold_real_y = @event_target_scroll.real_y
      @scrolled_event = true
    end
    iex_lock_event_scroll_update( *args, &block )
    if @scrolled_event
      iex_update_scroll(iexold_real_x, iexold_real_y)
      @scrolled_event = false
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_update_scroll
  #--------------------------------------------------------------------------#
  def iex_update_scroll( last_real_x, last_real_y )
    return if @event_target_scroll == nil
    ax1 = $game_map.adjust_x( last_real_x )
    ay1 = $game_map.adjust_y( last_real_y )
    ax2 = $game_map.adjust_x( @event_target_scroll.real_x )
    ay2 = $game_map.adjust_y( @event_target_scroll.real_y )
    if ay2 > ay1 and ay2 > $game_player::CENTER_X
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < $game_player::CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > $game_player::CENTER_Y
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < $game_player::CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
