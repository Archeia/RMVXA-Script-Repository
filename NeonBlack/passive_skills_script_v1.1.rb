##-----------------------------------------------------------------------------
#  CP Passive Skills v1.1
#  Created by Neon Black
#  v1.1 - 12.9.2014 - Slight optimization
#  v1.0b - 9.5.2012 - Slight bug fix
#  v1.0 - 9.5.2012 - Wrote and debugged main script
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
#      Instructions:
#  Place this script in the "Materials" section of the scripts above main.
#  This script has no customization options and is plug and play.  To use this
#  script just follow two fairly simple steps.
#   1. Create a state with the passive buffs you would like a skill to add.
#   2. Add the line "passive[x]" without the quotes to a skill's notebox where
#      "x" is the ID of the state to be applied while the skill is learned.
#      Note that passives do not apply to enemies.
##-----------------------------------------------------------------------------
 
 
##-----------------------------------------------------------------------------
#  The following lines are the actual core code of the script.  While you are
#  certainly invited to look, modifying it may result in undesirable results.
#  Modify at your own risk!
##-----------------------------------------------------------------------------


$imported ||= {}
$imported["CP_PASSIVES"] = 1.1

class Game_BattlerBase  ## Alias the feature objects to get states and passives.
  alias cp_passive_f_objects feature_objects
  def feature_objects
    return cp_passive_f_objects if @passover
    return cp_passive_f_objects + passives
  end
  
  def passives  ## Returns an empty passive array for all battlers.
    return []
  end
end

class Game_Actor < Game_Battler  ## Gets passive states on a character.
  def passives
    res = []
    @passover = true
    skills.each do |skill|
      next if skill.passives.empty?
      res += skill.passives
    end
    @passover = false
    return res.collect {|ps| $data_states[ps]}
  end
end

class RPG::Skill < RPG::UsableItem
  def passives
    return @passives if @passives
    @passives = []
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /passive\[(\d+)\]/i
        @passives.push($1.to_i)
      end
    end
    @passives
  end
end


##-----------------------------------------------------------------------------
#  End of script.
##-----------------------------------------------------------------------------