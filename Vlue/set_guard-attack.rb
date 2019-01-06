#Set Guard/Attack Skills v1.3
#----------#
#Features: Let's you set different attack/guard actions for individual actors
#
#Usage:    Placed in note tags of actors, weapons, armors, classes:
#             <Attack_Id skill_id> - changes default attack
#             <Guard_Id skill_id>  - changes default guard
#
#          Weapons/Armors overrides Classes overides Actors.
#          
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

#Sets Attack/Guard commands to name of skill
SGAS_COMMAND_TO_SKILL_NAME = true

class Game_Actor
  def guard_skill_id
    @equips.each do |item|
      next unless item.object
      return $1.to_i if item.object.note.upcase =~ /<GUARD_ID (\d+)>/
    end
    return $1.to_i if self.class.note.upcase =~ /<GUARD_ID (\d+)>/
    actor.note.upcase =~ /<GUARD_ID (\d+)>/ ? $1.to_i : 2
  end
  def attack_skill_id
    @equips.each do |item|
      next unless item.object
      return $1.to_i if item.object.note.upcase =~ /<ATTACK_ID (\d+)>/
    end
    return $1.to_i if self.class.note.upcase =~ /<ATTACK_ID (\d+)>/
    actor.note.upcase =~ /<ATTACK_ID (\d+)>/ ? $1.to_i : 1
  end
end

class Window_ActorCommand
  def add_attack_command
    text = $data_skills[@actor.attack_skill_id].name if SGAS_COMMAND_TO_SKILL_NAME
    add_command(text ? text : Vocab::attack, :attack, @actor.attack_usable?)
  end
  def add_guard_command
    text = $data_skills[@actor.guard_skill_id].name if SGAS_COMMAND_TO_SKILL_NAME
    add_command(text ? text : Vocab::guard, :guard, @actor.guard_usable?)
  end
end