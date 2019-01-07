=begin
#===============================================================================
 Title: Feature Conditions
 Author: Hime
 Date: Nov 22, 2014
--------------------------------------------------------------------------------
 ** Change log
 Nov 22, 2014
   - fixed bug where conditions were always false
 Nov 14, 2014
   - added checks to prevent recursive calls
 Jul 10, 2014
   - added support for tagging multiple features in one note-tag
 Jul 9, 2014
   - added support for individual features
 Jul 16, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to add "feature conditions" to any objects that hold
 features. These conditions are used to control whether the features from an
 object are applied to your actor or not.
 
 For example, suppose you have shield equips that have special elemental
 immunities when the "guard" state is applied. You can add these features to
 the shield and then use feature conditions to indicate that the "guard" state
 must be applied before the features are transferred.
 
 Feature conditions can be applied at the object level, which means all
 conditions must be met for any features to be applied.
 
 Feature conditions can also be applied at the feature level, which provides
 finer control over when specific features can be applied.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To add a feature conditions, use the notetag for any objects with features,
 such as Actors, Classes, Weapons, Armors, Enemies, or States. If you are using
 the Feature Manager, then it will be applied to skills and items as well.
 
 == Object-level feature conditions ==
 
 For object-level conditions, use the note-tag of the form
 
   <feature condition>
      FORMULA
   </feature condition>
   
 For any valid ruby formula that returns true or false.
 Three variables are available for your convenience:
 
   a - subject the feature applies to
   s - game switches
   v - game variables
   
 By "subject" I refer to "actor" or "enemy". For example, a state can be applied
 to both actors or enemies, so if the enemy has the state, then that enemy is
 the subject. If the actor has the state, then that actor is the subject. Be
 careful when writing your formulas.
 
 == Feature-level conditions ==
 
 Applying conditions to individual features is the same as object-level
 conditions, except in the note-tag you specify which feature it applies to
 
   <feature condition: x>
     FORMULA
   </feature condition>
  
   <feature condition: x, y, ... >
     FORMULA
   </feature condition>
   
 Where x and y are the ID's of the features. The ID of the feature is based on
 its position in the list, so the feature at the top of the list has ID 1, the
 next one has ID 2, and so on.
 
 You can specify multiple ID's by separating them with commas.
   
--------------------------------------------------------------------------------
 ** Examples
 
 Here are some quick examples of some conditions you might have
 
 * Feature 2 and 3 are applied only if the party has more than 5000 gold
 
   <feature condition: 2,3 >
     $game_party.gold > 5000
   </feature condition>
     
 * Features of the object are only applied if state 23 is applied
 
   <feature condition>
     a.state?(23)
   </feature condition>
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_FeatureConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Feature_Conditions
    Regex = /<feature[-_ ]condition>(.*?)<\/feature[-_ ]condition>/im
    Ft_Regex = /<feature[-_ ]condition:\s*(.*?)\s*>(.*?)<\/feature[-_ ]condition>/im
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class BaseItem
    def feature_conditions_met?(subject)
      load_notetag_feature_conditions unless @feature_conditions_loaded
      return eval_feature_conditions(subject)
    end
    
    def load_notetag_feature_conditions
      @feature_conditions_loaded = true
      conditions = "true"
      res = self.note.scan(TH::Feature_Conditions::Regex)
      res.each_with_index do |cond, i|
        conditions << " && " if i > 0
        conditions << cond[0]
      end
      build_condition_method(conditions.empty? ? "true" : conditions)      
      load_notetag_individual_feature_conditions
    end
    
    def load_notetag_individual_feature_conditions
      results = self.note.scan(TH::Feature_Conditions::Ft_Regex)
      results.each do |res|
        ids = res[0].strip.split(",")
        ids.each do |id|
          id = id.to_i - 1
          @features[id].feature_condition = res[1]
        end
      end
    end
    
    #---------------------------------------------------------------------------
    # Builds the condition-checking method. This is done for performance
    # reasons since features are checked several hundred times very frequently.
    # It assumes the conditions do not change dynamically once they have been
    # loaded.
    #---------------------------------------------------------------------------
    def build_condition_method(conditions)
      eval(
        "def eval_feature_conditions(a, v=$game_variables, s=$game_switches)
           #{conditions}
         end"
      )
    end
  end
  
  class BaseItem::Feature
    attr_accessor :feature_condition
    
    def feature_condition_met?(subject)
      return true unless @feature_condition
      eval_feature_condition(subject)
    end
    
    def eval_feature_condition(a, v=$game_variables, s=$game_switches)
      eval(@feature_condition)
    end
  end
end

class Game_BattlerBase
  
  def feature_conditions_met?(obj, subject)
    obj.feature_conditions_met?(subject)
  end
  
  alias :th_feature_conditions_all_features :all_features
  def all_features    
    return [] if @feature_eval_checking
    @feature_eval_checking = true
    fts = th_feature_conditions_all_features.select {|ft| ft.feature_condition_met?(self)}
    @feature_eval_checking = false
    return fts
  end
end

class Game_Actor < Game_Battler
  
  alias :th_feature_conditions_feature_objects :feature_objects
  def feature_objects
    fts = th_feature_conditions_feature_objects.select {|obj|
      feature_conditions_met?(obj, self)
    }
    return fts
  end
end

class Game_Enemy < Game_Battler
  
  alias :th_feature_conditions_feature_objects :feature_objects
  def feature_objects
    fts = th_feature_conditions_feature_objects.select {|obj|
      feature_conditions_met?(obj, self)
    }
    return fts    
  end
end