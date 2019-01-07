=begin
Barehand Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you get a character's atk without the weapon's stats being
applied. I'm likening it to a barehanded monk attack.
----------------------
Instructions
----------------------
Use only on skills used by party members and then in the formula refer to
a.barehand
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  
  def barehand
    value = param_base(2) + @param_plus[2]
    for armor in armors
      value += armor.params[2]
    end
    value *= param_rate(2) * param_buff_rate(2)
    [[value, param_max(2)].min, param_min(2)].max.to_i
  end
  
end