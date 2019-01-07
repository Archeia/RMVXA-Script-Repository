###--------------------------------------------------------------------------###
#  Lockpick script                                                             #
#  Version 1.2                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by: Jesse120                                                       #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V.Alpha - 2.11.2012                                                         #
#   Wrote main script                                                          #
#  V1.0 - 2.12.2012                                                            #
#   Debbugged, polished, and documented script                                 #
#  V1.1 - 4.7.2012                                                             #
#   Modified so that breaking a pick is dependent on an in-game switch         #
#  V1.2 - 4.15.2012                                                            #
#   Added "Gold Lockpick"                                                      #
#   Added to Jesse's modification                                              #
#   Added "breaking locks"                                                     #
#   Slight cleanup and maintenance                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  New Scene entirely; should run with just about everything.                  #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is NOT plug and play and requires additional graphics and       #
#  several setting changes to work properly.  Please be sure you have          #
#  imported the required graphics before continuing.                           #
#                                                                              #
#  To use, place a script call in an event and use the following script call:  #
#    lockpick(x, y)                                                            #
#  Define "x" as a numeric value that represents the difficulty of the lock    #
#  where lower numbers are easier to pick.  It is recommended to only use      #
#  values ranging form 2-8 because 1 seems to be too easy and 9 seems to be    #
#  too hard.  The "y" argument is a little more complex.  "y" is simply the    #
#  variable that holds the "lock durability".  If "y" is defined, breaking a   #
#  pick will break the lock instead.  The durability of the lock will be       #
#  stored in variable "y" so that the player cannot leave the lock and return  #
#  with full durability.  If the variable contains a value of "0" when         #
#  lockpicking starts, the variable will be changed to the default durability  #
#  for picks.  A variable with the value -1 is considered a broken lock.       #
#  Note that even with a gold lockpick or with lockpick breaking disabled,     #
#  locks can still be broken.  To make a lock "unbreakable", set the variable  #
#  to a value lower than -100 as -1 to -99 are used to check breaking.         #
#                                                                              #
#  When a lock is picked, one of three different numbers will be returned in   #
#  pre-determined variable.  The numbers are as follows.                       #
#    1 - Returned if the player picks the lock.                                #
#    2 - Returned if the player cancels lockpicking.                           #
#    3 - Returned if the player breaks all their picks or has none.            #
#                                                                              #
#  The player must have at least one of a pre-determined item in order to      #
#  pick a lock.  The item is determined in the config section.                 #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP          #  Do not edit                                              #
module LOCKPICK    #   these two lines                                         #
#                                                                              #
###-----                                                                -----###
# The main game settings are below.  These include mose of the sound effects   #
# and variable settings in the script.                                         #
#                                                                              #
module SETTINGS  #  Do not edit this line                                      #
#                                                                              #
# The ID number of picks in the database.  The player must have a least 1      #
# lockpick in their inventory before they can pick locks.                      #
PICK_ITEM = 22 # Default = 22                                                  #
#                                                                              #
# These are the golden lockpick settings.  A golden lockpick will not break    #
# and is used by default if it is in the inventory.  It can be diabled if you  #
# do not want to use it.                                                       #
USE_G_PICK = true # Default = true                                             #
G_PICK_ITEM = 23  # Default = 23                                               #
#                                                                              #
# The variable that returns the result of lockpicking success.                 #
VARIABLE = 1 # Default = 1                                                     #
#                                                                              #
# The sound effect, volume, and pitch played when starting to pick a lock.     #
LOCK_SOUND = "Switch2" # Default = "Switch2"                                   #
LOCK_VOLUME = 60       # Default = 60                                          #
LOCK_PITCH = 110       # Default = 110                                         #
#                                                                              #
# The sound effect, volume, and pitch played when unlocking a lock.            #
UNLOCK_SOUND = "Key" # Default = "Key"                                         #
UNLOCK_VOLUME = 80   # Default = 80                                            #
UNLOCK_PITCH = 100   # Default = 100                                           #
#                                                                              #
# The sound effect, volume, and pitch played when breaking a pick.             #
BREAK_SOUND = "Sword2" # Default = "Sword2"                                    #
BREAK_VOLUME = 60      # Default = 60                                          #
BREAK_PITCH = 130      # Default = 130                                         #
#                                                                              #
# Determines the switch for breaking picks and the durability lockpicks have.  #
# Higher values in durability will take longer to break.  If the switch is     #
# turned on, picks can be broken.  If "BREAK_PICKS" is set to true, the        #
# switch is turned on by default.                                              #
BREAK_PICK_SWITCH = 1 # Default = 1                                            #
BREAK_PICKS = true    # Default = true                                         #
DURABILITY = 90       # Default = 90                                           #
#                                                                              #
# A dialog box can be drawn in the bottom left corner with the remaining       #
# picks in your possession.  Setting this to false will not show that box.     #
# You may also set the text to be shown in the box.                            #
SHOW_REMAINING = true    # Default = true                                      #
ITEM_NAME = "Lockpicks:" # Default = "Lockpicks:"                              #
#                                                                              #
end  #  Don't edit this line either.                                           #
#                                                                              #
###-----                                                                -----###
# The settings for the graphics are below.  Use these to specify the graphics  #
# used and the X and Y offsets from the middle of the screen.  Note that all   #
# graphics must exist in the "pictures" folder.                                #
#                                                                              #
module LOCK  #  Don't touch this line                                          #
#                                                                              #
# Settings for the lock graphic                                                #
X_OFFSET = 0     # Default = 0                                                 #
Y_OFFSET = 0     # Default = 0                                                 #
GRAPHIC = "Lock" # Default = "Lock"                                            #
#                                                                              #
end          #  Don't touch                                                    #
module PICK  #  these two lines                                                #
#                                                                              #
# Settings for the pick graphic.                                               #
X_OFFSET = 0     # Default = 0                                                 #
Y_OFFSET = 30    # Default = 0                                                 #
GRAPHIC = "Pick" # Default = "Pick"                                            #
#                                                                              #
end          #  Don't touch                                                    #
module KEY   #  these two lines                                                #
#                                                                              #
# Settings for the "key" graphic.                                              #
X_OFFSET = 0    # Default = 0                                                  #
Y_OFFSET = -20  # Default = 0                                                  #
GRAPHIC = "Key" # Default = "Key"                                              #
#                                                                              #
end  #  Don't touch                                                            #
end  #  these three                                                            #
end  #  lines                                                                  #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

