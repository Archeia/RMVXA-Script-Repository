# ╔══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Tales of Graces Title System                         │ v1.02 │ (6/07/13) ║
# ╚══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     amicable, for producing mastery graphics for this script
#     YF, passive state code reference
#--------------------------------------------------------------------------
# This script replicates the Title system from the Wii/PS3 game "Tales
# of Graces". It's a somewhat unique system which performs like
# an alternative leveling system.
#
# This script has a high learning curve. Please read the documentation
# and study the examples I've provided in "Titles Volume 1: Basic 
# Package" for information on how to create your own custom titles.
#
# This script modifies actor "Nicknames". Any Nicknames defined in your
# database will not be used.
#
# And as a general rule of thumb: always assume a syntax error is 
# your fault.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.02 : Bugfix: Fixed issue with Death state. (6/07/2013)
# v1.01 : Compatibility Update: "KMS Generic Gauge"
#       : You can now change the rank icons.
#       : Added support for "Mastery" images.
#       : You can now choose whether reserve party members can learn 
#       : potential titles after each battle.
#       : Rearranged some code. 
#       : Updated script call documentation. (6/04/2013)
# v1.00 : Initial release. (6/02/2013)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# You must also install "Titles Volume 1: Basic Package" below this 
# script in the script editor. The Basic Package contains titles
# that this main script uses for New Game examples.
#--------------------------------------------------------------------------
#      What are titles?
#--------------------------------------------------------------------------
#
#    Title Basics
#      Ranks are earned by equipping titles and then collecting SP from
#      battles. Once a rank is earned, it remains in effect even if the
#      affiliated title is removed. Lower ranks are easier to earn,
#      but higher ones tend to be more useful. Swap titles often to
#      get a good variety of effects.
#
#    Rank Effects
#      You can create different rank effects for titles. Actors
#      can learn skills from earning a rank, semi-permanent 
#      stat increases and other custom effects. However,
#      creating your own does require knowledge of Ruby syntax.
#      (In Tales of Graces, titles grant "skills". But since the term
#       "skill" means something different in RPG Makek, skills are
#       called "ranks" in this script.)
#
#    Equipped Effects
#      Some effects are only active when a certain title is equipped;
#      these are known as "equipped effects." They differ from ranks
#      in that they come into play only when the corresponding title
#      is equipped. Knowing which titles to equip for their equipped
#      effects can make the difference in a battle against a tough
#      opponents.
#
#    Acquiring Titles
#      There are two main ways actors earn a title:
#        1) Through a script call.
#        2) After battle if the title's :condition statement is met.
#
#    Mastering Titles
#      If you keep using a title after earning all of its ranks,
#      you'll eventually master it, making any equipped effects
#      rise dramatically in effectiveness. This can be especially 
#      helpful against powerful foes, but you should still focus 
#      your efforts on earning as many ranks as you can, at least
#      early on.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Notetags   
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Notetags are for Enemies only:
#
#   <title sp: n>
#     This tag defines the amount of SP an enemy awards after battle
#     where n is a number value.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Script Calls 
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Script Calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event.
#
#   $game_actors[actor_id].add_title(:symbol)
#     This script call forces an actor to learn a title where actor_id
#     is an actor ID number from your database and :symbol is a 
#     symbol that represents a title. The actor will learn the title
#     regardless of whether it is a potential title or not.
#
#   $game_actors[actor_id].gain_title_sp(value)
#     This script call gives Title SP to a specified actor where 
#     actor_id is an actor ID number from your database and value is 
#     the amount of Title SP to give. This will only give Title SP
#     to the actor's currently equipped title. Using this script call
#     will also trigger the actor's auto-equip title function so keep 
#     that in mind.
#
#   $game_actors[actor_id].gain_sp_all_titles(value)
#     This script call gives Title SP to all of an actor's titles where 
#     actor_id is an actor ID number from your database and value is 
#     the amount of Title SP to give. Using this script call
#     will NOT trigger the actor's auto-equip title function.
#
#--------------------------------------------------------------------------
# The following Script Calls return true or false. They can be used in 
# Conditional Branch "Script" boxes found under Tab 4.
#
#   $game_actors[actor_id].current_title?(:symbol)
#     This script call checks whether an actor has a title equipped 
#     where actor_id is an actor ID number from your database and 
#     :symbol is a symbol that represents a title.
#     Returns true if the actor has that title equipped. Otherwise, false.
#
#   $game_actors[actor_id].title_learned?(:symbol)
#     This script call checks whether an actor has a title learned 
#     where actor_id is an actor ID number from your database and 
#     :symbol is a symbol that represents a title.
#     Returns true if the actor has the title. Otherwise, false.
#
#   $game_actors[actor_id].title_mastered?(:symbol)
#     This script call checks whether an actor has a title mastered 
#     where actor_id is an actor ID number from your database and 
#     :symbol is a symbol that represents a title.
#     Returns true if the title is mastered. Otherwise, false.
#
#--------------------------------------------------------------------------
# The following Script Calls return a value. They can be used in Control 
# Variable "Script" boxes and stored in a specified game variable.
#
#   $game_actors[actor_id].learned_title_count
#     This script call returns the number of titles the actor has 
#     learned where actor_id is an actor ID number from your database 
#     and :symbol is a symbol that represents a title.
#
#   $game_actors[actor_id].mastered_title_count
#     This script call returns the number of titles the actor has 
#     mastered where actor_id is an actor ID number from your database 
#     and :symbol is a symbol that represents a title.
#
#   $game_actors[actor_id].title_rank[:symbol]
#     This script call returns the rank of the specified title where 
#     actor_id is an actor ID number from your database and :symbol 
#     is a symbol that represents a title. Make sure you use square
#     brackets for this script call.
#
#--------------------------------------------------------------------------
#      FAQ   
#--------------------------------------------------------------------------
#  --I got a syntax error! How do I fix it?
#  
#      Protip: A syntax error usually means it's your fault. 
#      You likely mistyped something in the configuration module.
#      Check to make sure you did not miss a comma, a closing bracket,
#      or whatever.
#      
#      The customization for this script is very difficult for newbies. 
#      You should expect errors when you try to create your own titles.
#
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#       DataManager#load_normal_database
#       DataManager#load_battle_test_database
#       BattleManager#gain_gold
#       Game_Actor#initialize
#       Game_Actor#param
#       Game_Actor#xparam
#       Game_Actor#sparam
#       Game_Actor#states
#       Game_Actor#state?
#       Game_Actor#state_addable?
#       Game_Actor#remove_state
#       Window_MenuCommand#add_original_commands
#       Scene_Menu#create_command_window
#       Scene_Menu#on_personal_ok
#
# There are no default method overwrites.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsToGTitleSystem"] = 1.02

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================

