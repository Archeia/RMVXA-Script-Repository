if true # << Make false to disable script, true to enable. 
#===============================================================================
#
# ☆ Dekita - Resolution Setter
# -- Author   : Dekita
# -- Version  : 1.0
# -- Level    : Very Easy
# -- Requires : N/A
# -- Engine   : RPG Maker VX Ace.
#
#===============================================================================
# ☆ Import
#-------------------------------------------------------------------------------
($imported||={})[:Dekita_ResolutionSetter] = 1.0
#===============================================================================
# ☆ Updates
#-------------------------------------------------------------------------------
# D /M /Y
# 15/1o/2o14 - Started, Finished,
#===============================================================================
# ☆ Introduction
#-------------------------------------------------------------------------------
# This script was written by DekitaRPG for the use with the offical high res dll. 
# 
# The purpose of this script is to allow the developer to easily adjust their
# selected screen resolution and thus, determine the optimum resolution setting
# for their project / computer.
# 
# Simply hold ALT and press UP/DOWN/LEFT/RIGHT to change the screen resolution. 
# UP/DOWN changes height and LEFT/RIGHT changes width. ALT *MUST* be held down 
# for the key to trigger.
# 
# Remember to refresh your scene (call the menu or something) after changing
# resolution to reset the display. No change to FPS otherwise.
# 
#===============================================================================
# ★☆★☆★☆★☆★☆★☆★☆★ TERMS AND CONDITIONS: ☆★☆★☆★☆★☆★☆★☆★☆★☆
#===============================================================================
# Please give credit to Dekita (or DekitaRPG). (requested, not required.)
# Free to use for all projects (commercial / non commercial).
# 
# Please do not repost this script on other sites - if you wish, you can 
# provide a link to the webpage below;
# http://dekitarpg.wordpress.com/2014/10/16/resolution-setter/
# 
#===============================================================================
# ☆ Instructions
#-------------------------------------------------------------------------------
# Place Below " ▼ Materials " and Above " ▼ Main " in your script editor.
# 
#===============================================================================
# ☆ Script Calls
#-------------------------------------------------------------------------------
# Graphics.change_res(type,change)
#---------------------------------
#   type   = :w or :h   
#   change = +32 or -32
#   You can send other change values; however, this will likely cause severe 
#   irregularities with map display and also with performance. 
# 
#-------------------------------------------------------------------------------
# Graphics.last_screen_res
#--------------------------
#   This will return an array containing the last [width,height] of the game 
#   window - if you have not changed resolution using the change_res script call 
#   then this script call will simply return the current width and height data.
# 
#===============================================================================
# www.dekyde.com
# www.dekitarpg.wordpress.com
#===============================================================================
module DEK_ResSet
#===============================================================================
  #-----------------------------------------------------------------------------
  # // This is a hash containing the key symbols that control resolution change.
  # // I recommend you keep as is; however, the settings can be changed.
  #-----------------------------------------------------------------------------
  Keys = {
    holding_dwn_key: :ALT,
    increase_height: :UP,
    decrease_height: :DOWN,
    increase_width:  :RIGHT,
    decrease_width:  :LEFT,
  }
  #-----------------------------------------------------------------------------
  # // This simply calls a fake scene to properly refresh the screen dimentions.
  # Normally when resize takes place, the graphics processor does not update
  # everything immediately, it is only after a scene change that this begin to 
  # update properly.
  # Personally, I just call the menu scene after performing my changes but
  # if you wish, you can set this to true and a scene will be auto called
  # when resolution is changed. This obviously does take a little time to 
  # process, so expect the screen to go black momentarily. 
  #-----------------------------------------------------------------------------
  Call_Scene_When_Res_Change = false
  #-----------------------------------------------------------------------------
  # [ end module ]
  #-----------------------------------------------------------------------------
