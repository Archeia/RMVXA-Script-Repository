###--------------------------------------------------------------------------###
#  Victory Ranking script                                                      #
#  Version 2.1e                                                                #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neon Black                                                #
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
#  V2.1 - 11.16.2012                                                           #
#   Added grade requirement for drops                                          #
#   Fixed an issue where drop rate was not figured properly                    #
#  V2.0 - Finished 8.11.2012                                                   #
#   Added level up windows                                                     #
#   Created score items and Grade module                                       #
#   Numerous other bugfixes and changes                                        #
#  V1.1b - 6.26.2012                                                           #
#   Fixed an error related to exp gain display                                 #
#  V1.1 - 6.21.2012                                                            #
#   Added rank sprite effect                                                   #
#  V1.0 - 6.19.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  This script has been tested to work with Yanfly's battle engine (just the   #
#  base engine) and Yami's PCTB.  If you have any issue, let me know and I     #
#  will address them asap.                                                     #
#  Due to the number of new windows, I will only list methods in already       #
#  existing objects here and not any of the newly created objects.             #
#                                                                              #
#  Alias       - BattleManager: setup, play_battle_bgm                         #
#                Game_Battler: execute_damage                                  #
#                Game_Enemy: initialize                                        #
#                Game_Actor: level_up                                          #
#                Scene_Battle: update_pctb_speed, dispose_all_windows,         #
#                              use_item                                        #
#                DataManager: load_database                                    #
#  Overwrites  - BattleManager: process_victory, play_battle_end_me,           #
#                               gain_gold, gain_drop_items, gain_exp           #
#                Game_Troop: make_drop_items                                   #
#                Game_Enemy: make_drop_items                                   #
#                Scene_Battle: update                                          #
#  New Objects - BattleManager: old_levels, old_skills, victory_phase?,        #
#                               skip?, victory_end                             #
#                Game_Troop: check_boss                                        #
#                Game_Actor: gain_exp_cpv, last_level_exp                      #
#                Scene_Battle: close_status_window, exp_window_update,         #
#                              update_window_rates, update_scores,             #
#                              show_victory_windows, create_leveled_windows,   #
#                              pack_and_send, remove_sprite, drop_items        #
#                RPG::UsableItem: karma_modif                                  #
#                RPG::Enemy: add_drops                                         #
#                DataManager: make_extra_drops                                 #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script requires you to set several settings for the script to work     #
#  properly.  The screen modifies the end of battle to allow a victory screen  #
#  to appear.  This script also has several notebox tags that can be added to  #
#  define changes to the grade and one note tag that will allow you to define  #
#  additional monster drops.                                                   #
###-----                                                                -----###
#                                                                              #
#      Monster Notebox Tags:                                                   #
#                                                                              #
#   drop[i:1:1:100] -or- drop[i:1:1]                                           #
#               This allows you to add drops to an enemy.  You can use either  #
#               of the two forms for this.  There are 4 arguments.  The first  #
#               argument is the type of item to drop and must be "i", "a", or  #
#               "w" for "item", "armor", or "weapon".  The second is the ID    #
#               of the item to be dropped.  The third is the drop ratio.       #
#               this is a 1 in "x" chance.  You can use any number with        #
#               higher numbers making the drop more uncommon.  The final       #
#               option does not need to be present.  This is a score option.   #
#               The player's score must be this number or above to have a      #
#               chance to get the drop.                                        #
#   score[1]  - This is the score that you get for killing a monster.  You     #
#               can set the "1" to any value.  When the monster is defeated,   #
#               this value is added to the grade at the end of battle.         #
#   onehit[1]  - This is the score added for killing a monster with a single   #
#                hit.  Note that skills with multiple hits will NOT activate   #
#                this unless the monster is killed with the FIRST hit.  Also   #
#                note that skills with the "death" effect will NOT activate    #
#                this.  You can set the "1" to any value.  The default 1-hit   #
#                kill value is defined in the config section.  This value      #
#                OVERRIDES the default 1-hit kill value on the monster it is   #
#                set on.                                                       #
###-----                                                                -----###
#                                                                              #
#      Item and Skill Notebox Tags:                                            #
#                                                                              #
#   score[+1]  - This can be used in a skill or item notebox to set the        #
#                adjusted score when the skill or item is used.  For example,  #
#                you can use "score[-20]" for a forbidden magic that will      #
#                decrease your grade at the end of battle.  You can use "+"    #
#                or "-" values and you can use any numeric value for the       #
#                score change.                                                 #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP       # Do not edit                                                  #
module VICTORY  #  these two lines.                                            #
#                                                                              #
###-----                                                                -----###
# This is the switch used to skip all change in music during a battle.  The    #
# victory screen will still show, but the music will not change when starting  #
# or ending the battle while this switch is on.                                #
SKIP_SWITCH = 5 # Default = 5                                                  #
#                                                                              #
# This determines if a music is played at the end of battle.  If you do not    #
# want a special victory music, set the value below to "false" without the     #
# quotes.  If you just want silence, set the music name to "nil" without the   #
# quotes.  MSX_VOL and MSX_PIT are the volume and pitch of the music.          #
USE_MUSIC = true # Defalt = true                                               #
VICTORY_MUSIC = "Scene4" # Default = "Scene4"                                  #
MSX_VOL = 100 # Default = 100                                                  #
MSX_PIT = 100 # Default = 100                                                  #
#                                                                              #
# This determines if a ME is used at the end of battle.  The ME will be played #
# before the music above.  Set this to false to turn it off.                   #
USE_ME = false # Default = false                                               #
#                                                                              #
# These are the visual settings to use for the victory screen.  The first      #
# three settings are for the colour of the exp gauges.  The first two are the  #
# normal exp gauge colours, the third one is the colour to use for the exp     #
# added at the end of battle.                                                  #
EXP_GAUGE_1 = 30 # Default = 30                                                #
EXP_GAUGE_2 = 31 # Default = 31                                                #
EXP_ADDED = 17 # Default = 17                                                  #
#                                                                              #
# This setting determines if you want to flip the two lower parts of the       #
# victory screen.  By default, rank, exp and money go on the left and spoils   #
# go on the right, but if this is set to true it flips that.                   #
FLIP_LOWER = false # Default = false                                           #
#                                                                              #
# These values define how the player's hp and mp recover after leveling.  You  #
# can change these based on how you want these values to heal when a character #
# levels up.                                                                   #
#  0 = Characters do not heal hp and mp when they level.                       #
#  1 = Current hp or mp is increased based on the new hp or mp.                #
#  2 = Hp and mp are restored to the max value after level up.                 #
HP_HEAL_TYPE = 0 # Default = 0                                                 #
MP_HEAL_TYPE = 0 # Default = 0                                                 #
#                                                                              #
# These are the text settings for the engine.  They are the pieces of info     #
# shown in the different windows at the end of battle.  Set these to the bits  #
# of text you want them to show.                                               #
LEVEL_UP = "Level Up!!" # Default = "Level Up!!"                               #
SPOILS = "Spoils" # Default = "Spoils"                                         #
EXP_NAME = "EXP" # Default = "EXP"                                             #
DEALT_NAME = "Dealt" # Default = "Dealt"                                       #
RECIEVED_NAME = "Recieved" # Default = "Recieved"                              #
TURNS_NAME = "Turns" # Default = "Turns"                                       #
RANK_NAME = "Grade" # Default = "Rank"                                         #
NO_DROPS = "No drops recieved" # Default = "No drops recieved"                 #
#                                                                              #
###-----                                                                -----###
# The following are setting related to the level up windows that display after #
# the victory screen.  They can be adjusted as desired.                        #
#                                                                              #
# Sets if level ups should be displayed after the victory screen.  Set this to #
# false if you don't want these to display.                                    #
LVL_UP_ENABLE = true # Default = true                                          #
#                                                                              #
# This is the sound effect and the volume and pitch of the sound effect that   #
# played when a level up screen is displayed.  If you do not want to use a     #
# sound effect, set the first setting to "nil" without the quotes.             #
LVL_SFX = "Item3" # Default = "Item3"                                          #
LVL_VOL = 80 # Default = 80                                                    #
LVL_PIT = 100 # Default = 100                                                  #
#                                                                              #
# These bits of text are the strings that display when a character learns new  #
# skills.  The lower one displays a number in the place of "%s" and will give  #
# an error if you do not have "%s" somewhere in the string.                    #
NEW_SKILLS = "Learned:" # Default = "Learned:"                                 #
MORE_SKILLS = "And %s more skills" # Default = "And %s more skills"            #
#                                                                              #
###-----                                                                -----###
# The following are the settings for determining rank and rewards at the end   #
# of battle.  The rank system can get used to reward the player for doing well #
# in battle by increasing exp or drop rate a little.  Each setting is          #
# explained a little bit more below.                                           #
#                                                                              #
# Determines if rank images are being used.  If set to true, an image will be  #
# used for showing the rank instead of the default text.  Image names are      #
# created using the below file name PLUS the rank name.  For example, if you   #
# set the file name to "Rank" and you get rank "C", it will try to find a file #
# named "RankE".                                                               #
USE_IMAGES = false # Default = false                                           #
IMAGE_NAME = "Rank" # Default = "Rank"                                         #
#                                                                              #
# The sound effect to play with images, and it's pitch and volume.  If you do  #
# not want a sound effect, set the name to "nil" without the quotes.           #
IMAGE_SFX = "Shot2" # Default = "Shot2"                                        #
SFX_VOL = 100 # Default = 100                                                  #
SFX_PIT = 100 # Default = 100                                                  #
#                                                                              #
# These are the ranks the player can recieve and the rewards associated with   #
# them.  There are 6 settings for each rank.  Please note however, the ranks   #
# must be IN ORDER from LOWEST to HIGHEST in order to work properly.  The      #
# settings are as follows:                                                     #
#    ["Rank",  points,  exp rate,  gold rate,  drop rate,  colour],            #
# Rank - This is the name of the rank in quotes.  This must be in quotes.      #
# points - The minimum number of points to achieve this rank.  Make sure the   #
#          lowest one is set to "0".                                           #
# exp rate - The rate to increase or decrease exp at the end of battle.  The   #
#            normal value is 100.                                              #
# gold rate - The rate to increase or decrease gold at the end of battle.  The #
#             normal value is 100.                                             #
# drop rate - The rate to increase or decrease drop rate at the end of battle. #
#             The normal value is 100.  Note that this does not increase the   #
#             number of times an item can drop, it just increases the chance   #
#             for it to drop.                                                  #
# colour - This is the colour the rank shows up on the victory screen.         #
RANKS =[ # Do not edit this line.                                              #

  ["E",   0, 100, 100, 100, 18],
  ["D", 100, 100, 105, 100, 20],
  ["C", 150, 100, 110, 105,  4],
  ["B", 250, 105, 110, 110, 21],
  ["A", 400, 115, 115, 115,  3],
  ["S", 700, 125, 125, 125, 17],
  
] # Do not edit this line.                                                     #
#                                                                              #
# These are the damage ratios and the points to recieve for each one.  Points  #
# are ADDED for EACH damage ratio the actual damage is BETTER than.  For       #
# example, if the player takes 140 damage and deals 200 damage, the damage     #
# ratio would be 142 and the player would get any points for values lower than #
# that.  This is the best way to determine the number of points a player gets. #
# Each line is set up with the damage ratio on the left and the points on the  #
# right side, like so:                                                         #
#    [Damage,  Point],                                                         #
DAMAGE_POINTS =[ # Do not edit this line.                                      #

  [ 50,  20],
  [ 80,  30],
  [100,  50],
  [150,  75],
  [200, 100],
  [300, 200],

] # Do not edit this line.                                                     #
#                                                                              #
# These are the point values of certain other things that can be done in       #
# battle.  If you do not want to use these, set them to "0".                   #
#                                                                              #
# Points for killing all foes in a single turn.                                #
SINGLE_TURN = 150 # Default = 150                                              #
# Points for killing a boss (collapse type in features.  Only added once.      #
BOSS_POINTS = 200 # Default = 200                                              #
# Points for taking no damage in the battle.                                   #
NO_DAMAGE = 100 # Default = 100                                                #
# Points for having full HP at the end of battle.                              #
FULL_HP = 50 # Default = 50                                                    #
# Points added for dealing a 1 hit kill to the foe.  Does not work when death  #
# is applied by the skill or item, just 1 hit kill via damage.                 #
ONE_HIT = 40 # Default = 40                                                    #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      A note to scripters:                                                    #
#  As of version 2.0 I have made it possible to add custom score items to be   #
#  used in battle.  These scores are handled by the "Grade" module.  If you    #
#  have created a new score item you want to use, you can add it to the Grade  #
#  module by using the script call "Grade.new_score(:foo, Bar)" where ":foo"   #
#  is the key you will use to access the object and "Bar" is the name of the   #
#  new objects class (in this case, the defining line for the object would be  #
#  "class Bar < Score_Base").  You can then reach this score object at any     #
#  time by using the script call "Grade.score[:foo]".  To see the base score   #
#  object or any of the pre-made score object, scroll down.  The score         #
#  objects have been placed at the top of the script.                          #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end  ## Close the VICTORY module.
end  ## Close the CP module.