module Bubs
  module ToGTitleSystem
  #--------------------------------------------------------------------------
  #     Title SP Vocab
  #--------------------------------------------------------------------------
  TITLE_SP   = "Skill Points"
  TITLE_SP_A = "SP"
  #--------------------------------------------------------------------------
  #     Title Menu Command Settings
  #--------------------------------------------------------------------------
  TITLE_MENU_COMMAND = "Titles"
  #  true : Adds a menu command to the Titles scene
  # false : Does not add a menu command.
  ADD_TITLE_MENU_COMMAND = true 
  #--------------------------------------------------------------------------
  #     Title Messages
  #--------------------------------------------------------------------------
  TITLE_SP_GAINED_MESSAGE = "%d SP received!"
  TITLE_OBTAINED_MESSAGE   = "%s earned the title %s!"
  #--------------------------------------------------------------------------
  #     Title Rank Icons
  #--------------------------------------------------------------------------
  RANK_ACTIVE_ICON = 125      # Iconset index number
  RANK_INACTIVE_ICON = 127    # Iconset index number
  
  #--------------------------------------------------------------------------
  #     Title Mastered Text
  #--------------------------------------------------------------------------
  TITLE_MASTERED_TEXT = "MASTERED!"
  TITLE_MASTERED_A_TEXT = "M"
  TITLE_MASTERED_COLOR = 21     # Windowskin color index
  #--------------------------------------------------------------------------
  #     Title Mastered Image
  #--------------------------------------------------------------------------
  #  true : Use graphic placed in Graphics/System folder for Mastered titles.
  # false : Do not use graphic and use text instead.
  USE_TITLE_MASTERED_IMAGE = true
  TITLE_MASTERED_IMAGE = "mastered5"
  #--------------------------------------------------------------------------
  #     Titles SP Gauge Settings
  #--------------------------------------------------------------------------
  TITLE_SP_GAUGE_COLOR1 = 30    # Windowskin color index
  TITLE_SP_GAUGE_COLOR2 = 31    # Windowskin color index
  #--------------------------------------------------------------------------
  #     Titles SP Generic Gauge Settings
  #--------------------------------------------------------------------------
  # These settings only take effect when the script KMS Generic Gauge
  # is installed.
  GENERIC_GAUGE = { :image      => "GaugeEXP", # Filename in Graphics/System
                    :offset     => [-23, -2],  # Gauge Position Offset [x, y]
                    :len_offset => -4,         # Gauge Length Adjustment
                    :slope      => 30,         # Gauge Slope -89 to 89
                  }
  #--------------------------------------------------------------------------
  #     Title Scene Command Vocab
  #--------------------------------------------------------------------------
  SET_TITLE_TEXT   = "Set Title"
  CHANGE_MODE_TEXT = "Change Mode"
  CURRENT_MODE_TEXT = "Auto-Equip Mode: %s" 
  
  #--------------------------------------------------------------------------
  #     Title Debug Mode
  #--------------------------------------------------------------------------
  #  true : All actors will have all defined titles in a New Game.
  # false : Actors learn titles normally.
  TITLE_DEBUG_MODE = false
  #--------------------------------------------------------------------------
  #     Potential Title Debug Mode
  #--------------------------------------------------------------------------
  # This setting only takes affect if TITLE_DEBUG_MODE is true.
  #
  #  true : All actors start with ALL titles as potential, but unlearned
  #         in title debug mode. This is useful for checking title 
  #         conditions.
  # false : All actors will learn all titles in title debug mode.
  TITLE_DEBUG_POTENTIAL_TITLES_ONLY = false
  #--------------------------------------------------------------------------
  #     Title Debug Messages
  #--------------------------------------------------------------------------
  #  true : Enable console window messages related to this script.
  # false : Disable console window messages related to this script.
  TITLE_DEBUG_MESSAGES = true 
  
  #--------------------------------------------------------------------------
  #     Default Enemy Title SP
  #--------------------------------------------------------------------------
  # If an enemy does not have an SP award defined with <sp_title: n>
  # then enemies will provide this default value.
  DEFAULT_ENEMY_TITLE_SP = 20
  #--------------------------------------------------------------------------
  #     Default Mastery SP
  #--------------------------------------------------------------------------
  # If :mastery_sp is not defined for a title, then :mastery_sp
  # will be defaulted to the value defined here.
  DEFAULT_MASTERY_SP = 4000
  #--------------------------------------------------------------------------
  #     Reserve Party Member Title Learning
  #--------------------------------------------------------------------------
  #  true : All party members, including reserve members, can learn 
  #         titles after a battle.
  # false : Only battle members may learn titles after battle.
  PARTY_RESERVES_TITLE_LEARNING = false
  
  #--------------------------------------------------------------------------
  #     Initial Actor Title
  #--------------------------------------------------------------------------
  # This setting defines the initial title symbol New Game actors
  # start with. An actor will be assigned the title :undefined if an 
  # actor doesn't have an initial title symbol defined here or if
  # the title does not exist.
  INITIAL_TITLE = {
  # actor_id => :symbol,
     1 => :silver_reaper,
     2 => :thunder_fist,
     3 => :wandering_paladin,
     4 => :magic_swordsman,
     5 => :dawns_edge,
     6 => :dark_green_aim,
     7 => :formless_wind,
     8 => :savior_of_joan,
     9 => :graceful_nightmare,
    10 => :star_seer,
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #     Auto-Equip Mode Settings
  #--------------------------------------------------------------------------
  # This setting determines Title Auto-Equip options.
  #
  # If a key is an integer, that integer will determine when a title
  # will automatically switch to another title. For example, if an
  # actor's Mode is set to 3 and the actor's title rank is 3 or above,
  # it will automatically equip another title that is below rank 3.
  #
  # :manual and :mastered are special keys. Their default help description
  # text should be self-explanatory on what they do.
  #
  # Use the newline character \n to define linebreaks for description
  # text.
  #
  # !! IMPORTANT !!
  # The order of the modes in this setting determines the order they
  # are listed in the mode selection window.
  #
  AUTO_EQUIP_MODES = {
  #      key => ["Mode Name", "Help Window Description Text"]
     :manual => ["Manual",   "Turn off auto-equip and equip titles manually."],
           3 => ["Rank 3",   "Auto-equip titles until they reach Rank 3.\n" +
                             "Recommended for beginners."],
           4 => ["Rank 4",   "Auto-equip titles until they reach Rank 4.\n" +
                             "Recommended for those looking to boost stats."],
           5 => ["Rank 5",   "Auto-equip titles until they reach Rank 5.\n" +
                             "Recommended for skill completionists."],
   :mastered => ["Mastered", "Auto-equip titles until they are mastered."],
   
  } # <- Do not delete.
  
  #--------------------------------------------------------------------------
  #     Default Auto-Equip Mode
  #--------------------------------------------------------------------------
  # The mode that all actors are set as in a New Game. Must be a key
  # within the AUTO_EQUIP_MODES hash.
  DEFAULT_AUTO_EQUIP_MODE = 3
  
  #--------------------------------------------------------------------------
  #     Actor Potential Titles
  #--------------------------------------------------------------------------
  # This setting lets you define which titles actors can *POTENTIALLY*
  # learn. This means actors will *not* start out with these titles
  # at the beginning of the game. After each battle, all potentially
  # learnable titles will be checked using the :condition that you
  # defined for the title. If the actor meets the title's :condition
  # statement, then the actor will earn the title.
  #
  # !! IMPORTANT !!
  # The order of the symbols in the actor's POTENTIAL_TITLES array 
  # will determine the display order of titles for the actor in the 
  # Titles Scene.
  POTENTIAL_TITLES ||= {} # <- Leave this alone, do not delete.
  
  # POTENTIAL_TITLES[actor_id] = [:symbol1, :symbol2, etc...]

  # Actor 1
  POTENTIAL_TITLES[1]  = [:silver_reaper, :berserker, :adventurer, :paragon, 
                          :zero_to_hero, :newbie, :ambidextrous, 
                          :axe_adept, :sword_adept, :hammer_adept, :gun_adept, 
                          :survivor, :sole_survivor,:marathon_man, :suave,
                          :all_by_myself, :slime_hunter]
                          
  # Actor 2
  POTENTIAL_TITLES[2]  = [:thunder_fist, :lightning_legs, :adventurer, :paragon,
                          :zero_to_hero, :claw_adept, :millionaire_miser, 
                          :all_by_myself]
                          
  # Actor 3
  POTENTIAL_TITLES[3]  = [:wandering_paladin, :justicar, :adventurer, :paragon, 
                          :zero_to_hero, :spear_adept, :sword_adept, 
                          :all_by_myself]
                          
  # Actor 4
  POTENTIAL_TITLES[4]  = [:magic_swordsman, :mystic_fencer, :adventurer, 
                          :paragon, :zero_to_hero, :sword_adept, 
                          :not_enough_mana, :all_by_myself]
                           
  # Actor 5
  POTENTIAL_TITLES[5]  = [:dawns_edge, :far_east_warrior, :adventurer, :paragon, 
                          :zero_to_hero, :katana_adept, :seasoned_fighter,  
                          :all_by_myself]
  # Actor 6
  POTENTIAL_TITLES[6]  = [:dark_green_aim, :fletcher, :adventurer, :paragon,
                          :zero_to_hero, :bow_adept, :all_by_myself]
                          
  # Actor 7
  POTENTIAL_TITLES[7]  = [:formless_wind, :vagabond, :adventurer, :paragon,
                          :zero_to_hero, :ambidextrous, :sword_adept,
                          :dagger_adept, :traveler, :all_by_myself]
                          
  # Actor 8
  POTENTIAL_TITLES[8]  = [:savior_of_joan, :acolyte, :adventurer, :paragon,
                          :zero_to_hero, :hammer_adept, :blessed, 
                          :not_enough_mana, :all_by_myself]
                          
  # Actor 9
  POTENTIAL_TITLES[9]  = [:graceful_nightmare, :enchantress, :adventurer, 
                          :paragon, :zero_to_hero, :staff_adept,
                          :not_enough_mana, :all_by_myself]
                           
  # Actor 10
  POTENTIAL_TITLES[10] = [:star_seer, :thaumaturge, :adventurer, :paragon,
                          :zero_to_hero, :staff_adept, :not_enough_mana,  
                          :all_by_myself]
                          
  #--------------------------------------------------------------------------
  #     Global Potential Titles
  #--------------------------------------------------------------------------
  # Global potential titles apply to all actors. Any Global potential titles
  # listed in the array will be placed at the bottom of actor title lists.
  GLOBAL_POTENTIAL_TITLES = [:fireproof, :poisonproof]
  
  #--------------------------------------------------------------------------
  #     Title Rank Presets
  #--------------------------------------------------------------------------
  # This setting allows you to create predefined rank settings excluding SP.
  # This should make things easier when typing up rank effects.
  #
  # How to use in TITLE definitions:
  #
  # Simply type the Rank Preset symbol you created in the second
  # element of the rank's array. For example:
  #
  #          SP,  Preset
  #   1 => [100, :xsleep],
  #
  #       At game startup, :xsleep will be converted to:
  #
  #   1 => [100, 22, "X-Sleep", "Sleep Resist +10%", "@state_bonus[6] += -0.10"],
  #   
  # At game startup, the ":xsleep" symbol will automatically be replaced 
  # with the preset elements you defined in RANK_PRESETS.
  #
  # Don't forget the comma!
  RANK_PRESETS = {
    #                 Icon, "Name",     "Description", "Rank Effect"
    :vitality_30   => [32,  "Vitality", "Max HP +30",  "@bonus[:mhp] += 30"],
    :energy_15     => [33,    "Energy", "Max MP +10",  "@bonus[:mmp] += 10"],
    
    #                 Icon, Name, Description, Effect
    :xpoison_10    => [18, "X-Poison",   "Poison Resist +10%",    "@state_bonus[2] += -0.10"],
    :xblind_10     => [19, "X-Blind",    "Blind Resist +10%",     "@state_bonus[3] += -0.10"],
    :xsilence_10   => [20, "X-Silence",  "Silence Resist +10%",   "@state_bonus[4] += -0.10"],
    :xconfuse_10   => [21, "X-Confuse",  "Confuse Resist +10%",   "@state_bonus[5] += -0.10"],
    :xsleep_10     => [22, "X-Sleep",    "Sleep Resist +10%",     "@state_bonus[6] += -0.10"],
    :xparalysis_10 => [23, "X-Paralysis", "Paralysis Resist 10%", "@state_bonus[7] += -0.10"],
    :xstun_10      => [24, "X-Stun",     "Stun Resist +10%",      "@state_bonus[8] += -0.10"],
    
    # The following presets are examples of Rank Effects using @element_bonus.
    # @element_bonus keeps track of accumulated rates bonuses for a
    # defined element ID number. 
    #
    # A value of 0.01 for elemental rates is equal to 1%
    # Since these are element reduction effects, -0.05 means
    # elements of the specified ID will be reduced by 5% damage.
    #                 Icon, "Name",      "Description",        "Rank Effect"
    :xfire_5       => [104, "X-Fire",    "Fire Resist +5%",    "@element_bonus[3] += -0.05"],
    :xice_5        => [105, "X-Ice",     "Ice Resist +5%",     "@element_bonus[4] += -0.05"],
    :xthunder_5    => [106, "X-Thunder", "Thunder Resist +5%", "@element_bonus[5] += -0.05"],
    :xwater_5      => [107, "X-Water",   "Water Resist +5%",   "@element_bonus[6] += -0.05"],
    :xearth_5      => [108, "X-Earth",   "Earth Resist +5%",   "@element_bonus[7] += -0.05"],
    :xwind_5       => [109, "X-Wind",    "Wind Resist +5%",    "@element_bonus[8] += -0.05"],
    :xholy_5       => [110, "X-Holy",    "Holy Resist +5%",    "@element_bonus[9] += -0.05"],
    :xdark_5       => [111, "X-Dark",    "Dark Resist +5%",    "@element_bonus[10] += -0.05"],
    
  # - - - - - - - Create Your Own Presets Below This Line - - - - - - - - - -
    
    
    
    
    
    
  
  
  
  
  
  
  
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  } # <- Do not delete.

  #--------------------------------------------------------------------------
  #     Title Definitions
  #--------------------------------------------------------------------------
  # ALL PREDEFINED TITLES ARE FOUND SEPARATELY FROM THIS SCRIPT!
  #
  # Install "Titles Volume 1: Basic Package" below this script
  # in your script editor list in your script editor.
  #
  # This section is where you define titles, title ranks, title learn
  # conditions, and other settings.
  #
  # Please read the example below provided as TITLE[:example], which is
  # the first title defined in this section. Examine it carefully
  # because this will be somewhat complicated for users who are
  # not familiar with Ruby syntax. 
  #
  # If you are not familiar with Ruby syntax, then you will likely 
  # encounter syntax errors.
  #
  TITLE ||= {} # <- Leave this alone, do not delete.
  #---------------------------
  
  # - - - - - - - Create Your Own Titles Below This Line - - - - - - - - - -
  
  #   TITLE[:title_symbol] = {  ...  }
  
  
  
  
  
  
  
  
  
  
  
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  #---------------------------
  # DO NOT DELETE THIS ENTRY!
  #---------------------------
  TITLE[:undefined] = {
    :name => "Undefined",
    :icon => 0,
    :description => "This title is undefined.",
    :condition => "",
  }
  
  end # module ToGTitleSystem


  #--------------------------------------------------------------------------
  #   Custom Title Conditions
  #--------------------------------------------------------------------------
  # You can define custom condition methods here. Defining them here
  # is equivilant to defining methods in class Game_Actor.
  #
  # This section requires programming knowledge.
  module ToGTitleConditions
  #--------------------------------------------------------------------------
  # sole_survivor?
  #--------------------------------------------------------------------------
  # Determines if the actor is the only person in a party of 2 members
  # or more that survived.
  def sole_survivor?
    bm_size = $game_party.battle_members.size
    bm_alive = $game_party.battle_members.select {|member| member.alive?}.size
    return bm_alive == 1 && bm_size > 1 && self.alive? && self.battle_member?
  end
  

  end # module ToGTitleConditions
end # module Bubs


#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



Bubs::ToGTitleSystem::INITIAL_TITLE.default = :undefined
Bubs::ToGTitleSystem::POTENTIAL_TITLES.default = []
$kms_imported ||= {}

#==============================================================================
# ** Vocab
#==============================================================================
module Vocab
  #--------------------------------------------------------------------------
  # string constants
  #--------------------------------------------------------------------------
  ObtainTitle      = Bubs::ToGTitleSystem::TITLE_OBTAINED_MESSAGE
  ObtainTitleSp    = Bubs::ToGTitleSystem::TITLE_SP_GAINED_MESSAGE
  
  TitleMastered    = Bubs::ToGTitleSystem::TITLE_MASTERED_TEXT
  TitleMastered_A  = Bubs::ToGTitleSystem::TITLE_MASTERED_A_TEXT
  TitleSet         = Bubs::ToGTitleSystem::SET_TITLE_TEXT
  TitleChangeMode  = Bubs::ToGTitleSystem::CHANGE_MODE_TEXT
  TitleCurrentMode = Bubs::ToGTitleSystem::CURRENT_MODE_TEXT
  
  #--------------------------------------------------------------------------
  # new : title_sp
  #--------------------------------------------------------------------------
  def self.title_sp
    Bubs::ToGTitleSystem::TITLE_SP
  end
  
  #--------------------------------------------------------------------------
  # new : title_sp_a
  #--------------------------------------------------------------------------
  def self.title_sp_a
    Bubs::ToGTitleSystem::TITLE_SP_A
  end
  
  #--------------------------------------------------------------------------
  # new : togtitles
  #--------------------------------------------------------------------------
  def self.togtitles
    Bubs::ToGTitleSystem::TITLE_MENU_COMMAND
  end
end




#==========================================================================
# ** DataManager
#==========================================================================
module DataManager

  #--------------------------------------------------------------------------
  # alias : load_normal_database
  #--------------------------------------------------------------------------
  class << self; alias load_normal_database_bubs_togtitles load_normal_database; end
  def self.load_normal_database
    load_normal_database_bubs_togtitles # alias
    
    $data_titles = ToGTitleData.new
  end
  
  #--------------------------------------------------------------------------
  # alias : load_battle_test_database
  #--------------------------------------------------------------------------
  class << self; alias load_battle_test_database_bubs_togtitles load_battle_test_database; end
  def self.load_battle_test_database
    load_battle_test_database_bubs_togtitles # alias
    
    $data_titles = ToGTitleData.new
  end
  
end # module DataManager



#==============================================================================
# ** BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # new : gain_title_sp         # Title SP Acquisition and Level Up Display
  #--------------------------------------------------------------------------
  def self.gain_title_sp
    $game_party.members.each do |actor|
      actor.gain_title_sp($game_troop.title_sp_total)
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : gain_gold             # Gold Acquisition and Display
  #--------------------------------------------------------------------------
  class << self; alias gain_gold_bubs_togtitles gain_gold; end
  def self.gain_gold
    gain_title_sp
    display_title_sp
    
    gain_gold_bubs_togtitles # alias
    
    check_title_conditions
    display_titles_just_learned
  end
  
  #--------------------------------------------------------------------------
  # new : display_title_sp             # Display SP Earned
  #--------------------------------------------------------------------------
  def self.display_title_sp
    if $game_troop.title_sp_total > 0
      text = sprintf(Vocab::ObtainTitleSp, $game_troop.title_sp_total)
      $game_message.add('\.' + text)
    end
  end
  
  #--------------------------------------------------------------------------
  # new : check_title_conditions 
  #--------------------------------------------------------------------------
  def self.check_title_conditions
    if Bubs::ToGTitleSystem::PARTY_RESERVES_TITLE_LEARNING
      actors = $game_party.all_members
    else
      actors = $game_party.members
    end
    
    for actor in actors
      actor.check_title_conditions
    end
  end
  
  #--------------------------------------------------------------------------
  # new : check_title_conditions 
  #--------------------------------------------------------------------------
  def self.display_titles_just_learned
    for actor in $game_party.all_members
      for title in actor.titles_just_learned
        text = sprintf(Vocab::ObtainTitle, actor.name, title.name)
        $game_message.add(text)
      end
    end
    wait_for_message
  end
  
end # module BattleManager




#==============================================================================
# ** ToGTitle
#==============================================================================
class ToGTitle
  attr_accessor :symbol
  attr_accessor :name
  attr_accessor :icon
  attr_accessor :description
  attr_accessor :condition
  attr_accessor :on_title_set
  attr_accessor :on_title_unset
  attr_accessor :ranks
  attr_accessor :states
  attr_accessor :mastery_states
  attr_accessor :mastery_sp
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    @symbol = :none
    @name = ""
    @description = ""
    @condition = ""
    @on_title_set = ""
    @on_title_unset = ""
    @icon = 0
    @ranks = {}
    @states = []
    @mastery_states = []
    @mastery_sp = 0
  end
  
  #--------------------------------------------------------------------------
  # rank_script
  #--------------------------------------------------------------------------
  def rank_script(rank)
    @ranks[rank] ? @ranks[rank].script : ""
  end
  
  #--------------------------------------------------------------------------
  # max_rank
  #--------------------------------------------------------------------------
  def max_rank
    @ranks.size
  end
  
  #--------------------------------------------------------------------------
  # sp_for_rank
  #--------------------------------------------------------------------------
  # Calculates sp required for a given rank
  def sp_for_rank(rank)
    return 0 if rank <= 0
    value = 0
    
    for i in 1..rank
      next if @ranks[i].nil?
      value += @ranks[i].sp
    end
    
    value += @mastery_sp if rank > max_rank
    return value
  end
  
end # class ToGTitle



#==============================================================================
# ** ToGTitleRank
#==============================================================================
class ToGTitleRank
  attr_accessor :name
  attr_accessor :description
  attr_accessor :sp
  attr_accessor :script
  attr_accessor :icon
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    @name = ""
    @description = ""
    @sp = 0
    @script = ""
    @icon = 0
  end

end



#==============================================================================
# ** ToGTitleData
#==============================================================================
class ToGTitleData
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    @data = {}
    create_title_data
  end
  
  #--------------------------------------------------------------------------
  # []                # Get Title
  #--------------------------------------------------------------------------
  def [](symbol)
    return @data[:undefined] if @data[symbol].nil?
    return @data[symbol]
  end
  
  #--------------------------------------------------------------------------
  # all_symbols
  #--------------------------------------------------------------------------
  def all_symbols
    array = []
    @data.each_key { |key| array.push(key) }
    return array
  end
  
  #--------------------------------------------------------------------------
  # m_sp
  #--------------------------------------------------------------------------
  def m_sp
    Bubs::ToGTitleSystem::DEFAULT_MASTERY_SP
  end

  #--------------------------------------------------------------------------
  # create_title_data
  #--------------------------------------------------------------------------
  def create_title_data
    Bubs::ToGTitleSystem::TITLE.each do |key, hash|
      title = ToGTitle.new
      
      title.symbol         = key
      title.name           = hash[:name] ? hash[:name] : ""
      title.icon           = hash[:icon] ? hash[:icon] : 0
      title.description    = hash[:description] ? hash[:description] : ""
      title.mastery_sp     = hash[:mastery_sp] ? hash[:mastery_sp] : m_sp
      title.condition      = hash[:condition] ? hash[:condition] : ""
      title.on_title_set   = hash[:on_title_set] ? hash[:on_title_set] : ""
      title.on_title_unset = hash[:on_title_unset] ? hash[:on_title_unset] : ""
      
      (hash[:states] ? hash[:states] : []).each do |state_id|
        title.states.push(state_id)
      end
      
      (hash[:mastery_states] ? hash[:mastery_states] : []).each do |state_id|
        title.mastery_states.push(state_id)
      end
      
      next if create_title_ranks_data(title, hash) == :error
      
      @data[key] = title
    end
  end
  
  #--------------------------------------------------------------------------
  # create_title_ranks_data
  #--------------------------------------------------------------------------
  def create_title_ranks_data(title, hash)
    sp = 0
    hash.each do |key, value|
      next unless key.is_a?(Integer)
      rank = ToGTitleRank.new
      if value.size == 2
        rank.sp = value[0]
        symbol  = value[1]
        presets = Bubs::ToGTitleSystem::RANK_PRESETS[symbol]
        rank.icon        = presets[0]
        rank.name        = presets[1]
        rank.description = presets[2]
        rank.script      = presets[3]
      elsif value.size == 5
        rank.sp          = value[0]
        rank.icon        = value[1]
        rank.name        = value[2]
        rank.description = value[3]
        rank.script      = value[4]
      else
        if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
          str = title.symbol.to_s
          text1 = sprintf("An error occured with title :%s!", str)
          text2 = sprintf(":%s, Rank %d is incorrectly defined.", str, key)
          text3 = sprintf(":%s data initialization skipped.", str)
          p text1; p text2; p text3
        end
        return :error
      end
      title.ranks[key] = rank
    end
    return :ok
  end
  
end # class ToGTitleData




#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  include Bubs::ToGTitleConditions
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :current_title
  attr_accessor :actor_titles
  attr_accessor :title_bonus
  attr_reader :title_rank
  attr_reader :title_sp
  attr_accessor :title_mode
  attr_accessor :bonus
  attr_accessor :state_bonus
  attr_accessor :element_bonus
  attr_accessor :titles_just_learned
  attr_reader :title_states
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias :initialize_bubs_togtitles :initialize
  def initialize(actor_id)
    initialize_bubs_togtitles(actor_id) # alias
    
    initialize_togtitle_data
  end
  
  #--------------------------------------------------------------------------
  # new : initialize_togtitle_data
  #--------------------------------------------------------------------------
  def initialize_togtitle_data
    @current_title = :undefined
    @actor_titles = []
    @potential_titles = []
    @title_rank = {}
    @title_sp = {}
    @title_mode = Bubs::ToGTitleSystem::DEFAULT_AUTO_EQUIP_MODE
    @title_states = []
    
    # Bonus variables
    @bonus = {}
    @state_bonus = {}
    @element_bonus = {}
    
    @titles_just_learned = []
    @actor_titles.uniq!
    
    initialize_togtitle_data_defaults
    initialize_potential_titles
    initialize_current_title
    setup_title_debug_mode if title_debug_mode?
  end
  #--------------------------------------------------------------------------
  # new : initialize_togtitle_data_defaults
  #--------------------------------------------------------------------------
  def initialize_togtitle_data_defaults
    @bonus.default = 0
    @state_bonus.default = 0.0
    @element_bonus.default = 0.0
    @title_sp.default = 0
    @title_rank.default = 0
  end
  
  #--------------------------------------------------------------------------
  # new : initialize_potential_titles
  #--------------------------------------------------------------------------
  def initialize_potential_titles
    @potential_titles |= Bubs::ToGTitleSystem::POTENTIAL_TITLES[@actor_id]
    @potential_titles |= Bubs::ToGTitleSystem::GLOBAL_POTENTIAL_TITLES
  end
  
  #--------------------------------------------------------------------------
  # new : initialize_current_title
  #--------------------------------------------------------------------------
  def initialize_current_title
    @current_title = Bubs::ToGTitleSystem::INITIAL_TITLE[@actor_id]
    @actor_titles.push(@current_title) unless has_title?(@current_title)
    @nickname = title.name
  end
  
  #--------------------------------------------------------------------------
  # new : setup_title_debug_mode
  #--------------------------------------------------------------------------
  def setup_title_debug_mode
    for symbol in $data_titles.all_symbols
      @potential_titles.push(symbol)
      next if Bubs::ToGTitleSystem::TITLE_DEBUG_POTENTIAL_TITLES_ONLY
      @actor_titles.push(symbol)
    end
    @potential_titles.uniq!
    @actor_titles.uniq!
  end
  
  #--------------------------------------------------------------------------
  # new : add_title
  #--------------------------------------------------------------------------
  def add_title(symbol)
    @actor_titles |= [symbol]
    @potential_titles |= [symbol]
  end
  
  #--------------------------------------------------------------------------
  # new : titles
  #--------------------------------------------------------------------------
  def titles
    temp = @potential_titles.select { |symbol| has_title?(symbol) }.uniq
    return temp.collect { |symbol| $data_titles[symbol] }
  end
  
  #--------------------------------------------------------------------------
  # new : title
  #--------------------------------------------------------------------------
  # returns actor's current title object
  def title
    $data_titles[@current_title]
  end
  
  #--------------------------------------------------------------------------
  # new : current_title_rank
  #--------------------------------------------------------------------------
  # returns int
  def current_title_rank
    @title_rank ? @title_rank[@current_title] : 0
  end
  
  #--------------------------------------------------------------------------
  # new : current_title_max_rank
  #--------------------------------------------------------------------------
  # returns int
  def current_title_max_rank
    title.max_rank
  end
    
  #--------------------------------------------------------------------------
  # new : mastered_title_count
  #--------------------------------------------------------------------------
  def mastered_title_count
    @actor_titles.select { |symbol| 
      @title_rank[symbol] > $data_titles[symbol].max_rank 
    }.size
  end
  
  #--------------------------------------------------------------------------
  # new : learned_title_count
  #--------------------------------------------------------------------------
  def learned_title_count
    @actor_titles.size
  end

  #--------------------------------------------------------------------------
  # new : current_title=
  #--------------------------------------------------------------------------
  def current_title=(symbol)
    return if symbol == @current_title
    on_title_unset
    @current_title = symbol
    @nickname = title.name
    on_title_set
  end
  
  #--------------------------------------------------------------------------
  # new : current_title?
  #--------------------------------------------------------------------------
  def current_title?(symbol)
    @current_title == symbol
  end

  #--------------------------------------------------------------------------
  # new : title_learned?
  #--------------------------------------------------------------------------
  def title_learned?(symbol)
    @actor_titles.include?(symbol)
  end
  alias :has_title? :title_learned?
  
  #--------------------------------------------------------------------------
  # new : gain_title_sp
  #--------------------------------------------------------------------------
  def gain_title_sp(value)
    return if current_title_mastered? #@mastered_titles.include?(title.symbol)
    @title_sp[@current_title] += value
    check_title_rank_up
  end
  
  #--------------------------------------------------------------------------
  # new : gain_sp_all_titles
  #--------------------------------------------------------------------------
  def gain_sp_all_titles(value)
    original_title = @current_title
    for symbol in @actor_titles
      begin
        @current_title = symbol
        gain_title_sp(value)
      rescue
        if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
          text1 = "An error occurred with title %s" 
          text2 = "when gain_sp_all_titles was used."
          text3 = "Title's SP gain skipped."
          p text1; p text2; p text3
        end
      end
    end
    @current_title = original_title
  end
  
  #--------------------------------------------------------------------------
  # new : check_title_rank_up
  #--------------------------------------------------------------------------
  def check_title_rank_up
    sp = @title_sp[@current_title]
    max_rank = title.max_rank
    title_rank_up while sp >= next_title_rank_sp  && current_title_rank <= max_rank
    auto_equip_title
  end
  
  #--------------------------------------------------------------------------
  # new : title_mastered?
  #--------------------------------------------------------------------------
  def title_mastered?(symbol)
    @title_rank[symbol] > $data_titles[symbol].max_rank
  end
  
  #--------------------------------------------------------------------------
  # new : title_debug_mode?
  #--------------------------------------------------------------------------
  def title_debug_mode?
    Bubs::ToGTitleSystem::TITLE_DEBUG_MODE
  end
  
  #--------------------------------------------------------------------------
  # new : current_title_mastered?
  #--------------------------------------------------------------------------
  def current_title_mastered?
    current_title_rank > current_title_max_rank
  end
  
  #--------------------------------------------------------------------------
  # new : next_title_rank_sp
  #--------------------------------------------------------------------------
  # Calculates sp required for next rank
  def next_title_rank_sp
    title.sp_for_rank(current_title_rank + 1)
  end
  
  #--------------------------------------------------------------------------
  # new : title_rank_up
  #--------------------------------------------------------------------------
  def title_rank_up
    @title_rank[@current_title] += 1
    return if @title_rank[@current_title] > title.max_rank
    script = title.rank_script(current_title_rank)
    begin
      eval(script)
    rescue
      if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
        text1 = "An error occurred with a title effect script."
        text2 = "Title Symbol: " + title.symbol
        str = sprintf("%s\n\n%s\n\n%s", text1, text2, script)
        msgbox(str)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new : check_title_conditions
  #--------------------------------------------------------------------------
  def check_title_conditions
    @titles_just_learned = []
    for symbol in @potential_titles
      next if @actor_titles.include?(symbol)
      script = $data_titles[symbol].condition
      next if script == ""
      begin
        if eval(script)
          add_title(symbol)
          @titles_just_learned.push($data_titles[symbol])
        end
      rescue
        if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
          text1 = "An error occurred with a title condition."
          text2 = "Title Symbol: " + symbol.to_s
          str = sprintf("%s\n\n%s\n\n%s", text1, text2, script)
          msgbox(str)
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new : auto_equip_title
  #--------------------------------------------------------------------------
  # recursive method up to 3 times
  def auto_equip_title(value = 0)
    case @title_mode
    when :manual
      return @current_title
    when :mastered
      return @current_title unless title_mastered?(@current_title)
      @actor_titles.shuffle.each do |symbol|
        next if title_mastered?(symbol)
        next if $data_titles[symbol].max_rank == 0
        @current_title = symbol
        @nickname = title.name
        return @current_title
      end
    when Integer
      return @current_title unless current_title_rank >= @title_mode
      @actor_titles.shuffle.each do |symbol|
        next if $data_titles[symbol].max_rank == 0
        next if title_mastered?(symbol)
        for i in 1..(@title_mode + value)
          next if @title_rank[symbol] >= i
          @current_title = symbol
          @nickname = title.name
          return @current_title
        end
      end
      return @current_title if value == 3
      auto_equip_title(value + 1)
    end
    return @current_title
  end
  
  #--------------------------------------------------------------------------
  # new : on_title_set
  #--------------------------------------------------------------------------
  def on_title_set
    script = title.on_title_set
    begin
      eval(script)
    rescue
      if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
        text1 = "An error occurred with a :on_title_set script call."
        text2 = "Title Symbol: " + symbol.to_s
        str = sprintf("%s\n\n%s\n\n%s", text1, text2, script)
        msgbox(str)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new : on_title_unset
  #--------------------------------------------------------------------------
  def on_title_unset
    script = title.on_title_unset
    begin
      eval(script)
    rescue
      if Bubs::ToGTitleSystem::TITLE_DEBUG_MESSAGES
        text1 = "An error occurred with a :on_title_unset script call."
        text2 = "Title Symbol: " + symbol.to_s
        str = sprintf("%s\n\n%s\n\n%s", text1, text2, script)
        msgbox(str)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # alias : param
  #--------------------------------------------------------------------------
  alias :param_bubs_togtitles :param
  def param(param_id)
    value = param_bubs_togtitles(param_id) # alias
    value += param_title_bonus(param_id)
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  
  #--------------------------------------------------------------------------
  # alias : xparam
  #--------------------------------------------------------------------------
  alias :xparam_bubs_togtitles :xparam
  def xparam(xparam_id)
    xparam_title_bonus(xparam_id) + xparam_bubs_togtitles(xparam_id)
  end
  
  #--------------------------------------------------------------------------
  # alias : sparam
  #--------------------------------------------------------------------------
  alias :sparam_bubs_togtitles :sparam
  def sparam(sparam_id)
    sparam_title_bonus(sparam_id) + sparam_bubs_togtitles(sparam_id)
  end
  
  #--------------------------------------------------------------------------
  # new : param_title_bonus
  #--------------------------------------------------------------------------
  def param_title_bonus(param_id)
    return 0 unless @bonus
    case param_id
    when 0
      @bonus[:mhp]
    when 1
      @bonus[:mmp]
    when 2
      @bonus[:atk]
    when 3
      @bonus[:def]
    when 4
      @bonus[:mat]
    when 5
      @bonus[:mdf]
    when 6
      @bonus[:agi]
    when 7
      @bonus[:luk]
    end
  end
  
  #--------------------------------------------------------------------------
  # new : xparam_title_bonus
  #--------------------------------------------------------------------------
  def xparam_title_bonus(xparam_id)
    return 0 unless @bonus
    case xparam_id
    when 0
      @bonus[:hit]
    when 1
      @bonus[:eva]
    when 2
      @bonus[:cri]
    when 3
      @bonus[:cev]
    when 4
      @bonus[:mev]
    when 5
      @bonus[:mrf]
    when 6
      @bonus[:cnt]
    when 7
      @bonus[:hrg]
    when 8
      @bonus[:mrg]
    when 9
      @bonus[:trg]
    end
  end
  
  #--------------------------------------------------------------------------
  # new : sparam_title_bonus
  #--------------------------------------------------------------------------
  def sparam_title_bonus(sparam_id)
    return 0 unless @bonus
    case sparam_id
    when 0
      @bonus[:tgr]
    when 1
      @bonus[:grd]
    when 2
      @bonus[:rec]
    when 3
      @bonus[:pha]
    when 4
      @bonus[:mcr]
    when 5
      @bonus[:tcr]
    when 6
      @bonus[:pdr]
    when 7
      @bonus[:mdr]
    when 8
      @bonus[:fdr]
    when 9
      @bonus[:exr]
    end
  end
  
  #--------------------------------------------------------------------------
  # inherit alias : state?
  #--------------------------------------------------------------------------
  alias :state_bubs_togtitles :state?
  def state?(state_id)
    return false if title_state?(state_id)
    return state_bubs_togtitles(state_id)
  end
  
  #--------------------------------------------------------------------------
  # inherit alias : states
  #--------------------------------------------------------------------------
  alias :states_bubs_togtitles :states
  def states
    array = states_bubs_togtitles
    array |= title_states
    return array
  end
  
  #--------------------------------------------------------------------------
  # new : title_state?
  #--------------------------------------------------------------------------
  def title_state?(state_id)
    @title_states ||= []
    return @title_states.include?(state_id)
  end

  #--------------------------------------------------------------------------
  # new : title_states
  #--------------------------------------------------------------------------
  # returns array of state_ids
  def title_states
    return [] unless @title_rank
    array = current_title_mastered? ? title.mastery_states : title.states
    array = array.select { |state_id| title_state_addable?(state_id) }
    array = array.sort_by { |id| [-$data_states[id].priority, id] }
    create_title_state_array(array)
    set_title_state_turns(array)
    return array.collect { |state_id| $data_states[state_id] }
  end

  #--------------------------------------------------------------------------
  # new : create_title_state_array
  #--------------------------------------------------------------------------
  def create_title_state_array(array)
    @title_states = []
    for state_id in array
      @title_states.push(state_id)
    end
  end
  
  #--------------------------------------------------------------------------
  # new : title_state_addable?
  #--------------------------------------------------------------------------
  def title_state_addable?(state_id)
    return false if $data_states[state_id].nil?
    return alive?
  end

  #--------------------------------------------------------------------------
  # new : set_title_state_turns
  #--------------------------------------------------------------------------
  def set_title_state_turns(array)
    for state_id in array
      @state_turns[state_id] = 0 unless @states.include?(state_id)
      @state_steps[state_id] = 0 unless @states.include?(state_id)
    end
  end

  #--------------------------------------------------------------------------
  # alias : state_addable?
  #--------------------------------------------------------------------------
  alias :state_addable_bubs_togtitles :state_addable?
  def state_addable?(state_id)
    return false if title_state?(state_id)
    return state_addable_bubs_togtitles(state_id)
  end
  
  #--------------------------------------------------------------------------
  # alias : remove_state
  #--------------------------------------------------------------------------
  alias :remove_state_bubs_togtitles :remove_state
  def remove_state(state_id)
    return if title_state?(state_id)
    return remove_state_bubs_togtitles(state_id)
  end
  
end # class Game_Actor < Game_Battler



#==============================================================================
# ** Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # new : title_sp
  #--------------------------------------------------------------------------
  def title_sp
    d = Bubs::ToGTitleSystem::DEFAULT_ENEMY_TITLE_SP
    @title_sp ||= self.enemy.note =~ /<title[\s_]sp:\s*(\d+)>/i ? $1.to_i : d
  end
  
end



#==============================================================================
# ** Game_Troop
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # new : title_sp_total
  #--------------------------------------------------------------------------
  def title_sp_total
    dead_members.inject(0) {|r, enemy| r += enemy.title_sp }
  end
end




#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # draw_actor_title
  #--------------------------------------------------------------------------
  def draw_actor_title(actor, x, y, width = 160)
    return unless actor
    rect = Rect.new(x, y, width, line_height)
    change_color(normal_color)
    draw_icon(@actor.title.icon, x, y)
    rect.x += 24
    draw_text(rect, @actor.nickname)
  end
  #--------------------------------------------------------------------------
  # rank_active_icon
  #--------------------------------------------------------------------------
  def rank_active_icon
    Bubs::ToGTitleSystem::RANK_ACTIVE_ICON
  end
  #--------------------------------------------------------------------------
  # rank_inactive_icon
  #--------------------------------------------------------------------------  
  def rank_inactive_icon
    Bubs::ToGTitleSystem::RANK_INACTIVE_ICON
  end
  #--------------------------------------------------------------------------
  # use_title_mastered_image?
  #--------------------------------------------------------------------------  
  def use_title_mastered_image?
    Bubs::ToGTitleSystem::USE_TITLE_MASTERED_IMAGE
  end
  #--------------------------------------------------------------------------
  # title_mastered_image
  #--------------------------------------------------------------------------  
  def title_mastered_image
   Bubs::ToGTitleSystem::TITLE_MASTERED_IMAGE
  end
  #--------------------------------------------------------------------------
  # title_mastery_color
  #--------------------------------------------------------------------------
  def title_mastery_color
    text_color(Bubs::ToGTitleSystem::TITLE_MASTERED_COLOR)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_title_rank
  #--------------------------------------------------------------------------
  def draw_actor_title_rank(actor, x, y, width = 160)
    if actor.current_title_mastered?
      draw_title_mastered(actor, x, y, width)
    else
      for i in 0..(@actor.title.max_rank - 1)
        if @actor.current_title_rank >= (i + 1)
          draw_icon(rank_active_icon, x + i * 24, y, true) 
        else
          draw_icon(rank_inactive_icon, x + i * 24, y, false) 
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_title_mastered
  #--------------------------------------------------------------------------
  def draw_title_mastered(actor, x, y, width = 160, align = 0)
    if use_title_mastered_image?
      bitmap = Cache.system(title_mastered_image)
      rect = Rect.new(0, 0, contents_width, contents_height)
      bx = align == 2 ? x + width - bitmap.width : x
      contents.blt(bx, y, bitmap, rect)
      bitmap.dispose
    else
      rect = Rect.new(x, y, width, line_height)
      change_color(title_mastery_color)
      draw_text(rect, Vocab::TitleMastered, align)
      reset_font_settings
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_title_sp
  #--------------------------------------------------------------------------
  # draw a gauge for an actor where symbol is a title symbol
  def draw_actor_title_sp(actor, symbol, x, y, width = 160)
    current_rank = actor.title_rank[symbol]
    title = $data_titles[symbol]
    
    sp_next_rank = title.sp_for_rank(current_rank + 1)
    sp_next_rank -= title.sp_for_rank(current_rank)
    sp_needed = [sp_next_rank, 0].max
    
    current_sp = actor.title_sp[symbol]
    current_sp -= title.sp_for_rank(current_rank)
    current_sp = [current_sp, 0].max
    
    rate = sp_needed > 0 ? current_sp.to_f / sp_needed.to_f : 1.0 
    
    if @actor.current_title_max_rank + 1 > current_rank
      draw_actor_title_sp_gauge(rate, x, y, width)
      draw_current_and_max_values(x, y, width, current_sp, sp_needed, 
          normal_color, normal_color)
    else
      draw_title_mastered(actor, x, y, width, 2)
    end
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::title_sp_a)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_title_sp_gauge
  #--------------------------------------------------------------------------
  def draw_actor_title_sp_gauge(rate, x, y, width = 160)
    if $kms_imported["GenericGauge"]
      image      = Bubs::ToGTitleSystem::GENERIC_GAUGE[:image]
      offset     = Bubs::ToGTitleSystem::GENERIC_GAUGE[:offset]
      len_offset = Bubs::ToGTitleSystem::GENERIC_GAUGE[:len_offset]
      slope      = Bubs::ToGTitleSystem::GENERIC_GAUGE[:slope]
      draw_generic_gauge(image, x, y, width, rate, offset, len_offset, slope)
    else
      color1 = Bubs::ToGTitleSystem::TITLE_SP_GAUGE_COLOR1
      color2 = Bubs::ToGTitleSystem::TITLE_SP_GAUGE_COLOR2
      draw_gauge(x, y, width, rate, text_color(color1), text_color(color2) )
    end
  end
  
