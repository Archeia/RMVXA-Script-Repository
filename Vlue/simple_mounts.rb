# Simple Mounts v1.0
#----------#
#Features: Magically mount and dismount a mount! (Nothing to do with vehicles,
#           can you even do this with vehicles? I don't know. I didn't bother
#           to look it up. But hey, you can set areas mounts can walk and can 
#           not walk. You try and do that with vehicles. Yah.. and a SE. So..)
#
#Usage:    Press the button, mount mount, Success.
#
#          Notetags (Actor):
#           <Mount ["graphic_name",index]> - defines mount graphic for character
#            I.e.: <Mount ["Riding",0]>
#          Notetags (Map):
#           <No mount> - no mounting on this map
#
#
#~ #----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

#Mount press button! From :A-:Z and all like 4 buttons in between. (See INPUT helpfile)
MOUNT_BUTTON = :Z
#The speed of the mounted mount (default player speed is 4)
MOUNTED_MOVE_SPEED = 5
#List of regions that the mount is able to walk on! (Ignores passability)
MOUNT_ZONE_PASSABLE = [2]
#List of regions that the mount is unable to walk on!
MOUNT_ZONE_UNPASSABLE = [3]
#Switch to activate ability to mount (0 for no use)
MOUNT_UNLOCK_SWITCH = 0
#Sound effect to be played when mounting (or dismounting)
MOUNT_SE = "Horse"

class Game_Player
  attr_accessor :mounted
  alias mount_init initialize
  alias mount_pt perform_transfer
  def initialize(*args)
    mount_init(*args)
    @mounted = false
    @old_speed = 0
  end
  def mount
    array = actor.actor.mounted_graphic
    if array
      actor.set_graphic(array[0],array[1],actor.face_name,actor.face_index)
      refresh
    end
    @old_speed = @move_speed
    @move_speed = MOUNTED_MOVE_SPEED
    @mounted = true
    Audio.se_play("Audio/SE/" + MOUNT_SE,100,100)
  end
  def dismount
    pactor = $data_actors[actor.actor_id]
    actor.set_graphic(pactor.character_name,pactor.character_index,actor.face_name,actor.face_index)
    refresh
    @move_speed = @old_speed
    @mounted = false
    Audio.se_play("Audio/SE/" + MOUNT_SE,100,100)
  end
  def map_passable?(x,y,d)
    if @mounted
      return true if MOUNT_ZONE_PASSABLE.include?($game_map.region_id(x,y))
      return false if MOUNT_ZONE_UNPASSABLE.include?($game_map.region_id(x,y))
    end
    $game_map.passable?(x,y,d)
  end
  def perform_transfer
    mount_pt
    dismount if !$game_map.allow_mounts
  end
end

class Scene_Map
  alias mount_update update
  def update(*args)
    mount_update(*args)
    if Input.trigger?(MOUNT_BUTTON) 
      if MOUNT_UNLOCK_SWITCH > 0
        return unless $game_switches[MOUNT_UNLOCK_SWITCH]
      end
      return unless $game_map.allow_mounts
      $game_player.mounted ? $game_player.dismount : $game_player.mount
    end
  end
end

class RPG::Actor
  def mounted_graphic
    self.note =~ /<Mount (.+)>/
    if $1
      array = eval($1)
      return array
    end
    return false
  end
end

class Game_Actor
  attr_reader :actor_id
end

class Game_Map
  def allow_mounts
    @map.note =~ /<No mount>/ ? false : true
  end
end