##-----
## This is a basic score item.  There are 3 main parts to this.  The initialize
## part which defines each of the score variables to be used at the start, the
## update score part, which can be used at any time to get the current score
## the item will add, and the total part, which is used by the Grade module to
## get the final value.  You can use "attr_accessor" to create values that can
## be adjusted at any time or you can create methods to adjust different aspects
## of the score object.
##-----
class Score_Base  ## A score item.  Holds and adjusts an aspect of score.
  def initialize
    @score = 0  ## Sets the score to 0 at the start.
  end
  
  def update_score  ## Objects used to modify the score.
    return 0
  end
  
  def total  ## Create and return the score.
    update_score
    return @score
  end
end

class Score_Damage < Score_Base
  attr_accessor :dealt
  attr_accessor :recieved
  attr_accessor :onehit
  
  def initialize  ## Holds dealt and recieved damage as well as one hit scores.
    super         ## Creates a score based on dealt and recieved ratio.
    @dealt = 0
    @recieved = 0
    @onehit = 0
  end
  
  def update_score
    res = super
    if @recieved == 0
      CP::VICTORY::DAMAGE_POINTS.each {|point| res += point[1]}
    else
      dr = (@dealt * 100 / @recieved)
      CP::VICTORY::DAMAGE_POINTS.each do |point|
        next if dr < point[0]
        res += point[1]
      end
    end
    res += CP::VICTORY::NO_DAMAGE if @recieved == 0
    res += @onehit
    @score = res
  end
