=begin
Secondary Classes
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you to give a character a second class they can learn
some or all of that classes skills and optionally inherit all of the
secondary classes traits and a percentage of it's paramaters.
----------------------
Instructions
----------------------
Setup the two variables in the module to your liking and any for any skill
that you wish to be primary only notetag the skill learning box (the one
with level, skill and notes) with <primary>
To change an actor's subclass call
$game_actors[x].change_sec_class(class_id)
To define a starting sub class notetag the actor like so:
<secclass x>
----------------------
Known bugs
----------------------
None
=end
module Fomar
  
  # Have all the features/traits of the secondary class
  SECONDARY_CLASSES_ADD_FEATURES = false
  # Percentage of secondary class's params to be added
  SECONDARY_CLASSES_PARAMS = 10
  
end

class Game_Actor < Game_Battler
  
  attr_accessor :sec_class_id
  
  alias sc_setup setup
  def setup(actor_id)
    @sec_class_id = 0
    if $data_actors[actor_id].note =~ /<secclass (.*)>/i
      @sec_class_id = $1.to_i
    end
    sc_setup(actor_id)
  end
  
  alias sc_init_skills init_skills
  def init_skills
    sc_init_skills
    return if sec_class_id == 0
    self.sec_class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level and 
        not $data_skills[learning.skill_id].note.include?("<primary>")
    end
  end
  
  def sec_class
    $data_classes[@sec_class_id]
  end
  
  alias sc_feature_objects feature_objects
  def feature_objects
    return sc_feature_objects if @sec_class_id == 0
    if Fomar::SECONDARY_CLASSES_ADD_FEATURES
      return sc_feature_objects + [self.sec_class]
    else
      return sc_feature_objects
    end
  end
  
  def change_sec_class(class_id)
    @sec_class_id = class_id
    refresh
  end
  
  alias sc_param_base param_base
  def param_base(param_id)
    if @sec_class_id == 0
      return sc_param_base(param_id)
    else
      return sc_param_base(param_id) + ((Fomar::SECONDARY_CLASSES_PARAMS * self.sec_class.params[param_id, @level])/100)
    end
  end
end