$imported = {} if $imported == nil
$imported["CP_LOCKPICK"] = true

##-----
## Allows for ease of access to the script from an event.
##-----
class Game_Interpreter
  def lockpick(diffi, door = nil)
    $scene = Scene_Lockpick.new(diffi, door)
    @wait_count = 1
  end
end

##-----
## Draws the window for the number of remaining picks.
##-----
class Window_Picks < Window_Base
  def initialize
    super(0, 360, 160, WLH + 32)
    refresh
  end
  
  def draw_picks(value, x, y, width)
    pick_name = CP::LOCKPICK::SETTINGS::ITEM_NAME
    cx = contents.text_size(pick_name).width
    self.contents.font.color = normal_color
    self.contents.draw_text(x+cx+2, y, width-cx-2, WLH, value)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, pick_name)
  end

  def refresh
    self.contents.clear
    itemnum = CP::LOCKPICK::SETTINGS::PICK_ITEM
    draw_picks($game_party.item_number($data_items[itemnum]), 4, 0, 120)
  end
end


##-----
## The bread and butter of the script.
##-----
class Scene_Lockpick < Scene_Base
  
  ##-----
  ## Initialize scene.  Sets difficulty and number of picks available.
  ##-----
  def initialize(diffi, door = nil)
    @diffi = diffi
    @door = nil
    @door = $game_variables[door] unless door == nil
    @doorvar = door
    @door = CP::LOCKPICK::SETTINGS::DURABILITY if @door == 0
    @key_rotation = 0
    @pick_rotation = 90
    @zone = rand(90) * 2
    @wobble = 0
    @durability = CP::LOCKPICK::SETTINGS::DURABILITY
    @did_turn = false
    
    picksnum = CP::LOCKPICK::SETTINGS::PICK_ITEM
    gpicknum = CP::LOCKPICK::SETTINGS::G_PICK_ITEM
    usegp = CP::LOCKPICK::SETTINGS::USE_G_PICK
    @haspicks = true if $game_party.has_item?($data_items[picksnum])
    @haspicks = true if $game_party.has_item?($data_items[gpicknum]) and usegp
    @haspicks = false if @door == -1
  end
  
  ##-----
  ## Start scene.  Draws items on screen.
  ##-----
  def start
    super
    create_menu_background
    @picks_window = Window_Picks.new if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    @picks_window.z = 4 if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    create_lock
    create_key
    create_pick if @haspicks
    key_math
  end
  
  ##-----
  ## Terminate scene.  Removes drawn items.
  ##-----
  def terminate
    super
    dispose_menu_background
    @picks_window.dispose if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    @lock_sprite.dispose
    @key_sprite.dispose
    @pick_sprite.dispose if @haspicks
  end
  
  ##-----
  ## Update scene.  Calls the scene's flesh and blood.
  ##-----
  def update
    super
    update_pick_command
    update_key_position
    update_pick_position if @haspicks
  end
  
  ##-----
  ## Draws the lock at the start of the scene.
  ##-----
  def create_lock
    @lock_sprite = Sprite.new(@viewport1)
    @lock_sprite.bitmap = Cache.picture(CP::LOCKPICK::LOCK::GRAPHIC)
    @lock_sprite.ox = @lock_sprite.width/2
    @lock_sprite.oy = @lock_sprite.height/2
    @lock_sprite.x = Graphics.width/2 + CP::LOCKPICK::LOCK::X_OFFSET
    @lock_sprite.y = Graphics.height/2 + CP::LOCKPICK::LOCK::Y_OFFSET
    @lock_sprite.z = 1
  end
  
  ##-----
  ## Draws the key at the start of the scene.
  ##-----
  def create_key
    @key_sprite = Sprite.new(@viewport1)
    @key_sprite.bitmap = Cache.picture(CP::LOCKPICK::KEY::GRAPHIC)
    @key_sprite.ox = @key_sprite.width/2
    @key_sprite.oy = @key_sprite.height/2
    @key_sprite.x = Graphics.width/2 + CP::LOCKPICK::KEY::X_OFFSET
    @key_sprite.y = Graphics.height/2 + CP::LOCKPICK::KEY::Y_OFFSET
    @key_sprite.z = 3
    @k_rotate = @key_rotation
    @key_sprite.angle = @k_rotate * -1
  end
  
  ##-----
  ## Updates the rotation of the key each frame.
  ##-----
  def update_key_position
    return if @key_rotation == @k_rotate
    @k_rotate = @key_rotation
    @key_sprite.angle = @k_rotate * -1
  end
  
  ##-----
  ## Draws the pick at the start of the scene.
  ##-----
  def create_pick
    @pick_sprite = Sprite.new(@viewport1)
    @pick_sprite.bitmap = Cache.picture(CP::LOCKPICK::PICK::GRAPHIC)
    @pick_sprite.ox = @pick_sprite.width/2
    @pick_sprite.oy = @pick_sprite.width/2
    @pick_sprite.x = Graphics.width/2 + CP::LOCKPICK::PICK::X_OFFSET
    @pick_sprite.y = Graphics.height/2 + CP::LOCKPICK::PICK::Y_OFFSET
    @pick_sprite.z = 2
    @p_rotate = @pick_rotation
    @pick_sprite.angle = @p_rotate - 90
  end
  
  ##-----
  ## Updates the rotation of the pick each frame.
  ##-----
  def update_pick_position
    return if @pick_rotation == @p_rotate and @wobble == @shake
    @p_rotate = @pick_rotation
    @shake = @wobble
    @pick_sprite.angle = @p_rotate - 90 + @shake
  end
  
  ##-----
  ## Quick thing to make the wait method work I guess.
  ##-----
  def update_basic
    Graphics.update
    Input.update
  end
  
  ##-----
  ## Aforementioned wait method.
  ##-----
  def wait(dur)
    for i in 0...dur
      update_basic
    end
  end
  
  ##-----
  ## Method called when lock is picked successfully.
  ##-----
  def lock_picked
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 1
    update_key_position
    wait(20)
    picking_end
  end
  
  ##-----
  ## Method called when lockpicking is cancelled.
  ##-----
  def lock_stopped
    Sound.play_cancel
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 2
    picking_end
  end
  
  ##-----
  ## Method called when lockpicking is failed.
  ##-----
  def no_picks
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 3
    picking_end
  end
  
  ##-----
  ## End method that returns to the map.
  ##-----
  def picking_end
    $scene = Scene_Map.new
  end
  
  ##-----
  ## Method containing all the key commands and input.
  ##-----
  def update_pick_command
    if Input.trigger?(Input::B) ##----- Cancel
      lock_stopped
    elsif Input.trigger?(Input::C) ##----- Key turning input
      @did_turn = true
      if @haspicks
        lsnd = CP::LOCKPICK::SETTINGS::LOCK_SOUND
        lvol = CP::LOCKPICK::SETTINGS::LOCK_VOLUME
        lpit = CP::LOCKPICK::SETTINGS::LOCK_PITCH
        Audio.se_play("Audio/SE/" + lsnd, lvol, lpit)
      else
        no_picks
      end
    elsif Input.press?(Input::C) and @did_turn
      unless @key_rotation > @max_turn - 2
        @key_rotation += 2 
      else
        pick_dura
      end
      if @key_rotation == 90
        lsnd = CP::LOCKPICK::SETTINGS::UNLOCK_SOUND
        lvol = CP::LOCKPICK::SETTINGS::UNLOCK_VOLUME
        lpit = CP::LOCKPICK::SETTINGS::UNLOCK_PITCH
        Audio.se_play("Audio/SE/" + lsnd, lvol, lpit)
        lock_picked
      end
    else ##----- Lockpick movement below
      @wobble = 0 unless @wobble == 0
      @key_rotation -= 2 unless @key_rotation == 0
      @key_rotation = 0 if @key_rotation < 0
      if Input.press?(Input::RIGHT)
        @pick_rotation += 2 unless @pick_rotation == 180
        key_math
      elsif Input.press?(Input::LEFT)
        @pick_rotation -= 2 unless @pick_rotation == 0
        key_math
      end
    end
  end
  
  ##-----
  ## Calculates the math allowing the key to turn.
  ##-----
  def key_math
    if ((@zone-4)..(@zone+4)) === @pick_rotation
      @max_turn = 90
    else
      check_spot = @pick_rotation - @zone
      check_spot *= -1 if check_spot < 0
      check_spot -= 4
      check_spot *= @diffi
      @max_turn = 90 - check_spot
      @max_turn = 0 if @max_turn < 0
    end
  end
  
  ##-----
  ## Checks the pick's durability with each step.
  ##-----
  def pick_dura
    @wobble = rand(5) - 2
    if @door != nil
      @door -= @diffi
      snap_pick if @door < 1 and @door > -100
    elsif $game_switches[CP::LOCKPICK::SETTINGS::BREAK_PICK_SWITCH]
      gpicknum = CP::LOCKPICK::SETTINGS::G_PICK_ITEM
      usegp = CP::LOCKPICK::SETTINGS::USE_G_PICK
      unless $game_party.has_item?($data_items[gpicknum]) and usegp
        @durability -= @diffi
        snap_pick if @durability < 1
      end
    end
  end
  
  ##-----
  ## Snaps the pick if durability is 0 or lower.
  ##-----
  def snap_pick
    lsnd = CP::LOCKPICK::SETTINGS::BREAK_SOUND
    lvol = CP::LOCKPICK::SETTINGS::BREAK_VOLUME
    lpit = CP::LOCKPICK::SETTINGS::BREAK_PITCH
    Audio.se_play("Audio/SE/" + lsnd, lvol, lpit)
    for i in 0...5
      @pick_sprite.y += 3
      update_basic
    end
    wait(10)
    unless @door == nil
      @door = -1 if @door < 1
      return no_picks
    end
    change_pick
  end
  
  ##-----
  ## Removes a pick and prepares to change it.
  ##-----
  def change_pick
    itemnum = CP::LOCKPICK::SETTINGS::PICK_ITEM
    $game_party.lose_item($data_items[itemnum], 1)
    @picks_window.refresh if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    unless $game_party.has_item?($data_items[itemnum]) and @door != -1
      no_picks
    else
      new_pick
    end
  end
  
  ##-----
  ## Places a new pick if one is present.
  ##-----
  def new_pick
    @key_rotation = 0
    @pick_rotation = 90
    @wobble = 0
    @durability = CP::LOCKPICK::SETTINGS::DURABILITY
    @pick_sprite.dispose
    create_pick
    update_key_position
    wait(10)
  end
  
end

class Scene_Title < Scene_Base
  alias cp_lp_create_game_objects create_game_objects unless $@
  def create_game_objects
    cp_lp_create_game_objects
    onoroff = CP::LOCKPICK::SETTINGS::BREAK_PICKS
    $game_switches[CP::LOCKPICK::SETTINGS::BREAK_PICK_SWITCH] = onoroff
  end
end

##----------------------------------------------------------------------------##
##  END OF SCRIPT                                                             ##
##----------------------------------------------------------------------------##