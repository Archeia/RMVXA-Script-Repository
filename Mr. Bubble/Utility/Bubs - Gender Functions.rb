# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Gender Functions                                      │ v1.2 │ (1/06/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Yanfly, script and design references
#--------------------------------------------------------------------------
# This is a simple script that provides developers the option to define the
# gender of Actors and Enemies in their game. With the use of script calls
# and new methods, this opens up a variety of options for eventers and 
# scripters alike.
#--------------------------------------------------------------------------
# ++ Changelog ++
#--------------------------------------------------------------------------
# v1.2 : Efficency update. (1/06/12)
# v1.1 : Enemies should now use the proper default gender value. (1/04/12)
# v1.0 : Initial release. (1/04/12)
#--------------------------------------------------------------------------
# ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following notetags are for Actors and Enemies only:
# 
# <gender: none>
# <gender: genderless>
#   Defines the Actor or Enemy as genderless. The internal value that 
#   represents genderless is 0.
#   
# <gender: m>
# <gender: male>
#   Defines the Actor or Enemy as male. The internal value that
#   represents male is 1.
#   
# <gender: f>
# <gender: female>
#   Defines the Actor or Enemy as female. The internal value that
#   represents female is 2.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ++ Conditional Branch Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in Conditional
# Branch event commands within the Tab 4 "Script" box.
# Each of these script calls will turn the given Game Switch ON
# or OFF, where ON is true and OFF is false.
#
# leader_genderless?
# leader_male?
# leader_female?
#   These script calls check the gender of the party leader.
#
# party_member_genderless?(index)
# party_member_male?(index)
# party_member_female?(index)
#   These script calls check the gender of the given party member
#   where index is the party position index. 0 is the party leader,
#   1 is the 2nd member, 2 is the 3rd member, etc.
#
# actor_genderless?(id)
# actor_male?(id)
# actor_female?(id)
#   These script calls check an actor's gender where id is an
#   actor id from the Database. These can check the gender of actors
#   not in the current party.
#
# battle_party_all_genderless?
# battle_party_all_male?
# battle_party_all_female?
#   These script calls check if all members in the battle party
#   have matching genders.
#
# troop_enemy_genderless?(index)
# troop_enemy_male?(index)
# troop_enemy_female?(index)
#   These script calls check the gender of the given enemy in the 
#   current troop where index is the enemy's troop position index. 
#   0 is the first enemy, 1 is the 2nd enemy, 2 is the 3rd enemy, 
#   etc. This script call only works in-battle.
#   
# enemy_genderless?(id)
# enemy_male?(id)
# enemy_female?(id)
#   These script calls check an enemy's gender where id is an
#   enemy id from the Database. These can check the gender of enemies
#   even when not in battle.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ++ Variable Operation Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in Variable 
# Operation event commands within the "Script" box.
# Each of these script calls return a number which is then
# stored into the given Game Variable.
#
# all_party_genderless_count
# all_party_male_count
# all_party_female_count
#   These script calls count the number of party members that has
#   a specified gender and stores the number into the given
#   Game Variable. This includes both battle and reserve members
#   in the party.
#
# battle_party_genderless_count
# battle_party_male_count
# battle_party_female_count
#   These script calls count the number of battle members in the 
#   party that has a specified gender and stores the number 
#   into the given Game Variable. This does not include reserve members.
# 
# reserve_party_genderless_count
# reserve_party_male_count
# reserve_party_female_count
#   These script calls count the number of reserve members in the 
#   party that has a specified gender and stores the number 
#   into the given Game Variable. This does not include battle members.
#--------------------------------------------------------------------------
# ++ Compatibility ++
#--------------------------------------------------------------------------
# This script does not overwrite any default VXA methods. All default
# methods modified in this script are aliased.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
# ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. Newest 
# versions of this script can be found at http://mrbubblewand.wordpress.com/
#==========================================================================

$imported = {} if $imported.nil?
$imported["BubsGenderFunctions"] = true
  
#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================