end # class Window_Base < Window



#==============================================================================
# ** Window_ToGTitleStatus
#==============================================================================
class Window_ToGTitleStatus < Window_Base
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, fitting_height(2))
    @actor = nil
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # actor_icon_width
  #--------------------------------------------------------------------------
  def actor_icon_width
    return 96
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_name(@actor, 108, 0)
    draw_actor_icons(@actor, 108, line_height, actor_icon_width)
    draw_actor_title(@actor, 228, 0, contents_width - 228)
    draw_actor_title_rank(@actor, 228 + 24, line_height, contents_width - 228)
  end
  
  #--------------------------------------------------------------------------
  # draw_actor_face
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face_t(actor.face_name, actor.face_index, x, y, enabled)
  end
  
  #--------------------------------------------------------------------------
  # draw_face_t
  #--------------------------------------------------------------------------
  def draw_face_t(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96 + 24, 96, 48)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end

end # class Window_ToGTitleStatus < Window_Base



#==============================================================================
# ** Window_ToGTitleList
#==============================================================================
class Window_ToGTitleList < Window_Selectable
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super#(x, y, Graphics.width, Graph)
    @actor = nil
    @data = []
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    value = 8
    value = 11 if Graphics.height == 480
    return fitting_height(value) + 8
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end

  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  
  #--------------------------------------------------------------------------
  # spacing             # Get Spacing for Items Arranged Side by Side
  #--------------------------------------------------------------------------
  def spacing
    return 32
  end
  
  #--------------------------------------------------------------------------
  # item_max              # Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  
  #--------------------------------------------------------------------------
  # title       # Get title
  #--------------------------------------------------------------------------
  def title
    @data && index >= 0 ? @data[index] : nil
  end

  #--------------------------------------------------------------------------
  # current_item_enabled?     # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  
  #--------------------------------------------------------------------------
  # include?      # Include in Title List? 
  #--------------------------------------------------------------------------
  def include?(title)
    return false if title.nil?
    return false if title.symbol == :undefined
    return true
  end
  
  #--------------------------------------------------------------------------
  # enable?
  #--------------------------------------------------------------------------
  def enable?(title)
    return false if title.nil?
    return true
  end
  
  #--------------------------------------------------------------------------
  # make_item_list
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @actor ? @actor.titles.select {|title| include?(title)} : []
  end
  
  #--------------------------------------------------------------------------
  # draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    title_obj = @data[index]
    if $data_titles.all_symbols.include?(title_obj.symbol)
      rect = item_rect(index)
      rect.width -= 4
      draw_title(title_obj, rect.x, rect.y, true)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_title
  #--------------------------------------------------------------------------
  def draw_title(title_obj, x, y, enabled = true, width = 202)
    rect = item_rect(index)
    rect.width -= 4
    name = title_obj.name 
    icon = title_obj.icon
    symbol = title_obj.symbol
    draw_icon(icon, x, y, enabled)
    contents.font.size = 18
    draw_title_rank(title_obj, x, y)
    reset_font_settings
    change_color(normal_color, enabled)
    change_color(text_color(23)) if @actor.current_title == symbol
    draw_text(x + 24, y, width, line_height, name)
  end
  
  #--------------------------------------------------------------------------
  # draw_title
  #--------------------------------------------------------------------------
  def draw_title_rank(title_obj, x, y)
    rect = Rect.new(x - 2, y + 6, 24, line_height)
    if @actor.title_mastered?(title_obj.symbol)
      change_color(title_mastery_color)
      draw_text(rect, Vocab::TitleMastered_A, 2)
    else 
      rank = @actor.title_rank[title_obj.symbol]
      change_color(normal_color)
      draw_text(rect, rank, 2)
    end
  end

  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    return unless title
    @help_window.set_text(title.description)
  end

  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  
