#==============================================================================
#    Equipment Stat Variance
#    Version: 1.0.0
#    Author: modern algebra (rmrk.net)
#    Date: 26 December 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to set it so that the stats of equipment can change
#   between equipment of the same type. For example, the party could find two
#   hand axes, one having 15 ATK the other having 18 ATK.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    This script REQUIRES the Item Instances Base script, which is at:
#
#      http://rmrk.net/index.php/topic,47427.0.html
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials. It must also be below the Item Instances Base script.
#
#    To set it so that an equippable item varies in any particular stat, use 
#   put of the following codes into the note field of the item:
#
#            \var_mhp[n]              \var_mat[n]
#            \var_mmp[n]              \var_mdf[n]
#            \var_atk[n]              \var_agi[n]
#            \var_def[n]              \var_luk[n]
#
#   where you replace n with the integer amount you want the stat to vary by. 
#   Basically, the way the script works is that it will take a random number 
#   between 0 and n and add it to the basic value for that equippable item that
#   you set in the database.
#
#  EXAMPLE:
#
#    If you have a hand axe with 15 ATK and 3 DEF, and you set the following
#   in its note field:
#
#      \var_atk[5]\var_def[2]
#
#   then any new instance of the hand axe will have between 15 and 20 ATK, and 
#   between 3 and 5 DEF. 
#==============================================================================

if $imported && $imported[:"MA_InstanceItemsBase 1.0.0"]

  $imported[:MA_ItemStatVariance] = true

  # Push the Variance code into the checks for instance items
  MA_INSTANCE_ITEMS_BASE[:regexp_array].push(/\\VAR_\S*?\[\s*\d+\s*\]/i)

#==============================================================================
# *** MAIIB_RPG_EquipItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - random_variance
#==============================================================================

module MAIIB_RPG_EquipItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Random Variance
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def random_variance
    @rand_vars = self.note.scan(/\\VAR_(\S*?)\[\s*(\d+)\s*\]/i) unless @rand_vars
    return @rand_vars
  end
end

#==============================================================================
# *** Game_IEquipItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - initialize
#    new method - eval_stat_variance
#==============================================================================

module Game_IEquipItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maisv_iniz_4ty5 initialize
  def initialize(*args)
    maisv_iniz_4ty5(*args) # Run Original Method
    data.random_variance.each { |stat, variance| 
      eval_stat_variance(stat.downcase.to_sym, variance.to_i) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Evaluate Stat Variance
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def eval_stat_variance(stat, variance)
    stat = :"m#{stat}"if stat == :hp || stat == :mp
    ix = [:mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk].index(stat)
    self.params[ix] = data.params[ix] + rand(variance + 1) if ix
  end
end

else
  msgbox("Item Stat Variance could not be installed because you either do not have Instance Items Base or because you have that script placed below the Item Stat Variance script.")
end