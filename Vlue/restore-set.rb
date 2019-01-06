#Restore After Battle 1.3
#----------#
#Features: Allows you to set designated amounts of hp or mp to restore after
#                  a battle or level for different methods of game style.
#
#Usage: Plug and play and customize
#               
#Customization: Set below, in comments.
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

#Restore after level for specific actors only:
RAB_SPECIFIC_ACTORS = false
#Array of actor id's (Array format example: [5,6,78])
RAB_ACTORS = []

#Restore after battle for specific actors only:
RAB_SPECIFIC_ACTORS_B = false
#Array of actor id's
RAB_ACTORS_B = []

LEVELRESTORE  = true #Full restore Upon leveling
PARTIALRESTORE = false #Restore only the hp/mp gained on a level
BATTLERESTORE = true #Set restore Upon battle end

#HPSETTYPE and MPSETTYPE
# Set to 0 for setting of hp/mp to a specific number after battle.
# Set to 1 for setting of hp/mp to a specific percentage after battle.
# Set to 2 for adding to hp/mp by a certain percentage of maxhp/maxmp
HPSETTYPE = 0     
MPSETTYPE = 0

#The numbers to use when setting hp/mp after battle!
HPSET    = 100
MPSET    = 100

class Game_Actor < Game_Battler
  attr_reader   :actor_id
  alias recover_level_up level_up
  def level_up
    if PARTIALRESTORE
      lhp = self.mhp; lmp = self.mmp
    end
    recover_level_up
    return if RAB_SPECIFIC_ACTORS and !RAB_ACTORS.include?(@actor_id)
    if PARTIALRESTORE
      self.hp += self.mhp - lhp;self.mp += self.mmp - lmp
    end
    self.hp = self.mhp if LEVELRESTORE or self.hp > self.mhp
    self.mp = self.mmp if LEVELRESTORE or self.mp > self.mmp
  end
end

class Scene_Battle < Scene_Base  
  alias recover_terminate terminate
  def terminate
    if BATTLERESTORE != true then recover_terminate else
      recover_terminate
      for actor in $game_party.members
        next if RAB_SPECIFIC_ACTORS_B and !RAB_ACTORS.include?(actor.actor_id)
        case HPSETTYPE
        when 0
          actor.hp = HPSET
        when 1
          actor.hp = actor.mhp * HPSET / 100
        when 2
          actor.hp += actor.mhp * HPSET / 100
        end
        case MPSETTYPE
        when 0
          actor.mp = MPSET
        when 1
          actor.mp = actor.mmp * MPSET / 100
        when 2
          actor.mp += actor.mmp * MPSET / 100
        end
      end
    end
  end
end