end

class Score_HP < Score_Base
  def initialize  ## Holds the hp at the start of battle.
    super         ## Not technically used, but checks max hp at end of battle.
    @start_hp = get_party_hp
  end
  
  def get_party_hp
    return 0 if $game_party.battle_members.empty?
    result = 0
    $game_party.battle_members.each do |member|
      result += member.hp
    end
    return result
  end
  
  def get_max_hp
    return 0 if $game_party.battle_members.empty?
    result = 0
    $game_party.battle_members.each do |member|
      result += member.mhp
    end
    return result
  end
  
  def update_score
    res = super
    res += CP::VICTORY::FULL_HP if get_party_hp == get_max_hp
    @score = res
  end
end

class Score_Troop < Score_Base
  def update_score  ## Gets score values from the existance of boss monsters
    res = super     ## as well as adding custom scores per monster.
    res += CP::VICTORY::BOSS_POINTS if $game_troop.check_boss
    res += CP::VICTORY::SINGLE_TURN if $game_troop.turn_count == 1
    $game_troop.members.each {|foe| res += foe.add_score}
    @score = res
  end
end

class Score_Skill < Score_Base
  attr_accessor :karma
  
  def initialize
    super
    @karma = 0
  end
  
  def update_score
    res = super
    res += @karma
    @score = res
  end
end

