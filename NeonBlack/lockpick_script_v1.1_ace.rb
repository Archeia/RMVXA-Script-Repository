##----------------------------------------------------------------------------##
## Lockpicking Script v1.1
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.1 - 3.3.2013
##  Cleanup and debug for official Ace release
## v1.0 - 9.11.2012
##  Converted from VX script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_LOCKPICK"] = 1.1                                                ##
                                                                              ##
##----------------------------------------------------------------------------##
##     VXA Notes:
## This is the VXA version of my lockpicking script ported from VX.  There were
## a few modifications made to allow it to run properly, however the script
## remains mostly unchanged.
##
##     Instructions:
## Place this script in the "Materials" section of the scripts above main.
## This script is NOT plug and play and requires additional graphics and
## several setting changes to work properly.  Please be sure you have imported
## the required graphics before continuing.
##
## To use, place a script call in an event and use the following script call:
##
##   Lockpick.start(x[, y])
## Define "x" as a numeric value that represents the difficulty of the lock
## where lower numbers are easier to pick.  It is recommended to only use
## values ranging form 2-8 because 1 seems to be too easy and 9 seems to be too
## hard.  The "y" argument is a little more complex but is completely optional.
## "y" is simply the variable that holds the "lock durability".  If "y" is
## defined, breaking a pick will break the lock instead.  The durability of the
## lock will be stored in variable "y" so that the player cannot leave the lock
## and return with full durability.  If the variable contains a value of "0"
## when lockpicking starts, the variable will be changed to the default
## durability for picks.  A variable with the value -1 is considered a broken
## lock.  Note that even with a gold lockpick or with lockpick breaking
## disabled, locks can still be broken.  To make a lock "unbreakable", set the
## variable to a value lower than -100 as -1 to -99 are used to check breaking
##
## When a lock is picked, one of three different numbers will be returned in
## pre-determined variable.  The numbers are as follows.
##   1 - Returned if the player picks the lock.
##   2 - Returned if the player cancels lockpicking.
##   3 - Returned if the player breaks all their picks or has none.
##
## The player must have at least one of a pre-determined item in order to pick
## a lock.  The item is determined in the config section.
##----------------------------------------------------------------------------##
                                                                              ##
module CP       # Do not touch                                                ##
module LOCKPICK #  these lines.                                               ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# The main game settings are below.  These include mose of the sound effects and
# variable settings in the script.
module SETTINGS

# The ID number of picks in the database.  The player must have a least 1
# lockpick in their inventory before they can pick locks.
PICK_ITEM = 22

# These are the golden lockpick settings.  A golden lockpick will not break and
# is used by default if it is in the inventory.  It can be diabled if you do not
# want to use it.
USE_G_PICK = false
G_PICK_ITEM = 23

# The variable that returns the result of lockpicking success.
VARIABLE = 1

# The sound effect, volume, and pitch played when starting to pick a lock.
LOCK_SOUND = "Switch2"
LOCK_VOLUME = 60
LOCK_PITCH = 110

# The sound effect, volume, and pitch played when unlocking a lock.
UNLOCK_SOUND = "Key"
UNLOCK_VOLUME = 80
UNLOCK_PITCH = 100

# The sound effect, volume, and pitch played when breaking a pick.
BREAK_SOUND = "Sword2"
BREAK_VOLUME = 60
BREAK_PITCH = 130

# Determines the switch for breaking picks and the durability lockpicks have.
# Higher values in durability will take longer to break.  If the switch is
# turned on, picks can be broken.  If "BREAK_PICKS" is set to true, the switch
# is turned on by default.
BREAK_PICK_SWITCH = 1
BREAK_PICKS = true
DURABILITY = 90

# A dialog box can be drawn in the bottom left corner with the remaining picks
# in your possession.  Setting this to false will not show that box.  You may
# also set the text to be shown in the box.
SHOW_REMAINING = true
ITEM_NAME = "Lockpicks:"

end
##------
# The settings for the graphics are below.  Use these to specify the graphics
# used and the X and Y offsets from the middle of the screen.  Note that all
# graphics must exist in the "pictures" folder.
module LOCK

# Settings for the lock graphic.
X_OFFSET = 0
Y_OFFSET = 0
GRAPHIC = "Lock"

end
module PICK

# Settings for the pick graphic.
X_OFFSET = 0
Y_OFFSET = 30
GRAPHIC = "Pick"

end
module KEY

# Settings for the "key" graphic.
X_OFFSET = 0
Y_OFFSET = -20
GRAPHIC = "Key"

end
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end
end

class Window_Picks < Window_Base
  def initialize
    super(0, Graphics.height - fitting_height(1), 160, fitting_height(1))
    refresh
  end
  
  def draw_picks(value, x, y, width)
    pick_name = CP::LOCKPICK::SETTINGS::ITEM_NAME
    cx = contents.text_size(pick_name).width
    self.contents.font.color = normal_color
    self.contents.draw_text(x+cx+2, y, width-cx-2, 24, value)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, 24, pick_name)
  end

  def refresh
    self.contents.clear
    itemnum = CP::LOCKPICK::SETTINGS::PICK_ITEM
    draw_picks($game_party.item_number($data_items[itemnum]), 4, 0,
               contents.width - 8)
  end
end