module Bubs
  module GenderFunctions
  #--------------------------------------------------------------------------
  # Default Gender Settings
  #--------------------------------------------------------------------------
  # The values below will determine the default gender for actors and
  # enemies if a notetag is not found.
  #     0 : Genderless
  #     1 : Male
  #     2 : Female
  DEFAULT_ACTOR_GENDER = 0    # Actors
  DEFAULT_ENEMY_GENDER = 0    # Enemies
  
  end # module GenderFunctions
end # module Bubs
  
#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    GENDER_NONE = /<(?:GENDER|sex):\s*(?:NONE|genderless)>/i
    GENDER_MALE = /<(?:GENDER|sex):\s*(?:M|male)>/i
    GENDER_FEMALE = /<(?:GENDER|sex):\s*(?:F|female)>/i
  end
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_gender_func load_database; end
  def self.load_database
    load_database_bubs_gender_func # alias
    load_notetags_bubs_gender_func
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_gender_func
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_gender_func
    groups = [$data_actors, $data_enemies]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_gender_func
      end # for
    end # for
  end # def
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :gender
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_gender_func
  #--------------------------------------------------------------------------
  def load_notetags_bubs_gender_func
    if self.is_a?(RPG::Actor)
      @gender = Bubs::GenderFunctions::DEFAULT_ACTOR_GENDER
    else
      @gender = Bubs::GenderFunctions::DEFAULT_ENEMY_GENDER
    end
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::GENDER_NONE
        @gender = 0
      when Bubs::Regexp::GENDER_MALE
        @gender = 1
      when Bubs::Regexp::GENDER_FEMALE
        @gender = 2
      end
    } # self.note.split
    
  end # def
end # class RPG::BaseItem


#==========================================================================
# ++ Game_BattlerBase
#==========================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # new method : genderless?
  #--------------------------------------------------------------------------
  def genderless?
    if actor?
      return true if self.actor.gender == 0
    else
      return true if self.enemy.gender == 0
    end
    return false
  end
  #--------------------------------------------------------------------------
  # new method : male?
  #--------------------------------------------------------------------------
  def male?
    if actor?
      return true if self.actor.gender == 1
    else
      return true if self.enemy.gender == 1
    end
    return false
  end
  #--------------------------------------------------------------------------
  # new method : male?
  #--------------------------------------------------------------------------
  def female?
    if actor?
      return true if self.actor.gender == 2
    else
      return true if self.enemy.gender == 2
    end
    return false  
  end
end # class Game_BattlerBase


