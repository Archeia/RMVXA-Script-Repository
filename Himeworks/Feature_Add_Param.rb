=begin
#==============================================================================
 ** Feature: Add Param
 Author: Hime
 Date: Mar 29, 2013
------------------------------------------------------------------------------
 ** Change log
 Mar 29, 2013
   - added formula support
 Oct 11, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
------------------------------------------------------------------------------
 ** Required
 -Feature Manager
 (http://himeworks.com/2012/10/13/feature-manager/)
------------------------------------------------------------------------------
 Allows you to add parameters using constant values rather than percents.
 
 Tag object with
   <ft: add_param param_type value>
   
 Where param_type is one of
    mhp, mmp, atk, def, mat, mdf, agi, luk
    
 And the value can be a number or a formula that evaluates to a number.
 The formula takes a variable "a" for the actor, and "v" for game variables.
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Feature_AddParam"] = true
#==============================================================================
# ** Rest of the script
#==============================================================================
module Features
  module Add_Param
    FeatureManager.register(:add_param)
  end
end

class RPG::BaseItem
  
  def add_feature_add_param(code, data_id, args)
    data_id = FeatureManager::Param_Table[args[0].downcase]
    add_feature(code, data_id, args[1])
  end
end

class Game_Battler < Game_BattlerBase
  
  def eval_add_param_feature(formula, a, v=$game_variables)
    eval(formula)
  end
  
  def sum_add_param_features(param_id)
    @eval_add_feature = true
    sum = features_with_id(:add_param, param_id).inject(0) {|r, ft| r += eval_add_param_feature(ft.value, self)}
    @eval_add_feature = false
    return sum
  end
  
  alias :ft_add_param_plus :param_plus
  def param_plus(param_id)
    # if we're evaluating features, don't sum the features
    return ft_add_param_plus(param_id) if @eval_add_feature
    return sum_add_param_features(param_id) + ft_add_param_plus(param_id)
  end
end