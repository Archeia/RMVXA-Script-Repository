# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Party Guests                                          │ v1.1 │ (7/13/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# This script allows you to have actors as guests in the party 
# similarly to various console RPGs. A custom window is added to the
# menu that displays current guests in the party.
#
# Party guests do not require special tags in their noteboxes. They are 
# simply actors put into a "guests" group within the party which is
# seperate from any of your battle or reserve members. Because of 
# this, guests are not eligible to be chosen for battle at all.
#
# Since guests are just glorified actors, names, face graphics, 
# sprite graphics, etc. are defined in the Actors tab in the database 
# like normal. Those settings are then used in various display windows 
# related to guests.
#
# Guests provide no special effects to the party. However, other existing 
# scripts can provide effects if desired.
#
# If an actor is already in the main party and is placed into the
# guest group, the actor will automatically be removed from the 
# main party. The same is true vice versa.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Fixed guest_in_party? Script Call. 
#      : Changed instance variable name for Guest ID array. (7/13/2012)
# v1.0 : Initial release. (6/25/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in "Script..." 
# event commands found under Tab 3 when creating a new event.
#
# add_guest(actor_id)
#   Adds an actor to the party guest group. If the actor is already in the
#   main party, the actor will automatically be removed from the main 
#   party before being added to the guest group.
#   
# remove_guest(actor_id)
#   Removes the actor from the guest group.
#
# remove_all_guests
#   Removes all actors from the guest group.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Conditional Branch Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in Conditional
# Branch event commands within the Tab 4 "Script" box.
# Each of these script calls will turn the given Game Switch ON
# or OFF, where ON is true and OFF is false.
#   
# guest_in_party?(actor_id)
#   Checks whether the given actor is a guest in the party.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     Game_Party#initialize
#     Game_Party#add_actor
#
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported = {} if $imported.nil?
$imported["BubsPartyGuests"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Party Guests Settings
  #==========================================================================
  module PartyGuests
    
  #--------------------------------------------------------------------------
  #   Guest Limit
  #--------------------------------------------------------------------------
  # The maximum number of guests that can accompany the party.
  #   !! Use caution when adding too many guests to the party since 
  #   !! the Guests window in the menu is not currently suited to handle
  #   !! a large amount of guests to display.
  MAX_GUESTS = 2

  #--------------------------------------------------------------------------
  #   Guest Window Label Text
  #--------------------------------------------------------------------------
  GUEST_WINDOW_TEXT = "Guests"
  #--------------------------------------------------------------------------
  #   Guest Window Display Style
  #--------------------------------------------------------------------------
  # Determines the style in which Guests are shown in the Guests window
  # 0 : Show Guest face portraits
  # 1 : Show Guest map sprites
  GUEST_WINDOW_STYLE = 0
  #--------------------------------------------------------------------------
  #   Hide Guest Window When No Guests
  #--------------------------------------------------------------------------
  # true  : The Guest window will be hidden when there are no guests
  # false : The Guest window will still be visible when there are no guests
  HIDE_WINDOW_WHEN_NO_GUESTS = false

  end # module PartyGuests
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==========================================================================
# ++ Game_Party
#==========================================================================
class Game_Party < Game_Unit
  attr_accessor :guest_ids
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_party_guests initialize
  def initialize
    initialize_bubs_party_guests # alias 
    
    @guest_ids = []
  end
    
  #--------------------------------------------------------------------------
  # new method : guests
  #--------------------------------------------------------------------------
  def guests
    @guest_ids.collect {|id| $game_actors[id] }
  end

  #--------------------------------------------------------------------------
  # new method : party_guests
  #--------------------------------------------------------------------------
  def party_guests
    @guest_ids
  end
  
  #--------------------------------------------------------------------------
  # new method : add_guest
  #--------------------------------------------------------------------------
  def add_guest(actor_id)
    return if @guest_ids.size >= max_guests
    return if @guest_ids.include?(actor_id)
    
    remove_actor(actor_id)
    @guest_ids.push(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  #--------------------------------------------------------------------------
  # new method : remove_guest
  #--------------------------------------------------------------------------
  def remove_guest(actor_id)
    @guest_ids.delete(actor_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  #--------------------------------------------------------------------------
  # alias : add_actor
  #--------------------------------------------------------------------------
  alias add_actor_bubs_party_guests add_actor
  def add_actor(actor_id)
    remove_guest(actor_id)
    add_actor_bubs_party_guests(actor_id) # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : max_guests
  #--------------------------------------------------------------------------
  def max_guests
    return Bubs::PartyGuests::MAX_GUESTS
  end
end # class Game_Party


#==========================================================================
# ++ Window_PartyGuests
#==========================================================================
class Window_PartyGuests < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  
  #--------------------------------------------------------------------------
  # height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(guest_window_height)
  end
  
  #--------------------------------------------------------------------------
  # new method : guest_window_height
  #--------------------------------------------------------------------------
  def guest_window_height
    fh = 1
    case Bubs::PartyGuests::GUEST_WINDOW_STYLE
    when 0
      fh = 1 + ($game_party.guest_ids.size * 2)
    when 1
      fh = $game_party.guest_ids.empty? ? 1 : 3
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_party_guest_text
    draw_party_guests
  end
  
  #--------------------------------------------------------------------------
  # new method : draw_party_guests
  #--------------------------------------------------------------------------
  def draw_party_guests
    case Bubs::PartyGuests::GUEST_WINDOW_STYLE
    when 0
      draw_party_guest_faces
    when 1
      draw_party_guest_graphics
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : draw_party_guest_faces
  #--------------------------------------------------------------------------
  def draw_party_guest_faces
    $game_party.guests.each_with_index { |actor, i| 
      draw_actor_half_face(actor, 20, 48 * i + line_height)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method : draw_party_guest_graphic
  #--------------------------------------------------------------------------
  def draw_party_guest_graphics
    $game_party.guests.each_with_index { |actor, i| 
      draw_actor_graphic(actor, 32 * i + 20, 24 * 3)
    }
  end
  
  #--------------------------------------------------------------------------
  # new method : draw_party_guest_text
  #--------------------------------------------------------------------------
  def draw_party_guest_text
    change_color(system_color)
    draw_text(0, 0, 160, line_height, Bubs::PartyGuests::GUEST_WINDOW_TEXT)
  end
  
  #--------------------------------------------------------------------------
  # new method : draw_actor_half_face
  #--------------------------------------------------------------------------
  def draw_actor_half_face(actor, x, y, enabled = true)
    draw_half_face(actor.face_name, actor.face_index, x, y, enabled)
  end

  #--------------------------------------------------------------------------
  # new method : draw_half_face
  #--------------------------------------------------------------------------
  def draw_half_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96 + 32, 96, 46)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  
  #--------------------------------------------------------------------------
  # open
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end # class Window_PartyGuests


#==========================================================================
# ++ Scene_Menu
#==========================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # alias : start
  #--------------------------------------------------------------------------
  alias start_bubs_party_guests start
  def start
    start_bubs_party_guests # alias
    
    create_guest_window
  end
  
  #--------------------------------------------------------------------------
  # new method : create_guest_window
  #--------------------------------------------------------------------------
  def create_guest_window
    return if $game_party.guests.empty? && Bubs::PartyGuests::HIDE_WINDOW_WHEN_NO_GUESTS
    
    @guest_window = Window_PartyGuests.new
    @guest_window.x = 0
    @guest_window.y = Graphics.height - @gold_window.height - @guest_window.height
  end
end # class Scene_Menu

#==========================================================================
# ++ Game_Actor
#==========================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # new method : guest?
  #--------------------------------------------------------------------------
  def guest?
    $game_party.guest_ids.include?(@actor_id)
  end
end # class Game_Actor

#==========================================================================
# ++ Game_BattlerBase
#==========================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # new method : guest?
  #--------------------------------------------------------------------------
  def guest?
    return false
  end
end # class Game_BattlerBase


#==========================================================================
# ++ Game_Interpreter
#==========================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : remove_all_guests
  #--------------------------------------------------------------------------
  def remove_all_guests
    $game_party.guest_ids.clear
  end
  alias remove_all_guest remove_all_guests
  
  #--------------------------------------------------------------------------
  # new method : add_guest
  #--------------------------------------------------------------------------
  def add_guest(actor_id)
    $game_party.add_guest(actor_id)
  end
  
  #--------------------------------------------------------------------------
  # new method : remove_guest
  #--------------------------------------------------------------------------
  def remove_guest(actor_id)
    $game_party.remove_guest(actor_id)
  end
  
  #--------------------------------------------------------------------------
  # new method : guest_in_party?
  #--------------------------------------------------------------------------
  def guest_in_party?(actor_id)
    $game_party.guest_ids.include?(actor_id)
  end
  alias has_guest? guest_in_party?
  alias have_guest? guest_in_party?
end # class Game_Interpreter