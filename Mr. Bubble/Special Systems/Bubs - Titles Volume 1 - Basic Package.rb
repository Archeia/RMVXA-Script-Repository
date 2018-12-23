# ╔══════════════════════════════════════════════════════╦═══════╤═══════════╗
# ║ Tales of Graces Title System -                       ║ v1.00 │ (6/02/13) ║
# ║   Titles Volume 1: Basic Package                     ╠═══════╧═══════════╝
# ╚══════════════════════════════════════════════════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# The titles defined in this volume are required for some basic
# functionality with the Titles System script. This volume
# also contains the documentation on how to create your own
# custom titles.
#
# I highly suggest that you carefully study the examples I've
# provided in this titles volume (and other titles volumes).
# The learning curve for customizing this script is very high
# if you are not familiar with Ruby syntax.
#
# This volume also has some examples on how to use Rank Presets.
# Rank Presets are defined in the Main Script. Please refer
# to the documention in the Main Script to understand how they
# are defined.
#
# Have fun creating your own titles!
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.00 : Initial release. (6/02/2013)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor below the main script script "Tales of Graces Title 
# System".
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
$imported["BubsTitlesVolume1"] = 1.00

module Bubs
  module ToGTitleSystem
  
  TITLE ||= {} # <- Leave this alone, do not delete or modify.
  #--------------------------------------------------------------------------
  #     Title Definitions
  #--------------------------------------------------------------------------
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

  #---------------------------
  
  # All titles begin with TITLE[:symbol], where :symbol is a unique
  # identifier for your title. Symbols in Ruby begin with a colon ":"
  # and appear orange in color in your script editor. Make sure you
  # encase the settings in curly brackets, not anything else.
  TITLE[:example] = {   # Use an opening curly bracket "{"
    # You are now within a "hash". Hashes have keys and every key has
    # a value associated with it. In this kind of hash, the "=>" 
    # is used to associate the key with the value. Think of it
    # as an arrow that points to the key's value. After every value,
    # there must be a comma.
    ###---------------------------
    
    # :name defines the string that represents the title in-game.
    # Don't forget the comma at the end of all values!
    :name => "Example",
    
    # :icon defines a Iconset index number used to graphically
    # represent the title in menus.
    :icon => 16,
    
    # :description defines the text displayed in the help window.
    # Use the new-line character \n to make linebreaks. 
    :description => "This is help window text line 1.\n" +
                    "This is help window text line 2.",
                    
    # :condition defines the learning requirement for the title.
    # The string is processed with an eval method within the
    # scope of Game_Actor. MAKING YOUR OWN CUSTOM :condition 
    # STATEMENTS REQUIRES KNOWLEDGE OF RUBY SYNTAX AND PROGRAMMING 
    # LOGIC. I've provided many examples of different :condition 
    # statements within the default titles provided in this script.
    # :condition statements should return true or false values.
    # If you don't know Ruby and you need help making your own 
    # custom logic statement, feel free to ask for help.
    :condition => "true",
    
    # Integers as keys define the rank for the title. Ranks
    # MUST start from 1 and must be ranked consecutively 
    # (i.e. 1, 2, 3, 4, etc..). Rank values are represented by
    # an array. Each element in the array represents a
    # piece of required information that defines a rank.
    # There is no limit to the amount of ranks you may
    # define.
    # 
    #   Rank => [ SP, Icon, "Name", "Description", "Script Call"],
    #
    #     Rank - is an Integer value starting from 1
    #     SP - The amount of SP (Skill Points) the rank requires.
    #     Icon - The icon index number from your Iconset.png.
    #     Name - The name of the Rank's effect.
    #     Description - A short description of what your Rank does.
    #     Script Call - A string that defines what happens when an 
    #                   actor achieves that rank in the title. This 
    #                   string is processed with an eval method within
    #                   scope of Game_Actor. Similiarly with :condition,
    #                   knowledge of Ruby is necessary for fully
    #                   utilizing this option.
    #
    # Don't forget the comma!

    # Rank    SP, Icon, Name      Description,     Bonus Effect Script Call
      1 => [ 100,   34, "ATK +3",  "",              "@bonus[:atk] += 3"],
      2 => [ 300,   35, "DEF +3",  "",              "@bonus[:def] += 3"],
      
    # There is a second way to define ranks. You can use predefined
    # rank settings in RANK_PRESETS section above this section.
    # The first element in the array still must be the SP rank 
    # requirement. However the second element is a symbol that is
    # defined in the RANK_PRESETS hash. The preset will automatically
    # fill in the four other requirements at startup.
  
    # Rank    SP, Rank Preset Symbol
      3 => [ 600,  :xpoison_10],
      
    # :mastery_sp defines how much SP is required to Master the
    # title.
    #
    # Mastering a title lets you use the 
    :mastery_sp => 3000,
    
    # :states defines the passive effect states the title automatically
    # grants when the actor has this title equipped. You can
    # list as many state ID numbers in the array as you like.
    # :states is optional when defining titles.
    :states => [14],
    
    # :mastery_states defines the passive effect states the title 
    # automatically grants when the actor masters and equips
    # this title. :mastery_states override the effects of :states
    # when the title is mastered. You can list as many state ID numbers 
    # in the array as you like. 
    # :mastery_states is optional when defining titles.
    :mastery_states => [14, 15],
    
    # :on_title_set defines an eval statement that is processed
    # when an actor equips the title. Requires scripting knowledge.
    # :on_title_unset is optional when defining titles.
    :on_title_set => "p \"Processing On Title Set eval...\"",
    
    # :on_title_unset defines an eval statement that is processed
    # when an actor unequips the title. Requires scripting knowledge.
    # :on_title_unset is optional when defining titles.
    :on_title_unset => "p \"Processing On Title Unset eval...\"",
  } # <- Don't forget the closing curly bracket!
  
  #--------------------------------------------------------------------------
  #     Using @bonus, @state_bonus, and @element_bonus for Rank Effects
  #--------------------------------------------------------------------------
  # For Rank Effect Script Calls, I have provided instance variables 
  # and methods within Game_Actor that saves and accumulates any 
  # param increases.
  #
  # @bonus is a hash that keeps track of params, xparams, and sparams bonuses.
  # 
  #   @bonus[symbol] - Where symbol is any of the following symbols
  #
  # Actor Base Params (all these are normal values):
  #
  #     :mhp  Maximum Hit Points
  #     :mmp  Maximum Magic Points
  #     :atk  ATtacK power
  #     :def  DEFense power
  #     :mat  Magic ATtack power
  #     :mdf  Magic DeFense power
  #     :agi  AGIlity
  #     :luk  LUcK
  #
  # Actor Ex-Params and Sp-Params. Remember that these are rate values 
  # which means +0.01 is equal to a +1% increase:
  # 
  #     :hit  HIT rate
  #     :eva  EVAsion rate
  #     :cri  CRItical rate
  #     :cev  Critical EVasion rate 
  #     :mev  Magic EVasion rate    
  #     :mrf  Magic ReFlection rate 
  #     :cnt  CouNTer attack rate   
  #     :hrg  Hp ReGeneration rate  
  #     :mrg  Mp ReGeneration rate  
  #     :trg  Tp ReGeneration rate  
  #     :tgr  TarGet Rate
  #     :grd  GuaRD effect rate     
  #     :rec  RECovery effect rate  
  #     :pha  PHArmacology          
  #     :mcr  Mp Cost Rate          
  #     :tcr  Tp Charge Rate        
  #     :pdr  Physical Damage Rate  
  #     :mdr  Magical Damage Rate   
  #     :fdr  Floor Damage Rate     
  #     :exr  EXperience Rate       
  #
  # @state_bonus is a hash that keeps track of state chance bonuses
  # where @state_bonus[state_id] stores the accumulated bonus to that state.
  #
  # @element_bonus is a hash that keeps track of element rate bonuses
  # where @element_bonus[element_id] stores the accumulated bonus
  # to that element.
  
  # - - - - - - - Create Your Own Titles Below This Line - - - - - - - - - -
  
  #   TITLE[:title_symbol] = {  ...  }
  
  
  
  
  
  
  
  
  
  
  
  #--------------------------------------------------------------------------
  #   Predefined Titles
  #--------------------------------------------------------------------------  
  # This section is a very long list of predefined titles. I made these
  # titles as specifically as examples for people to study. Examine these
  # carefully if you intend on creating your own custom titles.
  
  #---------------------------
  TITLE[:silver_reaper] = {
    :name => "Silver Reaper",
    :icon => 126,
    :description => "A title for an infamous silver-haired hero.",
    :condition => "", 
    # Rank  SP, Icon, Label      Description,     Rank Effect Script Call
    1 => [ 100,   34, "ATK +3",  "",              "@bonus[:atk] += 3"],
    2 => [ 300,   35, "DEF +3",  "",              "@bonus[:def] += 3"],
    3 => [ 600,  128, "Cleave",  "Learn: Cleave", "learn_skill(81)"],
    4 => [1000,   32, "Vitality", "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   34, "ATK +5",  "",              "@bonus[:atk] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:thunder_fist] = {
    :name => "Thunder Fist",
    :icon => 126,
    :description => "A title for a talented monk.",
    :condition => "", 
    # Rank  SP, Icon,  Label      Description,     Bonus Effect Script Call
    1 => [ 100,   34, "ATK +3",  "",              "@bonus[:atk] += 3"],
    2 => [ 300,   38, "AGI +3",  "",              "@bonus[:agi] += 3"],
    3 => [ 600,  129, "Tackle",  "Learn: Tackle", "learn_skill(85)"],
    4 => [1000,   32, "Vitality", "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",  "",              "@bonus[:agi] += 3"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:wandering_paladin] = {
    :name => "Wandering Paladin",
    :icon => 126,
    :description => "A paladin searching for a purpose.",
    :condition => "", 
    1 => [ 100,   35, "DEF +3",   "",             "@bonus[:def] += 3"],
    2 => [ 300,   37, "MDF +3",   "",             "@bonus[:mdf] += 3"],
    3 => [ 600,  139, "Cover",    "Learn: Cover", "learn_skill(90)"],
    4 => [1000,   32, "Vitality", "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   37, "MDF +5",   "",             "@bonus[:mdf] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:magic_swordsman] = {
    :name => "Magic Swordsman",
    :icon => 126,
    :description => "A magic swordsman believed to be the last\n" +
                    "of his ilk.",
    :condition => "", 
    1 => [ 100,   34, "ATK +3",     "",                  "@bonus[:atk] += 3"],
    2 => [ 300,   36, "MAT +3",     "",                  "@bonus[:mat] += 3"],
    3 => [ 600,  131, "Aura Blade", "Learn: Aura Blade", "learn_skill(95)"],
    4 => [1000,   32, "Vitality",   "Max HP +30",        "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",     "",                  "@bonus[:agi] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:dawns_edge] = {
    :name => "Dawn's Edge",
    :icon => 126,
    :description => "Only true wielders Takeshi's blade may\n" + 
                    "bear this title.",
    :condition => "", 
    1 => [ 100,   34, "ATK +3",     "",                  "@bonus[:atk] += 3"],
    2 => [ 300,   38, "AGI +4",     "",                  "@bonus[:agi] += 4"],
    3 => [ 600,  132, "Yoroidoshi", "Learn: Yoroidoshi", "learn_skill(100)"],
    4 => [1000,   32, "Vitality",   "Max HP +30",        "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",     "",                  "@bonus[:agi] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:dark_green_aim] = {
    :name => "Dark Green Aim",
    :icon => 126,
    :description => "A nickname given by villagers near her forest\n" +
                    "home. She's not fond of it.",
    :condition => "", 
    1 => [ 100,   34, "ATK +3",      "",                   "@bonus[:atk] += 3"],
    2 => [ 300,   37, "MDF +3",      "",                   "@bonus[:mdf] += 3"],
    3 => [ 600,  133, "Triple Shot", "Learn: Triple Shot", "learn_skill(108)"],
    4 => [1000,   32, "Vitality",    "Max HP +30",         "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",      "",                   "@bonus[:agi] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:formless_wind] = {
    :name => "Formless Wind",
    :icon => 126,
    :description => "Petty thief by day.\n" + 
                    "Hired assassin by night.",
    :condition => "", 
    1 => [ 100,   34, "ATK +3",  "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",  "",              "@bonus[:luk] += 3"],
    3 => [ 600,  134, "Vanish",  "Learn: Vanish", "learn_skill(110)"],
    4 => [1000,   32, "Vitality", "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",  "",              "@bonus[:agi] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:savior_of_joan] = {
    :name => "Savior of Joan",
    :icon => 126,
    :description => "A woman whose destiny was to become a saint.",
    :condition => "", 
    1 => [ 100,   36, "MAT +3", "",            "@bonus[:mat] += 3"],
    2 => [ 300,   37, "MDF +3", "",            "@bonus[:mdf] += 3"],
    3 => [ 600,  135, "Heal",   "Learn: Heal", "learn_skill(26)"],
    4 => [1000,   33, "Energy", "Max MP +10",  "@bonus[:mmp] += 10"],
    5 => [1500,   36, "MAT +5", "",            "@bonus[:mat] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:graceful_nightmare] = {
    :name => "Graceful Nightmare",
    :icon => 126,
    :description => "Formerly a fearful witch.\n" +
                    "Just don't call her by this title directly.",
    :condition => "", 
    1 => [ 100,   36, "MAT +3",  "",             "@bonus[:mat] += 3"],
    2 => [ 300,   38, "AGI +3",  "",             "@bonus[:agi] += 3"],
    3 => [ 600,  136, "Sleep",   "Learn: Sleep", "learn_skill(39)"],
    4 => [1000,   32, "Vitality", "",            "@bonus[:mhp] += 30"],
    5 => [1500,   37, "MDF +5",  "",             "@bonus[:mdf] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:star_seer] = {
    :name => "Star Seer",
    :icon => 126,
    :description => "A hermit who vigilantly gazes at the starry skies.",
    :condition => "", 
    1 => [ 100,   36, "MAT +3",  "",               "@bonus[:mat] += 3"],
    2 => [ 300,   35, "DEF +3",  "",               "@bonus[:def] += 3"],
    3 => [ 600,  136, "Thunder", "Learn: Thunder", "learn_skill(59)"],
    4 => [1000,   33, "Energy",  "Max MP +10",     "@bonus[:mmp] += 10"],
    5 => [1500,   39, "LUK +5",  "",               "@bonus[:luk] += 5"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:berserker] = { 
    :name => "Berserker",
    :icon => 126,
    :description => "Rage fuels this warrior on the battlefield.\n" +
                    "Earned by Soldiers at Lv. 10",
    :condition => "@class_id == 1 && level >= 10",
    1 => [ 100,   34, "ATK +3",  "",              "@bonus[:atk] += 3"],
    2 => [ 300,   35, "DEF +3",  "",              "@bonus[:def] += 3"],
    3 => [ 600,  128, "Berserker's Roar",  "Learn: Berserker's Roar", "learn_skill(82)"],
    4 => [1000,   32, "Vitality", "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   34, "ATK +5",  "",              "@bonus[:atk] += 5"],
  }
  #---------------------------
  TITLE[:lightning_legs] = { 
    :name => "Lightning Legs",
    :icon => 126,
    :description => "Disciple of the strongest woman in the world.\n" +
                    "Earned by Monks at Lv. 10",
    :condition => "@class_id == 2 && level >= 10",
    1 => [ 100,   34, "ATK +3",   "",              "@bonus[:atk] += 3"],
    2 => [ 300,   38, "AGI +3",   "",              "@bonus[:agi] += 3"],
    3 => [ 600,  129, "Tiger Stance",  "Learn: Tiger Stance", "learn_skill(87)"],
    4 => [1000,   32, "Vitality", "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",   "",              "@bonus[:agi] += 3"],
  }
  #---------------------------
  TITLE[:justicar] = {
    :name => "Justicar",
    :icon => 126,
    :description => "A shining beacon of justice.\n" +
                    "Earned by Paladins at Lv. 10",
    :condition => "@class_id == 3 && level >= 10", 
    1 => [ 100,   35, "DEF +3",      "",             "@bonus[:def] += 3"],
    2 => [ 300,   37, "MDF +3",      "",             "@bonus[:mdf] += 3"],
    3 => [ 600,  139, "Super Guard", "Learn: Super Guard", "learn_skill(92)"],
    4 => [1000,   32, "Vitality",    "Max HP +30",   "@bonus[:mhp] += 30"],
    5 => [1500,   37, "MDF +5",      "",             "@bonus[:mdf] += 5"],
  }
  #---------------------------
  TITLE[:mystic_fencer] = {
    :name => "Mystic Fencer",
    :icon => 126,
    :description => "Beautifully blends magic and swordplay in battle.\n" +
                    "Earned by Spellblades at Lv. 10",
    :condition => "@class_id == 4 && level >= 10", 
    1 => [ 100,   34, "ATK +3",        "",            "@bonus[:atk] += 3"],
    2 => [ 300,   36, "MAT +3",        "",            "@bonus[:mat] += 3"],
    3 => [ 600,  131, "Magic Barrier", "Learn: Magic Barrier", "learn_skill(97)"],
    4 => [1000,   32, "Vitality",      "Max HP +30",  "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",        "",            "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:far_east_warrior] = {
    :name => "Far East Warrior",
    :icon => 126,
    :description => "An impressive example of Eastern discipline.\n" +
                    "Earned by Samurai at Lv. 10",
    :condition => "@class_id == 5 && level >= 10",
    1 => [ 100,   34, "ATK +3",     "",                  "@bonus[:atk] += 3"],
    2 => [ 300,   38, "AGI +4",     "",                  "@bonus[:agi] += 4"],
    3 => [ 600,  132, "Hassou",     "Learn: Hassou",     "learn_skill(102)"],
    4 => [1000,   32, "Vitality",   "Max HP +30",        "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",     "",                  "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:fletcher] = {
    :name => "Fletcher",
    :icon => 126,
    :description => "Trained in all aspects of the bow and arrow.\n" +
                    "Earned by Archers at Lv. 10",
    :condition => "@class_id == 6 && level >= 10",
    1 => [ 100,   34, "ATK +3",      "",                   "@bonus[:atk] += 3"],
    2 => [ 300,   37, "MDF +3",      "",                   "@bonus[:mdf] += 3"],
    3 => [ 600,  133, "Zero Shadow", "Learn: Zero Shadow", "learn_skill(107)"],
    4 => [1000,   32, "Vitality",    "Max HP +30",         "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",      "",                   "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:vagabond] = {
    :name => "Vagabond",
    :icon => 126,
    :description => "Can't stay in one place for too long.\n" +
                    "Earned by Theives at Lv. 10",
    :condition => "@class_id == 7 && level >= 10", 
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,  134, "Thief's Luck", "Learn: Thief's Luck", "learn_skill(112)"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:acolyte] = {
    :name => "Acolyte",
    :icon => 126,
    :description => "An attendant of the church and of the needy.\n" +
                    "Earned by Priestesses at Lv. 10",
    :condition => "@class_id == 8 && level >= 10", 
    1 => [ 100,   36, "MAT +3", "",             "@bonus[:mat] += 3"],
    2 => [ 300,   37, "MDF +3", "",             "@bonus[:mdf] += 3"],
    3 => [ 600,  135, "Saint",  "Learn: Saint", "learn_skill(69)"],
    4 => [1000,   33, "Energy", "Max MP +10",   "@bonus[:mmp] += 10"],
    5 => [1500,   36, "MAT +5", "",             "@bonus[:mat] += 5"],
  }
  #---------------------------
  TITLE[:enchantress] = {
    :name => "Enchantress",
    :icon => 126,
    :description => "Men are beguiled by both her beauty and magic.\n" +
                    "Earned by Witches at Lv. 10",
    :condition => "@class_id == 9 && level >= 10", 
    1 => [ 100,   36, "MAT +3",   "",                "@bonus[:mat] += 3"],
    2 => [ 300,   38, "AGI +3",   "",                "@bonus[:agi] += 3"],
    3 => [ 600,  136, "Blizzard", "Learn: Blizzard", "learn_skill(57)"],
    4 => [1000,   32, "Vitality", "",                "@bonus[:mhp] += 30"],
    5 => [1500,   37, "MDF +5",   "",                "@bonus[:mdf] += 5"],
  }
  #---------------------------
  TITLE[:thaumaturge] = {
    :name => "Thaumaturge",
    :icon => 126,
    :description => "Controller of the elements.\n" +
                    "Earned by Sages at Lv. 10",
    :condition => "@class_id == 10 && level >= 10", 
    1 => [ 100,   36, "MAT +3",  "",               ""],
    2 => [ 300,   35, "DEF +3",  "",               ""],
    3 => [ 600,  136, "Spark",   "Learn: Spark",   "learn_skill(61)"],
    4 => [1000,   33, "Energy",  "Max MP +10",     "@bonus[:mmp] += 10"],
    5 => [1500,   39, "LUK +5",  "",               ""],
  }
  #---------------------------
  TITLE[:freebie] = {
    :name => "Freebie",
    :icon => 126,
    :description => "This title is on the house!\n" + 
                    "Earned after any battle.",
    :condition => "true", # "true" means the actor will always learn  
                          # the title after 1 battle.
    1 => [ 100,   32, "Vitality", "Max HP +10", "@bonus[:mhp] += 10"],
    2 => [ 300,   34, "ATK +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   32, "Vitality", "Max HP +20", "@bonus[:mhp] += 20"],
    4 => [1000,   34, "ATK +5",   "",           "@bonus[:atk] += 5"],
    5 => [1500,   32, "Vitality", "Max HP +30", "@bonus[:mhp] += 30"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:unobtainable] = {
    :name => "Unobtainable",
    :icon => 126,
    :description => "This title is unobtainable after battles.\n" + 
                    "You can still use the add_title method though.",
    :condition => "false", # "false" means the actor will never learn  
                           # the title after battles. An empty string ""
                           # in this script also means false.
    1 => [ 100,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    2 => [ 300,   36, "MAT +3",   "",        "@bonus[:mat] += 3"],
    3 => [ 600,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    4 => [1000,   36, "MAT +5",   "",        "@bonus[:mat] += 5"],
    5 => [1500,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    :mastery_sp => 5000,
  }
  #---------------------------
  TITLE[:survivor] = {
    :name => "Survivor",
    :icon => 126,
    :description => "A title given to those who survive a battle with\n" + 
                    "5% HP or less.",
    :condition => "hp < (mhp * 0.05) && alive?", 
                # This :condition statement translated into English is:
                # "Is the actor's current HP is less than 5% of the 
                #  actor's maximum AND is the actor alive?"
    1 => [ 100,   32, "Vitality", "Max HP +10", "@bonus[:mhp] += 10"],
    2 => [ 300,   35, "DEF +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   32, "Vitality", "Max HP +20", "@bonus[:mhp] += 20"],
    4 => [1000,   39, "LUK +2",   "",           "@bonus[:luk] += 2"],
    5 => [1500,   32, "Vitality", "Max HP +30", "@bonus[:mhp] += 30"],
    :mastery_sp => 3000,
  }

  #---------------------------
  TITLE[:not_enough_mana] = {
    :name => "Not Enough Mana",
    :icon => 126,
    :description => "For those who hunger for more knowledge...\n" +
                    "Earned after achieving more than 250 Max MP.",
    :condition => "mmp > 250",  # if the actor's Max MP is over 250
    1 => [ 100,   33, "Energy", "Max MP +10", "@bonus[:mmp] += 10"],
    2 => [ 300,   36, "MAT +3", "",           "@bonus[:mat] += 3"],
    3 => [ 600,   33, "Energy", "Max MP +10", "@bonus[:mmp] += 10"],
    4 => [1000,   37, "MDF +5", "",           "@bonus[:mdf] += 5"],
    5 => [1500,   33, "Energy", "Max MP +10", "@bonus[:mhp] += 10"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:traveler] = {
    :name => "Traveler",
    :icon => 126,
    :description => "All roads lead to somewhere that's not here.\n" +
                    "Awarded after taking over 1000 steps.",
    :condition => "$game_party.steps > 1000", # if Steps is more than 1000
    1 => [ 100,   36, "MAT +2", "", "@bonus[:mat] += 2"],
    2 => [ 300,   37, "MDF +3", "", "@bonus[:mdf] += 3"],
    3 => [ 600,   38, "AGI +5", "", "@bonus[:agi] += 5"],
    4 => [1000,   37, "MDF +3", "", "@bonus[:mdf] += 3"],
    5 => [1500,   36, "MAT +5", "", "@bonus[:mhp] += 20"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:adventurer] = {
    :name => "Adventurer",
    :icon => 126,
    :description => "Few people achieve this childhood dream.",
    :condition => "level >= 20", # if actor's level more than or equal to 20
    1 => [ 100,   33, "Energy",   "Max MP +5",  "@bonus[:mmp] += 5"],
    2 => [ 300,   35, "DEF +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   36, "MAT +4",   "",           "@bonus[:mat] += 4"],
    4 => [1000,   38, "AGI +3",   "",           "@bonus[:agi] += 3"],
    5 => [1500,   32, "Vitality", "Max HP +20", "@bonus[:mhp] += 20"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:all_by_myself] = {
    :name => "All By Myself",
    :icon => 124,
    :description => "Don't wanna be all by myself...\n" +
                    "Awarded after completing a battle alone.",
    :condition => "$game_party.members.size == 1", # if alone in battle
    1 => [ 100,   39, "LUK +2", "",                "@bonus[:luk] += 2"],
    2 => [ 300,   38, "AGI +3", "",                "@bonus[:agi] += 3"],
    3 => [ 600,  116, "Strong Attack", "Learn: Strong Attack", "learn_skill(80)"],
    4 => [1000,   38, "AGI +3", "",                "@bonus[:agi] += 3"],
    5 => [1500,   34, "ATK +4", "",                "@bonus[:atk] += 4"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:ambidextrous] = {
    :name => "Ambidextrous",
    :icon => 11,
    :description => "\"If one sword has a power of 100, then using\n" +
                    "two swords would make it 200, right?\" ",
    :condition => "dual_wield?", # if actor has dual wield feature
    1 => [ 100,   38, "AGI +2", "", "@bonus[:agi] += 2"],
    2 => [ 300,   34, "ATK +3", "", "@bonus[:atk] += 3"],
    3 => [ 600,   38, "AGI +3", "", "@bonus[:agi] += 3"],
    4 => [1000,   34, "ATK +3", "", "@bonus[:atk] += 3"],
    5 => [1500,   38, "AGI +4", "", "@bonus[:agi] += 4"],
    :mastery_sp => 3000,
  }
  #---------------------------
  TITLE[:paragon] = {
    :name => "Paragon",
    :icon => 117,
    :description => "Awarded after reaching level 75.",
    :condition => "level >= 75", # if actor's level more than or equal to 75
    1 => [ 100,   32, "Vitality",  "Max HP +30",  "@bonus[:mhp] += 30"],
    2 => [ 300,   36, "MAT +3",    "",            "@bonus[:mat] += 3"],
    3 => [ 600,   33, "Energy",    "Max MP +15",  "@bonus[:mmp] += 15"],
    4 => [1000,   34, "ATK +3",    "",            "@bonus[:atk] += 3"],
    5 => [1500,  117, "EXP Boost", "EXP Up +25%", "@bonus[:exr] += 0.25"],
  }
  #---------------------------
  TITLE[:zero_to_hero] = {
    :name => "Zero to Hero",
    :icon => 116,
    :description => "All heroes start somewhere.\n" +
                    "Obtained after reaching Lv. 90",
    :condition => "level >= 90",
    1 => [ 100,   38, "AGI +2", "", "@bonus[:agi] += 2"],
    2 => [ 300,   34, "ATK +3", "", "@bonus[:atk] += 3"],
    3 => [ 600,   38, "AGI +3", "", "@bonus[:agi] += 3"],
    4 => [1000,   34, "ATK +3", "", "@bonus[:atk] += 3"],
    5 => [1500,   38, "AGI +4", "", "@bonus[:agi] += 4"],
  }
  #---------------------------
  TITLE[:blessed] = {
    :name => "Blessed",
    :icon => 116,
    :description => "Blessed by an angel. Provides HP regeneration.\n" +
                    "Also provides MP regeneration when mastered.",
    :condition => "true",
    1 => [ 100,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    2 => [ 300,   36, "MAT +3",   "",        "@bonus[:mat] += 3"],
    3 => [ 600,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    4 => [1000,   36, "MAT +5",   "",        "@bonus[:mat] += 5"],
    5 => [1500,   32, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    :states => [14],
    :mastery_states => [14, 15],
  }
  #---------------------------
  TITLE[:marathon_man] = {
    :name => "Marathon Man",
    :icon => 126,
    :description => "Given after 2 hours of gameplay.",
    :condition => "($game_system.playtime / 60 / 60) >= 2",
    1 => [ 100,   32, "Vitality", "Max HP +10", "@bonus[:mhp] += 10"],
    2 => [ 300,   35, "DEF +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   32, "Vitality", "Max HP +20", "@bonus[:mhp] += 20"],
    4 => [1000,   35, "DEF +7",   "",           "@bonus[:def] += 7"],
    5 => [1500,   32, "Vitality", "Max HP +30", "@bonus[:mhp] += 30"],
  }
  #---------------------------
  TITLE[:millionaire_miser] = {
    :name => "Millionaire Miser",
    :icon => 126,
    :description => "Awarded after the party holds over 1,000,000 Gold.\n" +
                    "You are the one percent.",
    :condition => "$game_party.gold >= 1000000",
    1 => [ 100,   39, "LUK +2", "", "@bonus[:luk] += 2"],
    2 => [ 300,   38, "AGI +3", "", "@bonus[:agi] += 3"],
    3 => [ 600,   39, "LUK +3", "", "@bonus[:luk] += 3"],
    4 => [1000,   38, "AGI +3", "", "@bonus[:agi] += 3"],
    5 => [1500,   39, "LUK +4", "", "@bonus[:luk] += 4"],
  }
  #---------------------------
  TITLE[:newbie] = {
    :name => "Newbie",
    :icon => 126,
    :description => "Awared after 5 battles.\n" +
                    "Win or lose, it still counts!",
    :condition => "$game_system.battle_count >= 5",
    1 => [ 100,   33, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    2 => [ 300,   36, "MAT +3",   "",        "@bonus[:mat] += 3"],
    3 => [ 600,   33, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
    4 => [1000,   36, "MAT +7",   "",        "@bonus[:mat] += 7"],
    5 => [1500,   33, "Energy", "Max HP +5", "@bonus[:mmp] += 5"],
  }
  #---------------------------
  TITLE[:seasoned_fighter] = {
    :name => "Seasoned Fighter",
    :icon => 126,
    :description => "Awarded after 100 encounters.",
    :condition => "$game_system.battle_count >= 100",
    1 => [ 100,   32, "Vitality", "Max HP +10", "@bonus[:mhp] += 10"],
    2 => [ 300,   34, "ATK +3",   "",           "@bonus[:atk] += 3"],
    3 => [ 600,   32, "Vitality", "Max HP +20", "@bonus[:mhp] += 20"],
    4 => [1000,   34, "ATK +7",   "",           "@bonus[:atk] += 7"],
    5 => [1500,   :vitality_30],
  }
  #---------------------------
  TITLE[:suave] = {
    :name => "Suave",
    :icon => 126,
    :description => "He's sexy and he knows it.",
    :condition => "true",
    1 => [ 100,   39, "LUK +1", "",                "@bonus[:luk] += 1"],
    2 => [ 300,   35, "DEF +3", "",                "@bonus[:def] += 3"],
    3 => [ 600,   24, "X-Stun", "Stun Resist +2%", "@state_bonus[8] += 0.02"],
    4 => [1000,   37, "MDF +4", "",                "@bonus[:mdf] += 4"],
    5 => [1500,   34, "ATK +4", "",                "@bonus[:atk] += 4"],
  }
  #---------------------------
  TITLE[:sole_survivor] = {
    :name => "Sole Survivor",
    :icon => 126,
    :description => "Given to those who survived a tough\n" +
                    "battle alone...",
    :condition => "sole_survivor?", # Uses a custom-made method
    1 => [ 100,   :vitality_30],
    2 => [ 300,   35, "DEF +5",   "",           "@bonus[:def] += 5"],
    3 => [ 600,   :vitality_30],
    4 => [1000,   39, "LUK +5",   "",           "@bonus[:luk] += 5"],
    5 => [1500,   :vitality_30],
    :mastery_sp => 3000,
  }
  
  #---------------------------
  TITLE[:item_collector] = {
    :name => "Item Collector",
    :icon => 224,
    :description => "Awarded after obtaining 50 different items.",
    :condition => "$game_party.all_items.uniq.size >= 50",
    1 => [ 100,   :vitality_30],
    2 => [ 300,   36, "MAT +3",       "",                  "@bonus[:mat] += 3"],
    3 => [ 600,   33, "Energy",       "Max MP +15",        "@bonus[:mmp] += 15"],
    4 => [1000,   34, "ATK +3",       "",                  "@bonus[:atk] += 3"],
    5 => [1500,  117, "Pharmacology", "Item Healing +10%", "@bonus[:pha] += 0.10"],
  }
  #---------------------------
  TITLE[:hipster] = {
    :name => "Hipster",
    :icon => 518,
    :description => "\"Definitions are too mainstream.\"\n" +
                    "Awarded after mastering 1 title.",
    :condition => "mastered_title_count >= 1",
    1 => [ 100,   :energy_15],
    2 => [ 300,   35, "DEF +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   36, "MAT +4",   "",           "@bonus[:mat] += 4"],
    4 => [1000,   38, "AGI +3",   "",           "@bonus[:agi] += 3"],
    5 => [1500,   :vitality_30],
  }
  #---------------------------
  TITLE[:mastery_master] = {
    :name => "Mastery Master",
    :icon => 518,
    :description => "Awarded after mastering 20 titles.",
    :condition => "mastered_title_count >= 20",
    1 => [ 100,   :energy_15],
    2 => [ 300,   35, "DEF +3",   "",           "@bonus[:def] += 3"],
    3 => [ 600,   36, "MAT +4",   "",           "@bonus[:mat] += 4"],
    4 => [1000,   38, "AGI +3",   "",           "@bonus[:agi] += 3"],
    5 => [1500,   :vitality_30],
  }
  #---------------------------
  TITLE[:axe_adept] = {
    :name => "Axe Adept",
    :icon => 115,
    :description => "\"This is why nobody tosses a dwarf!\"\n" +
                    "Awarded to axe wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 1 }",
                  # returns true if actor is holding a weapon 
                  # of type 1 (in default database, wtype_id 1 is "Axe"
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:claw_adept] = {
    :name => "Claw Adept",
    :icon => 115,
    :description => "\"Mistakes are always forgivable, if one has the\n" +
                    "courage to admit them.\" Awarded to claw wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 2 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:spear_adept] = {
    :name => "Spear Adept",
    :icon => 115,
    :description => "\"If you cannot sing Siegfried you can at least\n" +
                    "carry a spear.\" Awarded to spear wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 3 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:sword_adept] = {
    :name => "Sword Adept",
    :icon => 115,
    :description => "\"I'm pretty sure I'll be the main character.\"\n" +
                    "Awarded to sword wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 4 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:katana_adept] = {
    :name => "Katana Adept",
    :icon => 115,
    :description => "\"If on your journey, should you encounter God,\n" +
                    "God will be cut.\" Awarded to katana wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 5 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:bow_adept] = {
    :name => "Bow Adept",
    :icon => 115,
    :description => "\"I make any team better.\"\n" +
                    "Awarded to bow wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 6 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:dagger_adept] = {
    :name => "Dagger Adept",
    :icon => 115,
    :description => "\"Guns for show, knives for a pro.\"\n" +
                    "Awarded to dagger wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 7 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:hammer_adept] = {
    :name => "Hammer Adept",
    :icon => 115,
    :description => "\"YOU WANT ME TO PUT THE HAMMER DOWN?!\"\n" +
                    "Awarded to hammer wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 8 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:staff_adept] = {
    :name => "Staff Adept",
    :icon => 115,
    :description => "\"Made from life, protecting life, stronger\n" +
                    "than cold steel.\" Awarded to staff wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 9 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  #---------------------------
  TITLE[:gun_adept] = {
    :name => "Gun Adept",
    :icon => 115,
    :description => "\"There was a blur, and then shootin'. I didn't\n" +
                    "see no draw.\" Awarded to gun wielders.",
    :condition => "weapons.any? { |weapon| weapon.wtype_id == 9 }",
    1 => [ 100,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    2 => [ 300,   39, "LUK +3",       "",              "@bonus[:luk] += 3"],
    3 => [ 600,   34, "ATK +3",       "",              "@bonus[:atk] += 3"],
    4 => [1000,   32, "Vitality",     "Max HP +30",    "@bonus[:mhp] += 30"],
    5 => [1500,   38, "AGI +5",       "",              "@bonus[:agi] += 5"],
  }
  
  end # module ToGTitleSystem
end # module Bubs