end # class Window_ToGTitleList < Window_Selectable



#==============================================================================
# ** Window_ToGTitleRankList
#==============================================================================
class Window_ToGTitleRankList < Window_Selectable
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    @title = nil
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # title=
  #--------------------------------------------------------------------------
  def title=(title)
    @title = title
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    return if @actor.nil? || @title.nil?
    draw_actor_title_sp(@actor, @title.symbol, 32, 0, 160)
    draw_title_name(@title, Graphics.width / 2 - 32, 0)
    draw_title_ranks(@title, 0, 0)
  end
  
  #--------------------------------------------------------------------------
  # draw_title_name
  #--------------------------------------------------------------------------
  def draw_title_name(title, x, y)
    change_color(normal_color)
    rect = Rect.new(x, y, contents_width - x, line_height)
    draw_text(rect, title.name, 1)
  end
  
  #--------------------------------------------------------------------------
  # draw_title_ranks
  #--------------------------------------------------------------------------
  def draw_title_ranks(title, x, y)
    ranks = title.ranks
    return if ranks.size == 0
    lh = line_height
    gw = Graphics.width
    for i in 1..ranks.size
      enabled = i <= @actor.title_rank[@title.symbol]
      change_color(normal_color, enabled)
      draw_rank_icon(i, x, y + lh * i, enabled)
      draw_rank_name(ranks[i], x + 32, y + (lh * i), enabled)
      draw_rank_description(ranks[i], x + gw / 2 - 32, y + lh * i, enabled)
    end
  end
  
  #--------------------------------------------------------------------------
  # draw_rank_description
  #--------------------------------------------------------------------------
  def draw_rank_description(rank, x, y, enabled = false)
    rect = Rect.new(x, y, contents_width - x + 32, line_height)
    contents.font.size = 20
    draw_text(rect, rank.description, 0)
    contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # draw_rank_icon
  #--------------------------------------------------------------------------
  def draw_rank_icon(text, x, y, enabled = false)
    if enabled
      draw_icon(rank_active_icon, x, y)
    else
      draw_icon(rank_inactive_icon, x, y, false)
    end
    contents.font.size = 18
    draw_text(x + 4, y + 4, 24, line_height, text, 2)
    contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # draw_rank_name
  #--------------------------------------------------------------------------
  def draw_rank_name(rank, x, y, enable = false)
    name = rank.name
    icon = rank.icon
    rect = Rect.new(x + 26, y, contents_width / 2 - x - 24, line_height)
    draw_icon(icon, x, y, enable)
    draw_text(rect, name, 0)
  end
  