module Grade
  def self.reset  ## Holds score objects, score, and grades.
    @rate = CP::VICTORY::RANKS[0]
    @score = 0
    create_score_items
  end
  
  def self.create_score_items  ## Creates the default score items.
    @score_items = {}
    new_score(:damage, Score_Damage)
    new_score(:hp,     Score_HP)
    new_score(:troop,  Score_Troop)
    new_score(:skill,  Score_Skill)
  end
  
  def self.new_score(key, scr)  ## Adds a custom score item.
    @score_items[key] = scr.new
  end
  
  def self.update_score  ## Creates a score.
    return 0 if @score_items.empty?
    val = 0
    @score_items.each do |key, score|
      val += score.total
    end
    @score = val
  end
  
  def self.update_rate  ## Updates the rank and grade.
    update_score
    rank_top = 0
    CP::VICTORY::RANKS.each do |rank|
      next if rank[1] > @score
      if rank[1] > rank_top
        @rate = rank
        rank_top = rank[1]
      end
    end
  end
  
  def self.score  ## Returns the score.
    return @score
  end
  
  def self.rate(key = nil)  ## Gets bits of all of the rate.
    update_rate
    case key
    when :exp
      return @rate[2]
    when :gold
      return @rate[3]
    when :drop
      return @rate[4]
    else
      return @rate
    end
  end
  
  def self.score_items  ## Gets all score items for usage.
    return @score_items
  end
end

##-----
## End of score object.  The rest of the script is below.
##-----

module CP
module VICTORY
SCORE  = /SCORE\[(\d+)\]/i
KARMA  = /SCORE\[(\+|\-)?(\d+)\]/i
DROPS  = /DROP\[(\w+):(\d+):(\d+):?(\d*)\]/i
ONEHIT = /ONEHIT\[(\d+)\]/i
end  ## Used for added drops.
end

$imported = {} if $imported == nil
$imported["CP_VICTORY"] = 2.1

module BattleManager
  class << self
  
  ## Aliased to add certain new settings to the module.
  alias setup_cp_vict setup unless $@
  def setup(troop_id, can_escape = true, can_lose = false)
    Grade.reset
    setup_cp_vict(troop_id, can_escape, can_lose)
    @victory = false
    @played_bgm = 0
    @old_levels = {}; @old_skills = {}
    $game_party.all_members.each do |actr|
      id = actr.actor_id; lvl = actr.level; skl = actr.skills
      @old_levels[id] = lvl; @old_skills[id] = skl
    end
  end
  
  ## Gets the level or skills of the actors from before battle.
  def old_levels(id); return @old_levels[id]; end
  def old_skills(id); return @old_skills[id]; end
  
  ## Helps determine if the victory screen is active.
  def victory_phase?
    @phase == :victory
  end
  
  ## Determine if all musics should be skipped.
  def skip?
    $game_switches[CP::VICTORY::SKIP_SWITCH]
  end
  
  ## Aliased to skip bgm change if the switch is flipped.
  alias play_battle_bgm_cpv play_battle_bgm unless $@
  def play_battle_bgm
    play_battle_bgm_cpv unless skip?
  end
  
  ## Overwritten for the new victory screen.
  def process_victory
    return if @victory; @victory = true
    $game_system.battle_end_me.play if CP::VICTORY::USE_ME && !skip?
    RPG::BGM.fade(500) unless skip? || CP::VICTORY::USE_ME
    20.times do; Graphics.update; end
    SceneManager.scene.close_status_window
    Audio.return_audio if $imported["CP_CROSSFADE"]
    play_battle_end_me unless skip?  ## Skip the bgm change again.
    @phase = :victory
    SceneManager.scene.show_victory_windows
    exp = gain_exp
    gold = gain_gold
    gain_drop_items
    turns = $game_troop.turn_count
    dlt = Grade.score_items[:damage].dealt
    rcv = Grade.score_items[:damage].recieved
    SceneManager.scene.update_scores(dlt, rcv, turns)
    SceneManager.scene.update_window_rates(exp, gold, Grade.rate[4])
    SceneManager.scene.exp_window_update(exp)
    return true
  end
  
  ## Added to actually leave battle.
  def victory_end
    RPG::BGM.fade(500) unless skip?
    20.times do; Graphics.update; end
    SceneManager.return
    battle_end(0)
    replay_bgm_and_bgs unless skip? || $BTEST
  end
  
  ## Skipped if music is not made to change.
  def play_battle_end_me
    return if @played_bgm > 1
    @played_bgm += CP::VICTORY::USE_ME ? 1 : 2
    Audio.bgm_stop
    if CP::VICTORY::USE_MUSIC
      mus = CP::VICTORY::VICTORY_MUSIC
      vol = (CP::VICTORY::USE_ME && @played_bgm == 1) ? 0 : CP::VICTORY::MSX_VOL
      pit = CP::VICTORY::MSX_PIT
      RPG::BGM.new(mus, vol, pit).play unless mus.nil?
    else
      $game_system.battle_end_me.play
      replay_bgm_and_bgs unless $BTEST
    end
  end
  
  ## Adjusts the gold rate.
  def gain_gold
    if $game_troop.gold_total > 0
      rate = Grade.rate(:gold)
      gold = $game_troop.gold_total
      gold = gold * rate / 100
      $game_party.gain_gold(gold)
    else
      gold = 0
    end
    return gold
  end
  
  ## Adjusts the drop rate.
  def gain_drop_items
    drops = []
    rate = Grade.rate(:drop)
    $game_troop.make_drop_items(rate).each do |item|
      $game_party.gain_item(item, 1)
      drops.push(item)
    end
    SceneManager.scene.drop_items(drops)
  end
  
  ## Adjusts the exp rate.
  def gain_exp
    rate = Grade.rate(:exp)
    $game_party.all_members.each do |actor|
      actor.gain_exp_cpv($game_troop.exp_total, rate)
    end
    return $game_troop.exp_total * rate / 100
  end

  end
end

class Game_Troop < Game_Unit
  ## Checks if a monster has the boss kill flag set.
  def check_boss
    members.each do |enemy|
      next unless enemy.collapse_type == 1
      return true
    end
    return false
  end
  
  ## Adjusted drop rate.
  def make_drop_items(rate = 100)
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_items(rate) }
  end
