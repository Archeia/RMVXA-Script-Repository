=begin
#===============================================================================
 Title: Free Formation
 Author: Hime
 Date: May 11, 2013
--------------------------------------------------------------------------------
 ** Change log
 May 11
   - fixed crashing issue when selecting an empty slot
 Jan 30
   - added support for position setting and locking through script calls
 Jan 29, 2013
   - Initial release
--------------------------------------------------------------------------------
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script extends the party formation system to allow customized member
 positioning. You can now arrange your actors however you wish (almost).
 
--------------------------------------------------------------------------------
 ** Usage
 
 Script calls are available to perform formation-related operations.
 
   lock_actor_position(actor_id)
     - locks the specified actor's position
   
   unlock_actor_position(actor_id)
     - unlocks specified actor's position
   
   set_actor_position(actor_id, index)
     - Sets the position of the specified actor
     - index is 1-based, so 1 is the first position in the party

#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_FreeFormation"] = true
#===============================================================================
# ** Rest of the script
#===============================================================================
class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Lock the actor's position
  #-----------------------------------------------------------------------------
  def lock_actor_position(actor_id)
    $game_actors[actor_id].lock_position(true)
  end
  
  #-----------------------------------------------------------------------------
  # Unlock the actor's position
  #-----------------------------------------------------------------------------
  def unlock_actor_position(actor_id)
    $game_actors[actor_id].lock_position(false)
  end
  
  #-----------------------------------------------------------------------------
  # Set the actor's position. Basically a scripted swap.
  # Note that 1 is the first position.
  #-----------------------------------------------------------------------------
  def set_actor_position(actor_id, index)
    $game_party.set_position(actor_id, index-1)
  end
end

class Game_Actor < Game_Battler
  
  attr_reader :position_locked  # boolean indicating whether actor position is locked
  attr_reader :back_row         # 
  
  alias :th_change_rows_init :initialize
  def initialize(actor_id)
    th_change_rows_init(actor_id)
    @back_row = false
  end
  
  #-----------------------------------------------------------------------------
  # Index based on position in unit
  #-----------------------------------------------------------------------------
  def index
    $game_party.positions.index(@actor_id)
  end
  
  def position_locked?
    @position_locked
  end
  
  def lock_position(locked=true)
    @position_locked = locked
  end
  
  def back_row?
    return @back_row
  end
  
  def change_row
    @back_row = !@back_row
  end
end

class Game_Party < Game_Unit
  
  attr_reader :positions     # stores formation information for the party
  attr_reader :menu_actor_id
  
  alias :th_free_formation_init :initialize
  def initialize
    th_free_formation_init
    @positions = []
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Return based on positions
  #-----------------------------------------------------------------------------
  def battle_members
    @positions[0, max_battle_members].collect {|id| id && $game_actors[id] }.compact
  end
  
  def member_at_position(index)
    return @positions[index] ? $game_actors[@positions[index]] : nil
  end
  
  #-----------------------------------------------------------------------------
  # New. Assume there is always enough room to move all but one actor
  # into reserve
  #-----------------------------------------------------------------------------
  def party_size
    @actors.size + 3
  end
  
  #-----------------------------------------------------------------------------
  # New. Return first empty slot
  #-----------------------------------------------------------------------------
  def empty_slot
    @positions.index {|i| i.nil?} || @positions.size
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_free_formation_setup_start_members :setup_starting_members
  def setup_starting_members
    th_free_formation_setup_start_members
    @actors.each {|id| add_actor_position(id)}
  end

  #-----------------------------------------------------------------------------
  # Overwrite. Update positions rather than actor list
  #-----------------------------------------------------------------------------
  def swap_order(index1, index2)
    @positions[index1], @positions[index2] = @positions[index2], @positions[index1]
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # Add actor to positions
  #--------------------------------------------------------------------------
  alias :th_free_formation_add_actor :add_actor
  def add_actor(actor_id)
    add_actor_position(actor_id) unless @actors.include?(actor_id)
    th_free_formation_add_actor(actor_id)
  end
  #--------------------------------------------------------------------------
  # Remove from positions
  #--------------------------------------------------------------------------
  alias :th_free_formation_remove_actor :remove_actor
  def remove_actor(actor_id)
    delete_actor_position(actor_id)
    th_free_formation_remove_actor(actor_id)
  end

  #--------------------------------------------------------------------------
  # Overwrite. Used for error checks
  #--------------------------------------------------------------------------
  def menu_actor=(actor)
    @menu_actor_id = actor ? actor.id : 0
  end
  
  #--------------------------------------------------------------------------
  # New. Add actor ID to positions
  #--------------------------------------------------------------------------
  def add_actor_position(actor_id)
    @positions[empty_slot] = actor_id
  end
  
  #--------------------------------------------------------------------------
  # New. Remove actor ID to positions
  #--------------------------------------------------------------------------
  def delete_actor_position(actor_id)
    @positions.delete(actor_id)
  end
  
  #--------------------------------------------------------------------------
  # Forcefully set the position of an actor in the party, assuming actor
  # exists. If another actor exists at that position, then they will be
  # swapped.
  #--------------------------------------------------------------------------
  def set_position(actor_id, index)
    return unless @actors.include?(actor_id)
    swap_order($game_actors[actor_id].index, [index, party_size].min)
  end
end

#-------------------------------------------------------------------------------
# All changes based on default menu scene. Custom systems may require their
# own changes
#-------------------------------------------------------------------------------
class Window_MenuStatus < Window_Selectable
  
  #--------------------------------------------------------------------------
  # Based on positions, not member count
  #--------------------------------------------------------------------------
  def item_max
    $game_party.party_size
  end
  
  #--------------------------------------------------------------------------
  # Overwrite. Draw based on position
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor_id = $game_party.positions[index]
    return unless actor_id
    actor = $game_actors[actor_id]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    #if actor.back_row?
    #  draw_actor_face(actor, rect.x + 20, rect.y + 1, enabled)
    #else
    #  draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled)
    #end
    draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled)
    draw_actor_simple_status(actor, rect.x + 108, rect.y + line_height / 2)
  end
  
  #--------------------------------------------------------------------------
  # Overwrite. Need to store menu actor first for error checks
  #--------------------------------------------------------------------------
  def process_ok
    $game_party.menu_actor = $game_party.member_at_position(index)
    super
  end
end

class Scene_Menu < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # Empty spots should buzzer
  #--------------------------------------------------------------------------
  alias :th_free_formation_on_personal_ok :on_personal_ok
  def on_personal_ok
    if $game_party.menu_actor_id == 0
      @status_window.activate
      Sound.play_buzzer
      return
    end
    th_free_formation_on_personal_ok
  end
  
  #--------------------------------------------------------------------------
  # Selecting a position-locked actor is disallowed
  #--------------------------------------------------------------------------
  alias :th_free_formation_on_formation_ok :on_formation_ok
  def on_formation_ok
    actor = $game_party.member_at_position(@status_window.index)
    if actor.nil?
      th_free_formation_on_formation_ok
    elsif actor.position_locked?
      @status_window.activate
      Sound.play_buzzer
    elsif @status_window.pending_index == @status_window.index
      actor.change_row
      @status_window.pending_index = -1
      @status_window.redraw_item(@status_window.index)
      @status_window.activate
    else
      th_free_formation_on_formation_ok
    end
  end
end

class Window_BattleStatus < Window_Selectable
  def item_max
    $game_party.max_battle_members
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.member_at_position(index)
    return unless actor
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
end