end # class Window_ToGTitleRankList < Window_Selectable



#==============================================================================
# ** Window_ToGTitleHint
#==============================================================================
class Window_ToGTitleHint < Window_Help
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y) #, width, height)
    super(1)
    self.x = x
    self.y = y
    @actor = nil
  end
  
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def actor=(actor)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    return unless @actor
    draw_hint_text(0, 0)
  end
  
  #--------------------------------------------------------------------------
  # draw_hint_text
  #--------------------------------------------------------------------------
  def draw_hint_text(x, y)
    rect = Rect.new(x, y, contents_width, contents_height)
    text = sprintf(Vocab::TitleCurrentMode, mode_name)
    draw_text(rect, text, 1)
  end
  
  #--------------------------------------------------------------------------
  # mode_name
  #--------------------------------------------------------------------------
  def mode_name
    Bubs::ToGTitleSystem::AUTO_EQUIP_MODES[@actor.title_mode][0]
  end
  
end # class Window_ToGTitleHint < Window_Help



#==============================================================================
# ** Window_ToGTitleCommand
#==============================================================================
class Window_ToGTitleCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::TitleSet,        :set_title)
    add_command(Vocab::TitleChangeMode, :change_mode)
  end

end # class Window_ToGTitleCommand < Window_HorzCommand