end

class Game_Battler < Game_BattlerBase
  ## Aliased to add damage dealt and recieved to a value for later.
  alias exec_damage_cpv execute_damage unless $@
  def execute_damage(user)
    if @result.hp_damage > 0
      i = [@result.hp_damage, hp].min
      Grade.score_items[:damage].dealt += i if enemy?
      Grade.score_items[:damage].recieved += i if !enemy?
      if hp == mhp && i >= mhp && enemy?
        Grade.score_items[:damage].onehit += @one_hit
      end
    end
    exec_damage_cpv(user)
  end
end

class Game_Enemy < Game_Battler
  attr_accessor :add_score
  attr_accessor :one_hit
  
  ## Gets the default added points for an enemy.
  alias cp_gbv_initialize initialize unless $@
  def initialize(index, enemy_id)
    cp_gbv_initialize(index, enemy_id)
    enemy = $data_enemies[@enemy_id]
    @add_score = enemy.add_score
    @one_hit = enemy.one_hit
  end
  
  ## The actual adjusted drop rate.
  def make_drop_items(rate = 100)
    cpi = rate.to_f / 100
    enemy.drop_items.inject([]) do |r, di|
      if di.kind > 0 && rand * di.denominator < drop_item_rate * cpi
        if Grade.score >= di.req_grade
          r.push(item_object(di.kind, di.data_id))
        else
          r
        end
      else
        r
      end
    end
  end
end

class Game_Actor < Game_Battler
  attr_reader :actor_id
  
  alias cp_gv_level_up level_up unless $@
  def level_up
    tmp1 = mhp
    tmp2 = mmp
    cp_gv_level_up
    heal1 = mhp - tmp1
    heal2 = mmp - tmp2
    case CP::VICTORY::HP_HEAL_TYPE
    when 1; self.hp += heal1
    when 2; self.hp = mhp
    end
    case CP::VICTORY::MP_HEAL_TYPE
    when 1; self.mp += heal2
    when 2; self.mp = mmp
    end
  end
  
  ## Just made a whole new exp event here.  Adjusts the rate.
  def gain_exp_cpv(exp, vic_rate = 100)
    change_exp(self.exp + (exp * vic_rate * final_exp_rate / 100).to_i, false)
  end
  
  ## Determines the exp for the last level.
  def last_level_exp
    return 0 if @level <= 0
    return exp_for_level(@level - 1)
  end
end

class Scene_Battle < Scene_Base
  if $imported["YSA-PCTB"]
  alias cp_bv_fix_yami_pctb update_pctb_speed unless $@
  def update_pctb_speed
    return if BattleManager.victory_phase?
    cp_bv_fix_yami_pctb
  end
  end
  
  ## Overwritten to stop stuff from happening during the victory phase.
  def update
    super
    if BattleManager.in_turn?
      process_event
      process_action
    end
    BattleManager.judge_win_loss unless BattleManager.victory_phase?
    if BattleManager.victory_phase?
      if @victory_score.done and @victory_score.active
        sfx = CP::VICTORY::IMAGE_SFX
        vol = CP::VICTORY::SFX_VOL
        pit = CP::VICTORY::SFX_PIT
        RPG::SE.new(sfx, vol, pit).play unless sfx.nil?
        @victory_score.active = false
        @victory_item.active = true
      end
    end
  end
  
  ## Terminates the sprites and extra windows at the end of battle.
  alias cp_gv_dispose_all_windows dispose_all_windows unless $@
  def dispose_all_windows
    remove_sprite
    cp_gv_dispose_all_windows
  end
  
  ## Applies score loss/gain when using an item/skill.
  alias cp_gv_use_item use_item unless $@
  def use_item
    item = @subject.current_action.item
    Grade.score_items[:skill].karma += item.add_score
    cp_gv_use_item
  end
  
  ## Closes the status window sorta.
  def close_status_window
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.openness = 0 if ivar.is_a?(Window)
    end
  end
  
  ## The next few call stuff.
  def exp_window_update(exp)
    @victory_main.redraw_exp(exp)
    create_leveled_windows
    pack_and_send
  end
  
  def update_window_rates(exp, gold, item)
    @victory_rank.get_rates(exp, gold)
    @victory_item_top.get_rates(item)
  end
  
  def update_scores(dealt, recieved, turns)
    @victory_score.draw_score(CP::VICTORY::DEALT_NAME, dealt, 0)
    @victory_score.draw_score(CP::VICTORY::RECIEVED_NAME, recieved, 24)
    @victory_score.draw_score(CP::VICTORY::TURNS_NAME, turns, 48)
    @victory_score.rank_stuff
  end
  
  def show_victory_windows
    @victory_main = Window_VictoryMain.new
    @victory_top = Window_VictoryTop.new
    @victory_score = Window_VictoryScore.new
    @victory_rank = Window_VictoryRank.new
    @victory_item_top = Window_VictoryItemTop.new
    @victory_item = Window_VictoryItem.new
    @victory_main.openness = 0
    @victory_top.openness = 0
    @victory_score.openness = 0
    @victory_rank.openness = 0
    @victory_item_top.openness = 0
    @victory_item.openness = 0
    @victory_main.open
    @victory_top.open
    @victory_score.open
    @victory_rank.open
    @victory_item_top.open
    @victory_item.open
    if CP::VICTORY::USE_IMAGES
      @victory_score.active = true
    else
      @victory_item.active = true
    end
  end
  
  def create_leveled_windows
    @leveled = []
    return if @victory_main.leveled.empty?
    @victory_main.leveled.each {|actor| @leveled.push(Window_LvlUp.new(actor))}
    @leveled.each {|wind| wind.visible = false}
  end
  
  def pack_and_send
    ar1 = [@victory_main, @victory_top, @victory_score, @victory_rank,
           @victory_item_top, @victory_item]
    @victory_item.get_windows(ar1, @leveled)
  end
  
  def remove_sprite
    @victory_score.remove_sprite unless @victory_score.nil? || @victory_score.disposed?
    return if @leveled.nil? || @leveled.empty?
    @leveled.each {|wind| wind.dispose}
  end
  
  ## This pushes the drop items to the drop window.
  def drop_items(drops)
    @victory_item.get_drops(drops)
  end