end
#===============================================================================
# // Customization Section Has Ceased. 
# // Only edit the code below if you are able to comprehend its processing.
# // This is a precaution to ensure your sanity remains intact. :) 
#===============================================================================
# www.dekyde.com
# www.dekitarpg.wordpress.com
#===============================================================================
module Graphics
#===============================================================================
  #-----------------------------------------------------------------------------
  # Included Modules
  #-----------------------------------------------------------------------------
  include DEK_ResSet
  #-----------------------------------------------------------------------------
  # Alias List
  #-----------------------------------------------------------------------------
  class << self ; alias :dekreseupdate :update ; end
  #-----------------------------------------------------------------------------
  # // Graphics.update
  #-----------------------------------------------------------------------------
  def self.update(*args,&blk)
    dekreseupdate(*args,&blk)
    update_res_set if $TEST
  end
  #-----------------------------------------------------------------------------
  # // Graphics.update_res_set
  # // This method is called each time Graphics.update is called. 
  #-----------------------------------------------------------------------------
  def self.update_res_set
    return unless Input.press? Keys[:holding_dwn_key]
    u = Input.trigger? Keys[:increase_height]
    d = Input.trigger? Keys[:decrease_height]
    r = Input.trigger? Keys[:increase_width]
    l = Input.trigger? Keys[:decrease_width]
    return unless u || d || l || r
    change_res(:h,+32) if u && !d
    change_res(:h,-32) if d && !u
    change_res(:w,+32) if r && !l
    change_res(:w,-32) if l && !r
  end
  #-----------------------------------------------------------------------------
  # // Graphics.change_res(type,change)
  # // type   = :w or :h   //   change = +32 or -32
  #-----------------------------------------------------------------------------
  def self.change_res(*args)
    @@old_screen_size = [width,height]
    case args.first
    when :w then new_screen_size = [width+args.last,height] 
    when :h then new_screen_size = [width,height+args.last]
    end
    return unless new_screen_size
    resize_screen(*new_screen_size)
    fix_player_pos
    fix_graphicsss
  end
  #-----------------------------------------------------------------------------
  # // Graphics.last_screen_res
  #-----------------------------------------------------------------------------
  def self.last_screen_res
    @@old_screen_size || [width,height]
  end
  #-----------------------------------------------------------------------------
  # // Graphics.fix_player_pos  
  #-----------------------------------------------------------------------------
  def self.fix_player_pos
    return unless SceneManager.scene_is?(Scene_Map)
    $game_player.center($game_player.x,$game_player.y)
  end
  #-----------------------------------------------------------------------------
  # // Graphics.fix_graphicsss
  # // This method is simply to call a scene that reverts back to current scene.
  # // The purpose os this is to have the current screen size refreshed properly
  # // as this is not done normally with Graphics.resize_screen(*args)
  #-----------------------------------------------------------------------------
  def self.fix_graphicsss
    return unless Call_Scene_When_Res_Change
    SceneManager.call Scene_ResJustChanged
  end
  #-----------------------------------------------------------------------------
  # [ end module ]
  #-----------------------------------------------------------------------------
end
#===============================================================================
class Game_Player
#===============================================================================
  #-----------------------------------------------------------------------------
  # Alias List
  #-----------------------------------------------------------------------------
  alias :dekressetmovable? :movable?
  #-----------------------------------------------------------------------------
  # // $game_player.movable?
  #-----------------------------------------------------------------------------
  def movable?(*args,&blk)
    return false if changing_res?
    return dekressetmovable?(*args,&blk)
  end
  #-----------------------------------------------------------------------------
  # // $game_player.changing_res?
  # // Returns true / false based on whether user is holding down res change key
  #-----------------------------------------------------------------------------
  def changing_res?
    Input.press?(DEK_ResSet::Keys[:holding_dwn_key])
  end
  #-----------------------------------------------------------------------------
  # [ end class ]
  #-----------------------------------------------------------------------------
end
#===============================================================================
class Scene_ResJustChanged < Scene_Base
#===============================================================================
  #-----------------------------------------------------------------------------
  # // Starts Scene Processing
  #-----------------------------------------------------------------------------
  def start ;    super ; return_scene ; end
  def transition_speed ; return 0     ; end
  #-----------------------------------------------------------------------------
  # [ end class ]
  #-----------------------------------------------------------------------------
end
#===============================================================================
# www.dekyde.com
# www.dekitarpg.wordpress.com
#===============================================================================
end # if false / true