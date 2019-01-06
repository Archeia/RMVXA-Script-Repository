# Threat System v1.1
#----------#
#Features: Make enemies target the the most threatening person!
#           Damage dealt/health restore adds to a actors threat level, while
#           certain note tags can make skills/items modify threat levels.
#
#Usage:   Skill/Item Notetags: (Effects user)
#           <THREAT_CLEAR>      - reduces threat to 0
#           <THREAT_FULL>       - changes threat to highest + 1
#           <THREAT_ADD value>  - adds value to threat
#           <THREAT_SUB value>  - subtracts value from threat
#           <THREAT_MUL float>  - multiplies threat by value
#           <THREAT_DIV float>  - divides threat by value
#
#             value = whole number ( 1 ), float = decimal number ( 1.0 )
#
#         Actor/Class/Equip/State Notetags: (affect amount of threat added)
#           <THREAD_MOD value>
#          A value of 50 would increase the threat added by all abilities by 50%
#           and a value of -50 would be a reduction of 50% in threat.
#          The mod value stacks with actor, class, and all equips.
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

class Game_BattlerBase
  attr_accessor :threat
  alias threat_init initialize
  def initialize(*args)
    threat_init(*args)
    @threat = starting_threat
  end
  def add_threat(amount)
    @threat += amount * threat_modifier
  end
  def sub_threat(amount)
    @threat -= amount
  end
  def div_threat(amount)
    @threat /= amount
  end
  def mul_threat(amount)
    @threat *= amount
  end
  def clear_threat
    @threat = 0
  end
  def starting_threat
    0
  end
  def threat_modifier
    1
  end
  def skill_threat(item)
  end
  def full_threat
  end
end

class Game_Actor
  def threat_modifier
    mod = 100
    mod *= self.class.threat_mod
    mod *= actor.threat_mod
    @equips.each do |equip|
      next unless equip.object
      mod *= equip.object.threat_mod
    end
    states.each do |state|
      mod *= state.threat_mod
    end
    mod / 100
  end
  def skill_threat(item)
    full_threat if item.full_threat?
    div_threat(item.div_threat?) if item.div_threat?
    mul_threat(item.mul_threat?) if item.mul_threat?
    sub_threat(item.sub_threat?) if item.sub_threat?
    add_threat(item.add_threat?) if item.add_threat?
    clear_threat if item.clear_threat?
  end
  def full_threat
    $game_party.members.each do |actor|
      @threat = [actor.threat, @threat].max
    end
    @threat += 1
  end
end

class RPG::UsableItem
  def clear_threat?
    self.note =~ /<THREAT_CLEAR>/ ? true : false
  end
  def full_threat?
    self.note =~ /<THREAT_FULL>/ ? true : false
  end
  def add_threat?
    self.note =~ /<THREAT_ADD (\d+)>/ ? $1.to_i : false
  end
  def sub_threat?
    self.note =~ /<THREAT_SUB (\d+)>/ ? $1.to_i : false
  end
  def mul_threat?
    self.note =~ /<THREAT_MUL (\d+\.\d)>/ ? $1.to_i : false
  end
  def div_threat?
    self.note =~ /<THREAT_DIV (\d+\.\d)>/ ? $1.to_i : false
  end
end
  

class RPG::BaseItem
  def threat_mod
    self.note =~ /<THREAT_MOD (\d+|-\d+)>/ ? 1 + ($1.to_f / 100) : 1
  end
end

class Game_Unit
  def random_target
    alive_members.sort { |a,b| b.threat <=> a.threat }[0]
  end
end

class Game_Battler
  alias threat_ed execute_damage
  alias threat_obs on_battle_start
  alias threat_iue item_user_effect
  def execute_damage(user)
    threat_ed(user)
    user.add_threat(@result.hp_damage.abs)
  end
  def on_battle_start
    threat_obs
    @threat = starting_threat
  end
  def item_user_effect(user, item)
    threat_iue(user, item)
    user.skill_threat(item)
  end
end