end

## The main window with the character faces.
class Window_VictoryMain < Window_Selectable
  attr_reader :leveled
  
  def initialize
    super(0, 48, Graphics.width, 152)
    @index = -1
    @leveled = []
    draw_all_items
  end
  
  def draw_all_items
    item_max.times {|i| draw_item(i) }
  end
  
  def redraw_exp(exp)
    item_max.times {|i| draw_exp(i, exp) }
  end
  
  def draw_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    draw_victory_face(actor, rect)
    draw_actor_exp_info(actor, rect.x, rect.y + 104, rect.width)
  end
  
  def draw_victory_face(actor, orect)
    bitmap = Cache.face(actor.face_name)
    rect = Rect.new(actor.face_index % 4 * 96, actor.face_index / 4 * 96, 96, 96)
    fx = (orect.width - 96) / 2
    temp_bit = Bitmap.new(orect.width, orect.height)
    temp_bit.blt(fx, 0, bitmap, rect)
    contents.blt(orect.x, orect.y, temp_bit, temp_bit.rect)
  end
  
  def draw_exp(index, exp)
    actor = $game_party.members[index]
    rect = item_rect(index)
    draw_actor_exp_info(actor, rect.x, rect.y + 104, rect.width, exp)
  end
  
  def draw_actor_exp_info(actor, x, y, width, aexp = 0)
    x += (width - 96) / 2
    width = [width, 96].min
    aexr = aexp * actor.exr
    cexp = actor.exp - actor.current_level_exp
    nexp = actor.next_level_exp - actor.current_level_exp
    if cexp - aexr >= 0
      rate = cexp.to_f / nexp
      rate = 1.0 if rate > 1.0
      gc1 = text_color(CP::VICTORY::EXP_ADDED)
      gc2 = text_color(CP::VICTORY::EXP_ADDED)
      draw_gauge(x, y, width, rate, gc1, gc2)
      cexp -= aexr
      rate = cexp.to_f / nexp
      rate = 1.0 if rate > 1.0
      rate = 1.0 if actor.level == actor.max_level
      gc1 = text_color(CP::VICTORY::EXP_GAUGE_1)
      gc2 = text_color(CP::VICTORY::EXP_GAUGE_2)
      draw_gauge_clear(x, y, width, rate, gc1, gc2)
    else
      rate = 1.0
      gc1 = text_color(CP::VICTORY::EXP_ADDED)
      gc2 = text_color(CP::VICTORY::EXP_ADDED)
      draw_gauge(x, y, width, rate, gc1, gc2)
      cexp = actor.exp - actor.last_level_exp - aexr
      nexp = actor.current_level_exp - actor.last_level_exp
      rate = cexp.to_f / nexp
      gc1 = text_color(CP::VICTORY::EXP_GAUGE_1)
      gc2 = text_color(CP::VICTORY::EXP_GAUGE_2)
      draw_gauge_clear(x, y, width, rate, gc1, gc2)
      change_color(normal_color)
      draw_text(x, y, width, line_height, CP::VICTORY::LEVEL_UP, 1)
      @leveled.push(actor)
    end
  end
    
  def draw_gauge_clear(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
  
  def item_max
    $game_party.battle_members.size
  end
  
  def item_height
    return 128
  end
  
  def col_max
    $game_party.max_battle_members
  end
  
  def spacing
    return 0
  end
end

## The window at the top that says victory stuff.
class Window_VictoryTop < Window_Base
  def initialize
    super(0, 0, Graphics.width, 48)
    draw_title
  end
  
  def draw_title
    title = sprintf(Vocab::Victory, $game_party.name)
    change_color(normal_color)
    draw_text(0, 0, contents.width, line_height, title, 1)
  end
end

## The window that shows rank and score stuff.
class Window_VictoryScore < Window_Base
  attr_accessor :done
  
  def initialize
    side = CP::VICTORY::FLIP_LOWER ? Graphics.width / 2 : 0
    super(side, 200, Graphics.width / 2, Graphics.height - 272)
    @done = false
    setup_image if CP::VICTORY::USE_IMAGES
  end
  
  def update
    super
    unless @rank.nil? or @done or !open?
      @rank.opacity += 25
      @rank.zoom_x -= 0.2
      @rank.zoom_y -= 0.2
      if @rank.zoom_y < 1.0
        @done = true 
        @rank.zoom_x = 1.0
        @rank.zoom_y = 1.0
      end
    end
  end
  
  def setup_image
    @rank = Sprite.new
  end
  
  def hide_image
    @rank.visible = false if @rank
  end
  
  def remove_sprite
    @rank.dispose unless @rank.nil?
  end
  
  def draw_score(name, value, y)
    change_color(system_color)
    draw_text(16, y, contents.width-32, 24, name, 0)
    change_color(normal_color)
    draw_text(16, y, contents.width-32, 24, value, 2)
  end
  
  def rank_stuff
    draw_rank
    draw_image if CP::VICTORY::USE_IMAGES
  end
  
  def draw_image
    ranking = CP::VICTORY::IMAGE_NAME + Grade.rate[0]
    @rank.bitmap = Cache.system(ranking)
    @rank.ox = @rank.bitmap.width / 2
    @rank.oy = @rank.bitmap.height / 2
    @rank.opacity = 0
    @rank.zoom_x = 5.0
    @rank.zoom_y = 5.0
    @rank.x = x + width - padding - 16 - @rank.bitmap.width / 2
    @rank.y = y + height - padding - 16
    @rank.z = z + 10
  end
  
  def draw_rank
    color = Grade.rate[5]
    rank = Grade.rate[0]
    change_color(system_color)
    contents.font.size = 32
    fs = contents.font.size
    draw_text(16, contents.height-fs, contents.width-32, fs, CP::VICTORY::RANK_NAME, 0)
    change_color(normal_color) if color.nil?
    change_color(text_color(color)) unless color.nil?
    draw_text(16, contents.height-fs, contents.width-32, fs, rank, 2) unless CP::VICTORY::USE_IMAGES
  end
end

## The window that shows exp and gold.
class Window_VictoryRank < Window_Base
  def initialize
    side = CP::VICTORY::FLIP_LOWER ? Graphics.width / 2 : 0
    super(side, Graphics.height - 72, Graphics.width / 2, 72)
  end
  
  def get_rates(exp, gold)
    draw_object(Grade.rate[2], CP::VICTORY::EXP_NAME, exp, 0)
    draw_object(Grade.rate[3], Vocab.currency_unit, gold, 24)
  end
  
  def draw_object(rate, name, value, y)
    change_color(normal_color)
    draw_text(16, y, contents.width - 32, 24, value, 0)
    n = contents.text_size(value).width
    change_color(system_color)
    draw_text(n + 20, y, contents.width - n - 36, 24, name, 0)
    change_color(normal_color)
    text = rate.to_s + "%"
    draw_text(16, y, contents.width - 32, 24, text, 2)
  end
end

## The window that shows drop rate.
class Window_VictoryItemTop < Window_Base
  def initialize
    side = CP::VICTORY::FLIP_LOWER ? 0 : Graphics.width / 2
    super(side, 200, Graphics.width / 2, 48)
  end
  
  def get_rates(rate)
    change_color(system_color)
    draw_text(16, 0, contents.width-32, 24, CP::VICTORY::SPOILS, 0)
    change_color(normal_color)
    text = rate.to_s + "%"
    draw_text(16, 0, contents.width-32, 24, text, 2)
  end
end

## The window that shows items.  You can scroll through the items in it.
class Window_VictoryItem < Window_Selectable
  def initialize
    side = CP::VICTORY::FLIP_LOWER ? 0 : Graphics.width / 2
    super(side, 248, Graphics.width / 2, Graphics.height - 248)
    @index = 0
  end
  
  def item_max
    @data ? @data.size : 0
  end
  
  def draw_all_items
    return super if item_max > 0
    draw_null
  end
  
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y)
      draw_item_number(rect, index)
    end
  end
  
  def draw_null
    rect = item_rect(0)
    rect.width -= 4
    draw_text(rect, CP::VICTORY::NO_DROPS, 1)
  end
  
  def draw_item_number(rect, index)
    draw_text(rect, sprintf(":%2d", @number[index]), 2)
  end
  
  def get_drops(drops)
    @data = []
    @number = []
    for i in 0...drops.size
      ind = @data.index(drops[i])
      if ind.nil?
        @data.push(drops[i])
        @number.push(1)
      else
        @number[ind] += 1
      end
    end
    self.refresh
  end
  
  def get_windows(ar1, ar2)
    @done = 0
    @ar1 = ar1
    @ar2 = ar2
  end
  
  def process_handling
    return unless open? && active
    BattleManager.victory_end if Input.trigger?(:B)
    check_leveled_up if Input.trigger?(:C)
  end
  
  def check_leveled_up
    @done = 0 if @done.nil?; @done += 1
    return BattleManager.victory_end unless CP::VICTORY::LVL_UP_ENABLE
    return BattleManager.victory_end if @ar2.nil?
    return BattleManager.victory_end if @done > @ar2.size
    sfx = CP::VICTORY::LVL_SFX
    vol = CP::VICTORY::LVL_VOL
    pit = CP::VICTORY::LVL_PIT
    RPG::SE.new(sfx, vol, pit).play unless sfx.nil?
    @ar1.each {|wind| wind.visible = false}
    @ar2.each {|wind| wind.visible = false}
    @ar1[2].hide_image
    @ar2[@done - 1].visible = true
  end
  
  def update
    super
    if Audio.bgm_pos != 0
      BattleManager.play_battle_end_me
    end
  end
  
  def refresh
    contents.clear
    create_contents
    draw_all_items
  end