class Lockpick < Scene_MenuBase
  def self.start(diffi, door_var = nil)
    SceneManager.call(Lockpick)
    SceneManager.scene.prepare(diffi, door_var)
    Fiber.yield
  end
  
  def prepare(diffi, door_var)
    @diffi = diffi
    @door = $game_variables[door_var] unless door_var.nil?
    @doorvar = door_var
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
  
  def start ## Start scene.  Draws items on screen.
    super
    @picks_window = Window_Picks.new if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    @picks_window.z = 4 if @picks_window
    create_lock
    create_key
    create_pick if @haspicks
    key_math
  end
  
  def terminate
    super
    @lock_sprite.dispose
    @key_sprite.dispose
    @pick_sprite.dispose if @pick_sprite
  end
  
  def update
    super
    update_pick_command
    update_key_position
    update_pick_position if @haspicks
  end
  
  def create_lock
    @lock_sprite = Sprite.new
    @lock_sprite.bitmap = Cache.picture(CP::LOCKPICK::LOCK::GRAPHIC)
    @lock_sprite.ox = @lock_sprite.width/2
    @lock_sprite.oy = @lock_sprite.height/2
    @lock_sprite.x = Graphics.width/2 + CP::LOCKPICK::LOCK::X_OFFSET
    @lock_sprite.y = Graphics.height/2 + CP::LOCKPICK::LOCK::Y_OFFSET
    @lock_sprite.z = 1
  end
  
  def create_key
    @key_sprite = Sprite.new
    @key_sprite.bitmap = Cache.picture(CP::LOCKPICK::KEY::GRAPHIC)
    @key_sprite.ox = @key_sprite.width/2
    @key_sprite.oy = @key_sprite.height/2
    @key_sprite.x = Graphics.width/2 + CP::LOCKPICK::KEY::X_OFFSET
    @key_sprite.y = Graphics.height/2 + CP::LOCKPICK::KEY::Y_OFFSET
    @key_sprite.z = 3
    @k_rotate = @key_rotation
    @key_sprite.angle = @k_rotate * -1
  end
  
  def update_key_position
    return if @key_rotation == @k_rotate
    @k_rotate = @key_rotation
    @key_sprite.angle = @k_rotate * -1
  end
  
  def create_pick
    @pick_sprite = Sprite.new
    @pick_sprite.bitmap = Cache.picture(CP::LOCKPICK::PICK::GRAPHIC)
    @pick_sprite.ox = @pick_sprite.width/2
    @pick_sprite.oy = @pick_sprite.width/2
    @pick_sprite.x = Graphics.width/2 + CP::LOCKPICK::PICK::X_OFFSET
    @pick_sprite.y = Graphics.height/2 + CP::LOCKPICK::PICK::Y_OFFSET
    @pick_sprite.z = 2
    @p_rotate = @pick_rotation
    @pick_sprite.angle = @p_rotate - 90
  end
  
  def update_pick_position
    return if @pick_rotation == @p_rotate and @wobble == @shake
    @p_rotate = @pick_rotation
    @shake = @wobble
    @pick_sprite.angle = @p_rotate - 90 + @shake
  end
    
  def wait(dur)
    for i in 0...dur
      update_basic
    end
  end
  
  def lock_picked
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 1
    update_key_position
    wait(20)
    picking_end
  end
  
  def lock_stopped
    Sound.play_cancel
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 2
    picking_end
  end
  
  def no_picks
    variable = CP::LOCKPICK::SETTINGS::VARIABLE
    $game_variables[@doorvar] = @door unless @door == nil
    $game_variables[variable] = 3
    picking_end
  end
  
  def picking_end
    SceneManager.return
  end
  
  def update_pick_command
    if Input.trigger?(:B) ##----- Cancel
      lock_stopped
    elsif Input.trigger?(:C) ##----- Key turning input
      @did_turn = true
      if @haspicks
        lsnd = CP::LOCKPICK::SETTINGS::LOCK_SOUND
        lvol = CP::LOCKPICK::SETTINGS::LOCK_VOLUME
        lpit = CP::LOCKPICK::SETTINGS::LOCK_PITCH
        Audio.se_play("Audio/SE/" + lsnd, lvol, lpit)
      else
        no_picks
      end
    elsif Input.press?(:C) and @did_turn
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
      if Input.press?(:RIGHT)
        @pick_rotation += 2 unless @pick_rotation == 180
        key_math
      elsif Input.press?(:LEFT)
        @pick_rotation -= 2 unless @pick_rotation == 0
        key_math
      end
    end
  end
  
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
  
  def pick_dura  ## Checks the pick's durability with each step.
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
  
  def snap_pick  ## Snaps the pick if durability is 0 or lower.
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
  
  def change_pick  ## Removes a pick and prepares to change it.
    itemnum = CP::LOCKPICK::SETTINGS::PICK_ITEM
    $game_party.lose_item($data_items[itemnum], 1)
    @picks_window.refresh if CP::LOCKPICK::SETTINGS::SHOW_REMAINING
    unless $game_party.has_item?($data_items[itemnum]) and @door != -1
      no_picks
    else
      new_pick
    end
  end
  
  def new_pick  ## Places a new pick if one is present.
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

module DataManager
  class << self
    alias :cp_lockpick_cgo :create_game_objects
  end
  
  def self.create_game_objects
    cp_lockpick_cgo
    onoroff = CP::LOCKPICK::SETTINGS::BREAK_PICKS
    $game_switches[CP::LOCKPICK::SETTINGS::BREAK_PICK_SWITCH] = onoroff
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###