#==============================================================================
# ** Window_ToGTitleMode
#==============================================================================
class Window_ToGTitleMode < Window_Command
  attr_accessor :help_window
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    return 200
  end
  
  #--------------------------------------------------------------------------
  # col_max
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  
  #--------------------------------------------------------------------------
  # make_command_list
  #--------------------------------------------------------------------------
  def make_command_list
    modes.each do |key, array|
      add_command(array[0],  :set_mode, true, key)
    end
  end
  
  #--------------------------------------------------------------------------
  # update_help
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(mode_help)
  end
  
  #--------------------------------------------------------------------------
  # modes
  #--------------------------------------------------------------------------
  def modes
    Bubs::ToGTitleSystem::AUTO_EQUIP_MODES
  end
  
  #--------------------------------------------------------------------------
  # mode_help
  #--------------------------------------------------------------------------
  def mode_help
    Bubs::ToGTitleSystem::AUTO_EQUIP_MODES[current_ext][1]
  end
  
  #--------------------------------------------------------------------------
  # alignment
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  
end # class Window_ToGTitleMode < Window_Command




#==============================================================================
# ** Window_MenuCommand
#==============================================================================
class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # alias : add_original_commands
  #--------------------------------------------------------------------------
  alias :add_original_commands_bubs_togtitles :add_original_commands
  def add_original_commands
    add_original_commands_bubs_togtitles # alias
    
    if Bubs::ToGTitleSystem::ADD_TITLE_MENU_COMMAND
      add_command(Vocab::togtitles,   :togtitles, main_commands_enabled)
    end
  end