end

## Modifies a skill's score modification when used.
class RPG::UsableItem < RPG::BaseItem
  def add_score
    karma_modif if @add_score.nil?
    return @add_score
  end
  
  def karma_modif
    @add_score = 0
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::VICTORY::KARMA
        @add_score = ($1.to_s + $2.to_s).to_i
      end
    end
  end
end

class RPG::Enemy::DropItem
  def req_grade
    return @req_grade ? @req_grade : 0
  end
  
  def req_grade=(val)
    @req_grade = val
  end
end

## Modifies the enemy's drops from the database.
class RPG::Enemy < RPG::BaseItem
  def add_score
    add_drops if @add_score.nil?
    return @add_score
  end
  
  def one_hit
    add_drops if @one_hit.nil?
    return @one_hit
  end
  
  def drop_items
    add_drops if @added_drops.nil?
    return @drop_items
  end
  
  def add_drops
    @added_drops = true
    @add_score = 0
    @one_hit = CP::VICTORY::ONE_HIT
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::VICTORY::DROPS
        temp = RPG::Enemy::DropItem.new
        case $1.to_s
        when "I", "i"
          temp.kind = 1
        when "W", "w"
          temp.kind = 2
        when "A", "a"
          temp.kind = 3
        end
        temp.data_id = $2.to_i
        temp.denominator = $3.to_i
        temp.req_grade = $4.to_i
        @drop_items.push(temp)
      when CP::VICTORY::SCORE
        @add_score = $1.to_i
      when CP::VICTORY::ONEHIT
        @one_hit = $1.to_i
      end
    end
  end
