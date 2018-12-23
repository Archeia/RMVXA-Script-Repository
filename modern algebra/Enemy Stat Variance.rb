#==============================================================================
#    Enemy Stat Variance
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: January 4, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to attach a variance to each enemy stat, so that 
#   enemy instances aren't all just clones of each other but can have stat 
#   differences.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    Just place the code for each of the stat variances you want into the notes
#   box of the Enemy in the Database. The possible codes are:
#  
#      \vary_hp[x]
#      \vary_mp[x]
#      \vary_atk[x]
#      \vary_def[x]
#      \vary_mat[x]
#      \vary_mdf[x]
#      \vary_agi[x]
#      \vary_luk[x]
#
#    Each of the codes will give a variance of x to the stat chosen. A variance
#   x means that the enemy will have a random number between 0 and x added to
#   its base stat. So, if the base stat set in the database is 120, and x is
#   set to 30, then that stat will be between 120 and 150 for any instance of
#   that enemy. So, if you are fighting two slimes, then one of them could have
#   that stat be 127 while the other has it at 142, for example.
#
#    If, instead of being added on, you want the variance to be by percentage,
#   then all you need to do is add a percentile sign:
#
#      \vary_hp[x%]
#      \vary_mp[x%]
#      \vary_atk[x%]
#      \vary_def[x%]
#      \vary_mat[x%]
#      \vary_mdf[x%]
#      \vary_agi[x%]
#      \vary_luk[x%]
#
#   If the codes have a percentage to them, then it will take a random number
#   between 0 and x and add that percentage of the stat to the enemy's stat. So,
#   if an enemy's max HP is 200 and you set \variance_hp%[10], then the script
#   will choose a random number between 0 and 10. In this case, let's say it
#   chooses 6, then .06*200 will be added to the enemy's HP, resulting in that
#   enemy having 212 HP
#
#    Additionally, it should be noted that these are stackable; it would be 
#   valid, for instance to have one enemy have this in its notebox:
#      \vary_hp[10%]\vary_hp[30]
#==============================================================================

$imported = {} unless $imported
$imported[:MA_EnemyStatVariance] = true

#==============================================================================
# ** RPG::Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variable - maesv_add_params
#    new method - initialize_maesv_data
#==============================================================================

class RPG::Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :maesv_add_params
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Enemy Stat Variance Data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize_maesv_data
    @maesv_add_params = []
    # Scan note for Variance Codes
    note.scan(/\\VARY[ _](.+?)\[(\d+)(%?)\]/i) {|param_n, value, percent|
      param_id = ["HP", "MP", "ATK", "DEF", "MAT", "MDF", "AGI", "LUK"].index(param_n.upcase)
      @maesv_add_params << [param_id, value.to_i + 1, !percent.empty?] if param_id
    }
  end
end

#==============================================================================
# ** Game_Enemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - initialize; all_features
#==============================================================================

class Game_Enemy < Game_Battler
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maesv_initialze_4gj1 initialize
  def initialize(*args, &block)
    @maesv_percent_params = [] # Initialize Percentile Params array
    maesv_initialze_4gj1(*args, &block)
    # Add to stats according to variance in notes
    enemy.initialize_maesv_data unless enemy.maesv_add_params
    enemy.maesv_add_params.each {|param_id, value, percent_true|
      if percent_true # Percentile
        @maesv_percent_params << RPG::BaseItem::Feature.new(FEATURE_PARAM, 
          param_id, 1.0 + (rand(value).to_f / 100.0))
      else            # Add the randomized value to the parameter
        add_param(param_id, rand(value)) 
      end
    }
    recover_all # Ensure the enemy is at full strength
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * All Features
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maesv_allfeatrs_5jk6 all_features
  def all_features(*args, &block)
    result = maesv_allfeatrs_5jk6(*args, &block) # Run Original Method
    result + @maesv_percent_params
  end
end