end



#==============================================================================
# ** Scene_Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # alias : create_command_window
  #--------------------------------------------------------------------------
  alias :create_command_window_bubs_togtitles :create_command_window
  def create_command_window
    create_command_window_bubs_togtitles # alias
    
    @command_window.set_handler(:togtitles, method(:command_personal))
  end
  
  #--------------------------------------------------------------------------
  # alias : on_personal_ok
  #--------------------------------------------------------------------------
  alias :on_personal_ok_bubs_togtitles :on_personal_ok
  def on_personal_ok
    on_personal_ok_bubs_togtitles # alias
    
    if @command_window.current_symbol == :togtitles
      SceneManager.call(Scene_ToGTitles) 
    end
  end

end



#==============================================================================
# ** Scene_ToGTitles
#==============================================================================
class Scene_ToGTitles < Scene_MenuBase
  #--------------------------------------------------------------------------
  # start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_status_window
    create_title_hint_window
    create_titles_window
    create_title_command_window
    create_title_effects_window
    create_title_mode_window
  end
  
  #--------------------------------------------------------------------------
  # create_title_mode_window
  #--------------------------------------------------------------------------
  def create_title_mode_window
    wx = 0
    wy = 0
    @mode_window = Window_ToGTitleMode.new(wx, wy)
    @mode_window.x = Graphics.width / 2 - @mode_window.width / 2
    @mode_window.y = Graphics.height / 2 - @mode_window.height / 2
    @mode_window.z = 200
    @mode_window.hide.deactivate
    @mode_window.help_window = @help_window
    @mode_window.set_handler(:ok,     method(:on_mode_ok))
    @mode_window.set_handler(:cancel, method(:on_mode_cancel))
  end
  
  #--------------------------------------------------------------------------
  # create_title_hint_window
  #--------------------------------------------------------------------------
  def create_title_hint_window
    wx = 0
    wy = Graphics.height - 48
    @hint_window = Window_ToGTitleHint.new(wx, wy)
    @hint_window.actor = @actor
    @hint_window.show
    @hint_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    y = @help_window.height
    @status_window = Window_ToGTitleStatus.new(0, y)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  
  #--------------------------------------------------------------------------
  # create_titles_window
  #--------------------------------------------------------------------------
  def create_titles_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width
    wh = Graphics.height - @hint_window.height - wy
    @titlelist_window = Window_ToGTitleList.new(wx, wy, ww, wh)
    @titlelist_window.set_handler(:ok,     method(:on_title_ok))
    @titlelist_window.set_handler(:cancel, method(:return_scene))
    @titlelist_window.set_handler(:pagedown, method(:next_actor))
    @titlelist_window.set_handler(:pageup,   method(:prev_actor))
    @titlelist_window.help_window = @help_window
    @titlelist_window.actor = @actor
    @titlelist_window.activate.select(0)
  end
  
  #--------------------------------------------------------------------------
  # create_title_effects_window
  #--------------------------------------------------------------------------
  def create_title_effects_window
    wx = 0
    wy = @status_window.y + @status_window.height
    ww = Graphics.width
    wh = @titlelist_window.height - @title_command_window.height
    @title_effects_window = Window_ToGTitleRankList.new(wx, wy, ww, wh)
    @title_effects_window.hide
  end
  
  #--------------------------------------------------------------------------
  # create_title_command_window
  #--------------------------------------------------------------------------
  def create_title_command_window
    wx = 0
    wy = @hint_window.y - @hint_window.height
    ww = Graphics.width
    wh = Graphics.height - @help_window.height
    @title_command_window = Window_ToGTitleCommand.new(wx, wy) #(wx, wy, ww, wh)
    @title_command_window.hide.deactivate
    @title_command_window.set_handler(:set_title, method(:command_set_title))
    @title_command_window.set_handler(:change_mode, method(:on_change_mode))
    @title_command_window.set_handler(:cancel, method(:on_title_command_cancel))
  end
  
  #--------------------------------------------------------------------------
  # on_mode_ok
  #--------------------------------------------------------------------------
  def on_mode_ok
    @actor.title_mode = @mode_window.current_ext
    @hint_window.refresh
    on_mode_cancel
  end
  
  #--------------------------------------------------------------------------
  # on_mode_cancel
  #--------------------------------------------------------------------------
  def on_mode_cancel
    @mode_window.hide.deactivate
    @titlelist_window.update_help
    @title_command_window.activate
  end
  
  #--------------------------------------------------------------------------
  # on_change_mode
  #--------------------------------------------------------------------------
  def on_change_mode
    @mode_window.show.activate
    @mode_window.select_ext(@actor.title_mode)
  end
  
  #--------------------------------------------------------------------------
  # command_set_title
  #--------------------------------------------------------------------------
  def command_set_title
    if @actor.current_title != @titlelist_window.title.symbol
      @actor.current_title = @titlelist_window.title.symbol
    end
    @titlelist_window.refresh
    @status_window.refresh
    on_title_command_cancel
  end
  
  #--------------------------------------------------------------------------
  # on_title_command_cancel
  #--------------------------------------------------------------------------
  def on_title_command_cancel
    @title_effects_window.hide
    @title_command_window.hide.deactivate
    @titlelist_window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # on_title_ok
  #--------------------------------------------------------------------------
  def on_title_ok
    @title_effects_window.actor = @actor
    @title_effects_window.title = @titlelist_window.title
    @title_effects_window.show
    @titlelist_window.hide
    @title_command_window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # on_actor_change
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @titlelist_window.actor = @actor
    @hint_window.actor   = @actor
    @titlelist_window.refresh
    @titlelist_window.activate.select(0)
  end

  
end # class Scene_ToGTitles 