end

## Creates windows at the end of the victory screen that display level up stats.
class Window_LvlUp < Window_Base
  def initialize(actor)
    @actor = actor  ## Gets the actor, old level, and new skills.
    @old_level = BattleManager.old_levels(actor.actor_id)
    @skills = actor.skills - BattleManager.old_skills(actor.actor_id)
    create_params  ## Creates all params.  Here for custom params.
    super(0, 0, box_width, box_height)  ## Creates and moves the box.
    self.x = (Graphics.width - width) / 2
    self.y = (Graphics.height - height) / 2
    refresh
  end
  
  ## Creates the entire list of params.
  def create_params
    @params = []
    8.times do |i|
      p1 = @actor.class.params[i, @old_level]
      p2 = @actor.class.params[i, @actor.level]
      vocab = Vocab.param(i)
      add_param(vocab, p1, p2)
    end
  end
  
  ## Adds a param to the list.
  def add_param(vocab, p1, p2)
    @params.push([vocab, p1, p2])
  end
  
  ## Width of the box based on whether any new skills were learned.
  def box_width
    wd = @skills.empty? ? 240 : 480
    return wd + standard_padding * 2
  end
  
  ## Height of the box based on total params.
  def box_height
    return line_height + 104 + line_height * (@params.size + 1)
  end
  
  ## Refreshed the box contents.
  def refresh
    contents.clear
    draw_header
    draw_face_area(line_height * 1.5)
    draw_attr_area(0, line_height * 2 + 104)
    draw_skill_area(240, line_height * 2 + 104)
  end
  
  ## Draws the level up header.
  def draw_header
    x = (contents.width - 240) / 2
    ml = 0
    p1 = @old_level
    p2 = @actor.level
    ml = contents.text_size(p1).width if contents.text_size(p1).width > ml
    ml = contents.text_size(p2).width if contents.text_size(p2).width > ml
    ml += 4
    mo = 236 - ml
    change_color(system_color)
    draw_text(x + 2, 0, mo - ml - 22, line_height, CP::VICTORY::LEVEL_UP, 0)
    draw_text(x + mo - 22, 0, 22, line_height, "→", 1)
    change_color(normal_color)
    draw_text(x + mo - ml - 22, 0, ml, line_height, p1, 2)
    change_color(power_up_color)
    draw_text(x + mo, 0, ml, line_height, p2, 2)
  end
  
  ## Draws the params section.
  def draw_attr_area(x, y)
    ml = 0
    @params.each do |p|  ## Find the wides param.
      ml = contents.text_size(p[1]).width if contents.text_size(p[1]).width > ml
      ml = contents.text_size(p[2]).width if contents.text_size(p[2]).width > ml
    end
    ml += 4  ## Set params box size.
    mo = 236 - ml  ## Last object's location.
    @params.each_with_index do |para, i|
      ylh = y + i * line_height  ## Gets the y location.
      change_color(system_color)  ## Draws the name and arrow.
      draw_text(x + 2, ylh, mo - ml - 22, line_height, para[0], 0)
      draw_text(x + mo - 22, ylh, 22, line_height, "→", 1)
      change_color(normal_color)  ## Draws the old and new stats.
      draw_text(x + mo - ml - 22, ylh, ml, line_height, para[1], 2)
      change_color(para[2] > para[1] ? power_up_color : power_down_color)
      change_color(normal_color) if para[1] == para[2]
      draw_text(x + mo, ylh, ml, line_height, para[2], 2)
    end
  end
  
  def draw_face_area(y)  ## Draws the area with the face, name, and class.
    xi = (contents.width - 216) / 2
    draw_actor_name(@actor, xi + 104, y + 0 * line_height)
    draw_actor_class(@actor, xi + 104, y + 1 * line_height)
    draw_actor_face(@actor, xi + 4, y + 4)
  end
  
  def draw_skill_area(x, y)  ## Draw skill names.
    change_color(system_color)  ## First, draw the skill message.
    draw_text(x + 18, y, 220, line_height, CP::VICTORY::NEW_SKILLS, 1)
    change_color(normal_color)  ## Next, check if there are too many skills.
    if @skills.size > @params.size - 1
      total = @params.size-3
      total.times do |i|
        item = @skills[i]  ## Draws only so many skills.
        draw_item_name(item, x + 18, y + (i + 1) * line_height, true, 220)
      end  ## Draws the final message.
      draw_text(x + 18, y + (@params.size - 2) * line_height, 220, line_height,
                more_skills, 1)
    else
      @skills.each_with_index do |item, i|  ## Draws all skills.
        draw_item_name(item, x + 18, y + (i + 1) * line_height, true, 220)
      end
    end
  end
  
  def more_skills  ## Gets the more skills text.
    more = @skills.size - @params.size
    return sprintf(CP::VICTORY::MORE_SKILLS, more)
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###