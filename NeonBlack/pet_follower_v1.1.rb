###--------------------------------------------------------------------------###
#  Pet Follower script                                                         #
#  Version 1.1                                                                 #
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
#  V1.1 - 6.18.2012                                                            #
#   Added constant motion for pets                                             #
#  V1.0 - 6.18.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_Interpreter: remove_pet, hide_pet, show_pet, pet         #
#                                  pet_motion, pet_top                         #
#                Game_Followers: initialize                                    #
#                Game_Follower: refresh                                        #
#  Overwrites  - Game_Follower: update                                         #
#  New Objects - Game_Followers: remove_pet                                    #
#                Game_Follower: pet?                                           #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is plug and play and is activated and used through some simple  #
#  script calls.  Note that the pet acts exactly like a normal follower and    #
#  will gather if the gather option is used, however the pet will not hide if  #
#  the other followers are hidded.  Here are the commands:                     #
#                                                                              #
#   pet("x", y) - Changes the sprite of the pet follower where "x" is the      #
#                 filename and "y" is the index within the file.  If "y" is    #
#                 not defined, an index of "0" (the first image in a file)     #
#                 will be used.                                                #
#   remove_pet  - Removes the pet from the followers.                          #
#   hide_pet    - Hides the pet until "show_pet" is called.                    #
#   show_pet    - Shows the pet again.                                         #
#   pet_motion  - Causes pet sprites to stay animated.                         #
#   pet_stop    - Stops pet sprite animation.                                  #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

$imported = {} if $imported == nil
$imported["CP_PET"] = true

class Game_Interpreter  ##  Add pet commands that can be called by the user.
  def remove_pet
    $game_player.followers.remove_pet
    $game_player.followers.refresh
  end
  
  def hide_pet
    $game_player.followers.pet_visible = false
    $game_player.followers.refresh
  end
  
  def show_pet
    $game_player.followers.pet_visible = true
    $game_player.followers.refresh
  end
  
  def pet(name, index = 0)
    $game_player.followers.pet_name = name
    $game_player.followers.pet_index = index
    $game_player.followers.refresh
  end
  
  def pet_motion
    $game_player.followers.pet_motion = true
    $game_player.followers.refresh
  end
  
  def pet_stop
    $game_player.followers.pet_motion = false
    $game_player.followers.refresh
  end
end

class Game_Followers  ##  New variables
  attr_accessor :pet_name
  attr_accessor :pet_index
  attr_accessor :pet_visible
  attr_accessor :pet_motion
  
  alias pet_initialize initialize unless $@
  def initialize(leader)  ##  Push an extra follower for the pet.
    pet_initialize(leader)
    @data.push(Game_Follower.new(@data.size + 1, @data[-1]))
    @pet_name = ""
    @pet_index = 0
    @pet_visible = true
    @pet_motion = false
  end
  
  def remove_pet  ##  Nulify variables to remove the pet.
    @pet_name = ""
    @pet_index = 0
  end
end

class Game_Follower < Game_Character
  alias pet_refresh refresh unless $@
  def refresh  ##  Add pet names for the refresh.
    pet_refresh
    @character_name = pet? ? $game_player.followers.pet_name : @character_name
    @character_index = pet? ? $game_player.followers.pet_index : @character_index
    @step_anime = pet? ? $game_player.followers.pet_motion : false
  end
  
  def pet?  ##  Check if follower is the pet.
    (@member_index == $game_party.battle_members.size &&
     $game_player.followers.pet_visible && $game_player.followers.visible) ||
    (@member_index == 1 && $game_player.followers.pet_visible &&
     !$game_player.followers.visible)
  end
   
  def update  ##  The only overwrite.
    @move_speed     = $game_player.real_move_speed
    @transparent    = $game_player.transparent
    @walk_anime     = $game_player.walk_anime
    @step_anime     = $game_player.step_anime unless pet?
    @direction_fix  = $game_player.direction_fix
    @opacity        = $game_player.opacity
    @blend_type     = $game_player.blend_type
    super
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###