#==============================================================================
#    Random Encounters by Level
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 22 September, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to assign levels to enemies and have it so that 
#   enemy will only be randomly encountered when the player's level is within 
#   some range of that enemy's level. You can set the level range by map.
#
#    That might be confusing, so I will try to explain a little better by 
#   example. You set up a map with possible enemies being Angels, Cherubims, 
#   and Seraphims. You can enter this map at any time, and so you want the 
#   random encounters to reflect what level the hero party is. You don't want 
#   the party attacking Seraphims when they are level 1, because they will be 
#   crushed, and you don't want them to fight Angels when they are level 99, 
#   because it's too easy. Thus, you just set up in the script what levels the 
#   enemies with this script you will only fight monster troops that are within 
#   level range of your heroes. You can set what that level range is as well, 
#   thus making some maps harder and others easier.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    To set the level of an enemy, all you need to do is place the following 
#   code in its notebox:
#
#      \elvl[x]
#        
#   Replace the x with the level you want to assign to the enemy. As an example
#   if you wanted to set an enemy's level to 7, you would use the following
#   code:
#
#      \elvl[7]
#
#   If you do not give an enemy a level, then it will be encounterable at any 
#   level. The level of any given troop is the average level of all its members.
#
#    By default, your party will only encounter troops that are within 5 levels
#   of your party. In other words, if the average level of your party is 7, you
#   will encounter troops with levels between 2 and 12. You can change the 
#   level range in two ways. 
#
#    Firstly, you can change it by map by placing the following code in the 
#   notebox of a map:
#
#      \elvl[x, y]
#
#   Replace x and y with the minimum and maximum level difference. So, if you
#   have something like:
#
#      \elvl[-2, 8]
#
#   Then the parties will encounter enemy troops that are between 2 levels
#   below the party and 8 levels above the party. Alternately, if you did this:
#
#      \elvl[v1, v2]
#
#   Then it would set the minimum level to the value of variable 1 and the
#   maximum level to the value of variable 2.
#
#    Secondly, you can change the level range by placing the following code in
#   a Script event command:
#
#      set_encounter_level_range(x, y)
#
#   where, again, you replace x and y with the minimum and maximum level
#   diference.
#
#    You can turn this script off and on completely with the following code:
#
#      $game_map.marel_on = false    # <- OFF
#      $game_map.marel_on = true     # <- ON
#==============================================================================

$imported ||= {}
$imported[:MA_RandomEncounterByLevel] = true

#==============================================================================
# *** RPG
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    modified classes - Enemy; Troop; Map::Encounter
#==============================================================================

module RPG

#==============================================================================
# ** RPG::Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - marel_level
#==============================================================================

class Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Level
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marel_level
    unless @marel_level
      @marel_level = note[/\\E[ _]?LE?VE?L\[\s*(\d+)\s*\]/i] ? $1.to_i : 0
    end
    @marel_level
  end
end

#==============================================================================
# ** RPG::Troop
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - marel_level
#==============================================================================

class Troop
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Level
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marel_level
    unless @marel_level
      enemies = members.collect { |en| $data_enemies[en.enemy_id] }.compact
      total = enemies.inject(0) { |sum, en| sum + en.marel_level }
      size = enemies.select { |en| en.marel_level != 0 }.size
      @marel_level = size == 0 ? 0 : (total.to_f / size).ceil
    end
    @marel_level
  end
end

#==============================================================================
# ** RPG::Map::Encounter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - marel_level
#==============================================================================

class Map::Encounter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Level
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marel_level
    return $data_troops[troop_id].marel_level if $data_troops && $data_troops[troop_id]
    return 0
  end
end

end

#==============================================================================
# ** Game_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_accessor - marel_min_level; marel_max_level; marel_on
#    aliased method - initialize; setup
#    new method -marel_encounter_range
#==============================================================================

class Game_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :marel_min_level
  attr_accessor :marel_max_level
  attr_accessor :marel_on
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marel_initz_5ha6 initialize
  def initialize(*args, &block)
    @marel_on = true
    @marel_min_level = -5
    @marel_max_level = 5
    marel_initz_5ha6(*args, &block) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marel_setup_4bt7 setup
  def setup(*args, &block)
    marel_setup_4bt7(*args, &block) # Call Original Method
    if @map.note[/\\E[ _]?LE?VE?L\[\s*(V?)(-?\d+)[\s;,:]*(V?)(-?\d+)\s*\]/i]
      min = $1.empty? ? $2.to_i : $game_variables[$2.to_i.abs]
      max = $3.empty? ? $4.to_i : $game_variables[$4.to_i.abs]
      @marel_min_level, @marel_max_level = *[min, max].sort
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Marel Encounter Level Range
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def marel_encounter_level_range
    party = $game_party.battle_members
    avg = party.empty? ? 0 : 
      (party.inject(0) { |sum, mem| sum + mem.level }) / party.size 
    (avg + marel_min_level)..(avg + marel_max_level)
  end
end

#==============================================================================
# ** Game_Player
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - encounter_ok?
#==============================================================================

class Game_Player
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check if can encounter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias marel_enctrok_2cf9 encounter_ok?
  def encounter_ok?(encounter, *args, &block)
    return false if $game_map.marel_on && !(encounter.marel_level == 0 ||
      ($game_map.marel_encounter_level_range === encounter.marel_level))
    marel_enctrok_2cf9(encounter, *args, &block) # Call Original Method
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - set_encounter_level_range
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Encounter Level Range
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_encounter_level_range(min, max)
    $game_map.marel_min_level, $game_map.marel_max_level = *[min, max].sort
  end
end