module Bubs
  module GenderFunctions
  module ScriptCalls
  #--------------------------------------------------------------------------
  # new method : leader_genderless?
  #--------------------------------------------------------------------------
  def leader_genderless?
    leader = $game_party.leader
    return leader.genderless? unless leader.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : leader_male?
  #--------------------------------------------------------------------------
  def leader_male?
    leader = $game_party.leader
    return leader.male? unless leader.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : leader_female?
  #--------------------------------------------------------------------------
  def leader_female?
    leader = $game_party.leader
    return leader.female? unless leader.nil?
    return false  
  end
  #--------------------------------------------------------------------------
  # new method : party_member_genderless?
  #--------------------------------------------------------------------------
  def party_member_genderless?(index)
    member = $game_party.members[index]
    return member.genderless? unless member.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : party_member_male?
  #--------------------------------------------------------------------------
  def party_member_male?(index)
    member = $game_party.members[index]
    return member.male? unless member.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : party_member_female?
  #--------------------------------------------------------------------------
  def party_member_female?(index)
    member = $game_party.members[index]
    return member.female? unless member.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : actor_genderless?
  #--------------------------------------------------------------------------
  def actor_genderless?(id)
    actor = $game_actors[id]
    return actor.genderless? unless actor.nil?
    return false
  end
  #--------------------------------------------------------------------------
  # new method : actor_male?
  #--------------------------------------------------------------------------
  def actor_male?(id)
    actor = $game_actors[id]
    return actor.male? unless actor.nil?
    return false  
  end
  #--------------------------------------------------------------------------
  # new method : actor_female?
  #--------------------------------------------------------------------------
  def actor_female?(id)
    actor = $game_actors[id]
    return actor.female? unless actor.nil?
    return false  
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_all_genderless?
  #--------------------------------------------------------------------------
  def battle_party_all_genderless?
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.genderless?
    end
    return true if count == $game_party.max_battle_members
    return false
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_all_male?
  #--------------------------------------------------------------------------
  def battle_party_all_male?
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.male?
    end
    return true if count == $game_party.max_battle_members
    return false
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_all_female?
  #--------------------------------------------------------------------------
  def battle_party_all_female?
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.female?
    end
    return true if count == $game_party.max_battle_members
    return false
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_genderless_count
  #--------------------------------------------------------------------------
  def battle_party_genderless_count
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.genderless?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_male_count
  #--------------------------------------------------------------------------
  def battle_party_male_count
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.male?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : battle_party_female_count
  #--------------------------------------------------------------------------
  def battle_party_female_count
    count = 0
    for member in $game_party.battle_members
      next if member.nil?
      count += 1 if member.female?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : reserve_party_genderless_count
  #--------------------------------------------------------------------------
  def reserve_party_genderless_count
    count = 0
    count += all_party_genderless_count
    count -= battle_party_genderless_count
    return count
  end
  #--------------------------------------------------------------------------
  # new method : reserve_party_male_count
  #--------------------------------------------------------------------------
  def reserve_party_male_count
    count = 0
    count += all_party_male_count
    count -= battle_party_male_count
    return count
  end
  #--------------------------------------------------------------------------
  # new method : reserve_party_female_count
  #--------------------------------------------------------------------------
  def reserve_party_female_count
    count = 0
    count += all_party_female_count
    count -= battle_party_female_count
    return count
  end
  #--------------------------------------------------------------------------
  # new method : all_party_genderless_count
  #--------------------------------------------------------------------------
  def all_party_genderless_count
    count = 0
    for member in $game_party.all_members
      next if member.nil?
      count += 1 if member.genderless?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : all_party_male_count
  #--------------------------------------------------------------------------
  def all_party_male_count
    count = 0
    for member in $game_party.all_members
      next if member.nil?
      count += 1 if member.male?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : all_party_female_count
  #--------------------------------------------------------------------------
  def all_party_female_count
    count = 0
    for member in $game_party.all_members
      next if member.nil?
      count += 1 if member.female?
    end
    return count  
  end
  #--------------------------------------------------------------------------
  # new method : troop_enemy_genderless?
  #--------------------------------------------------------------------------
  def troop_enemy_genderless?(index)
    if $game_party.in_battle
      enemy = $game_troop.members[index]
      return enemy.genderless? unless enemy.nil?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # new method : troop_enemy_male?
  #--------------------------------------------------------------------------
  def troop_enemy_male?(index)
    if $game_party.in_battle
      enemy = $game_troop.members[index]
      return enemy.male? unless enemy.nil?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # new method : troop_enemy_female?
  #--------------------------------------------------------------------------
  def troop_enemy_female?(index)
    if $game_party.in_battle
      enemy = $game_troop.members[index]
      return enemy.female? unless enemy.nil?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # new method : enemy_genderless?
  #--------------------------------------------------------------------------
  def enemy_genderless?(id)
    enemy = $data_enemies[id]
    return true if !enemy.nil? && enemy.gender == 0
    return false
  end
  #--------------------------------------------------------------------------
  # new method : enemy_male?
  #--------------------------------------------------------------------------
  def enemy_male?(id)
    enemy = $data_enemies[id]
    return true if !enemy.nil? && enemy.gender == 1
    return false
  end
  #--------------------------------------------------------------------------
  # new method : enemy_female?
  #--------------------------------------------------------------------------
  def enemy_female?(id)
    enemy = $data_enemies[id]
    return true if !enemy.nil? && enemy.gender == 2
    return false
  end
end # module ScriptCalls
end # module GenderFunctions
end # module Bubs

#==========================================================================
# ++ Game_Interpreter
#==========================================================================
class Game_Interpreter; include Bubs::GenderFunctions::ScriptCalls; end