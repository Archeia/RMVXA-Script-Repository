=begin
Transformation States
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you to transform in battle through the
application of states.
----------------------
Instructions
----------------------
Notetag the states:
<transformclass x>
Where x is the class id of the class you want to use.
<transformequips x>
<transformequips x,x>
<transformequips x,x,x,x,x>
Where x = -1 -> Use the original equipment
Where x = 0  -> Blank the equipment
Where x > 0  -> Use the equipment of id
Note your current equipment is copied and then the changes 
are applied. So you only need as many entries to cover you 
upto the last piece of equipment you want to change.

Note: Both are optional so use them as you want.
<transformequips 0> for example could be used for a disarm state.
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  
  def transform_class
    for state in @states
      if $data_states[state].transform_class > 0
        return $data_states[state].transform_class
      end
    end
    return 0
  end
  
  def transform_equips
    for state in @states
      unless $data_states[state].transform_equips == []
        return $data_states[state].transform_equips
      end
    end
    return []
  end
  
  alias ft_class class
  def class
    if transform_class > 0
      $data_classes[transform_class]
    else
      ft_class
    end
  end
  
  alias ft_skills skills
  def skills
    if transform_class > 0
      skills = []
      self.class.learnings.each do |learning|
        skills.push($data_skills[learning.skill_id]) if learning.level <= @level
      end
      return skills
    else
      ft_skills
    end
  end
  
  alias ft_equips equips
  def equips
    unless transform_equips == []
      equip_ids = transform_equips
      new_equips = ft_equips
      for i in 0..equip_ids.size - 1
        if equip_ids[i] == -1
          new_equips[i] = @equips[i].object
        elsif equip_ids[i] == 0
          new_equips[i] = nil
        else
          if index_to_etype_id(i) == 0
            new_equips[i] = $data_weapons[equip_ids[i]]
          else
            new_equips[i] = $data_armors[equip_ids[i]]
          end
        end
      end
      return new_equips
    else
      ft_equips
    end
  end
  
end

module RPG
  class State
    
    def transform_class
      if @note =~ /<transformclass (.*)>/i
        return $1.to_i
      end
      return 0
    end
    
    def transform_equips
      if @note =~ /<transformequips (.*)>/i
        equips = []
        for equip in $1.split(",")
          equips.push(equip.to_i)
        end
        return equips
      end
      return []
    end
    
  end
end