=begin
Extra Traits/Features on Level Up
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you to gain traits/features when you level up.
----------------------
Instructions
----------------------
To add a trait when you level you need to set it up so that you learn
a skill at that level, I reccomend making a new catagory called passive
and having them be part of that. Give it an appropriate name e.g.
"Half MP Cost" etc, in messages it will be followed by " was learned."
Then in the note box for the learning use the following notetag:
<extratrait x>
Then all the traits from the source data with that id will be added to 
the character.
Source data can refer to weapons, armours or states.
Set EXTRA_FEATURES_SOURCE to:
0 -> Weapons
1 -> Armours
2 -> States
By default it is set to states
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  # Set this constant to determine the source of the extra features.
  EXTRA_FEATURES_SOURCE = 2
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias ef_setup setup
  def setup(actor_id)
    @extra_features = Extra_Features.new
    @extra_features.features = []
    ef_setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  alias ef_feature_objects feature_objects
  def feature_objects
    ef_feature_objects + [@extra_features]
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ
  #--------------------------------------------------------------------------
  alias ef_level_up level_up
  def level_up
    level = @level + 1
    self.class.learnings.each do |learning|
      if learning.level == level
        if learning.note =~ /<extratrait (.*)>/i
           @extra_features.features += $data_weapons[$1.to_i].features if EXTRA_FEATURES_SOURCE == 0
           @extra_features.features += $data_armors[$1.to_i].features if EXTRA_FEATURES_SOURCE == 1
           @extra_features.features += $data_states[$1.to_i].features if EXTRA_FEATURES_SOURCE == 2
         end
       end
     end
     ef_level_up
  end
end

class Extra_Features
  attr_accessor :features
end