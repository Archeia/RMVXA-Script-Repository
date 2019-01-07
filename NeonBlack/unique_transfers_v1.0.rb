###--------------------------------------------------------------------------###
#  Unique Transfers script                                                     #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
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
#  V1.0 - 7.17.2012                                                            #
#   Rewrote map transitions portion                                            #
#  V0.1 - 6.25.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Scene_Battle: start                                           #
#  Overwrites  - Scene_Map: perform_battle_transition, pre_transfer,           #
#                           post_transfer                                      #
#  New Objects - Scene_Base: custom_transition, custom_transfers,              #
#                            get_trans_image                                   #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script overwrites how transitions are handled when changing maps and   #
#  when entering battle.  This script requires some customization to work      #
#  properly as well as some custom graphics.  Be sure to read each config      #
#  option before using.                                                        #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP        # Do not                                                      #
module TRANSFERS #  change these.                                              #
#                                                                              #
###-----                                                                -----###
# The folder that stores all the transfer images.  Change this is you want to  #
# add a new folder.  All folders go within the "Graphics" folder.              #
FOLDER = "System" # Default = "System"                                         #
#                                                                              #
# Set if the screen is wiped to black before battle.  If this is set to false  #
# the screen will change directly to the battle screen using the transition    #
# much like in RPG Maker XP.                                                   #
BATTLE_WIPE = true # Default = true                                            #
#                                                                              #
# An array containing the names of all the custom battle transfers.  This      #
# array MUST have at least one entry.  Be sure to surround each entry in       #
# quotes and seperate them with a comman, ie. ["Battle1", "Battle2"].          #
BATTLE =[ "BattleStart", ]
#                                                                              #
# Set if you want to use custom map transfers.  If this is set to false, the   #
# last few options don't matter.                                               #
MAP_TRANSFERS = false # Default = false                                        #
#                                                                              #
# Choose if you want to wipe the map when transferring maps.  If this option   #
# is set to false transfers will go right from one map to the next without a   #
# black screen.  Also if it is set to false, only "TRANSFER_IN" transitions    #
# are used.                                                                    #
MAP_WIPE = true # Default = true                                               #
#                                                                              #
# This array contains the transitions to use when erasing the map.  This array #
# must be set up the same way as the battle array above.  If this blank, the   #
# default fade effect is used.                                                 #
TRANSFER_OUT =[]
#                                                                              #
# This array contains the transfers for re-drawing the screen after a map      #
# transfer.  It follows the same rules as the other two above.  If blank, the  #
# default fade effect is used.                                                 #
TRANSFER_IN =[]
#                                                                              #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

end
end

$imported = {} if $imported.nil?
$imported["CP_TRANSITION"] = 1.0

class Scene_Base  ## Calls the transition change.  Kinda pointless I guess.
  def custom_transition(*args)
    Graphics.transition(*args)
  end
  
  def custom_transfers(key)  ## Gets the full name of the transfer image.
    folder = CP::TRANSFERS::FOLDER
    image = get_trans_image(key)
    trans = "Graphics/" + folder + "/" + image 
    return trans
  end
  
  def get_trans_image(key)  ## Gets the transfer image file.
    max = 0
    case key
    when :battle
      total = CP::TRANSFERS::BATTLE.size  ## Sets up random number grabbing.
      max = rand(total) if total > 1
      image = CP::TRANSFERS::BATTLE[max]
    when :mapout
      total = CP::TRANSFERS::TRANSFER_OUT.size
      max = rand(total) if total > 1
      image = CP::TRANSFERS::TRANSFER_OUT[max]
    when :mapin
      total = CP::TRANSFERS::TRANSFER_IN.size
      max = rand(total) if total > 1
      image = CP::TRANSFERS::TRANSFER_IN[max]
    end
    return image
  end
end

class Scene_Map < Scene_Base
  def perform_battle_transition
    if CP::TRANSFERS::BATTLE_WIPE  ## Changes the battle transition for wipe.
      trans = custom_transfers(:battle)
      custom_transition(60, trans, 100)
    end
    Graphics.freeze
  end

  def pre_transfer  ## The pre-transfer method.
    @map_name_window.close  ## Below gets checks in transfer anims early.
    frz = (CP::TRANSFERS::MAP_TRANSFERS && !CP::TRANSFERS::TRANSFER_IN.empty?)
    if (CP::TRANSFERS::MAP_TRANSFERS && !CP::TRANSFERS::TRANSFER_OUT.empty?) ||
        !CP::TRANSFERS::MAP_WIPE
      Graphics.freeze  ## Freeze the screen to normal.
      if CP::TRANSFERS::MAP_WIPE  ## Ignore unless map should be wiped.
        gw = Graphics.width  ## Width and height for later used.
        gh = Graphics.height
        @clear_screen = Sprite.new  ## Create a blank sprite.
        @clear_screen.z = 500
        @clear_screen.bitmap = Bitmap.new(gw, gh)
        if $game_temp.fade_type == 1  ## Sets the sprite's colour.
          cl = Color.new(255, 255, 255)
        else
          cl = Color.new(0, 0, 0)
        end
        @clear_screen.bitmap.fill_rect(0, 0, gw, gh, cl)
        trans = custom_transfers(:mapout)  ## Get the transition name.
        custom_transition(fadeout_speed, trans, 100)  ## Perform transition.
        Graphics.freeze if frz  ## Freeze the screen for custom transitions.
        fadeout(1)  ## Actually darken the screen.
        @clear_screen.dispose  ## Destroy the sprite.
      end
    else  ## Normal processing.
      case $game_temp.fade_type
      when 0
        fadeout(fadeout_speed)
      when 1
        white_fadeout(fadeout_speed)
      end
      Graphics.freeze if frz  ## An added freeze for transitions.
    end
  end
  
  def post_transfer  ## Post transfer processing overwrite.
    if CP::TRANSFERS::MAP_TRANSFERS && !CP::TRANSFERS::TRANSFER_IN.empty?
      Graphics.wait(fadein_speed / 2) if CP::TRANSFERS::MAP_WIPE
      fadein(1)  ## Create the normal screen.
      trans = custom_transfers(:mapin)  ## Get transfer name.
      custom_transition(fadein_speed, trans, 100)  ## Perform transfer.
    else  ## Normal processing.
      case $game_temp.fade_type
      when 0
        Graphics.wait(fadein_speed / 2)
        fadein(fadein_speed)
      when 1
        Graphics.wait(fadein_speed / 2)
        white_fadein(fadein_speed)
      end
    end
    @map_name_window.open
  end
end

class Scene_Battle < Scene_Base
  alias cp_battle_trans start unless $@
  def start  ## Alias for XP style battle transitions.
    cp_battle_trans
    unless CP::TRANSFERS::BATTLE_WIPE
      trans = custom_transfers(:battle)
      custom_transition(60, trans, 100)
    end
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###