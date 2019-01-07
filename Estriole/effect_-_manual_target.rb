=begin
Add on requested by Non Ya
for EST - BRIBE AND BATTLE ROYALE
Agro system
  
requirement:
EST - BRIBE AND BATTLE ROYALE
Tsukihime Effect Manager 2.4 or above
EST - PERMANENT STATES SNIPPET (BELOW THIS SCRIPT IN SPOILER TAG)

to add the agro system.
-) every faction MUST have their own unique agro states
example faction a state is 45
faction a agro check state is 44
faction b state is 46
faction b agro check state is 47

from above example create states:
then in notetags add this:

for faction a agro check state:
<eff: manual_opponents 3 x true>
<eff: manual_friends 2 x true>
x is the faction a states.

for faction b agro check state:
<eff: manual_friends 2 x true>
<eff: manual_friends 2 x true>
x is the faction b states.

then at battle start add the faction states to each battler
then add the correct agro check states on top that faction state
example
slime a is faction a
slime b is faction b

at battle start:
slime a add state faction a
slime a add state agro check faction a
slime b add state faction b
slime b add state agro check faction b

thus both slime will attack each other ignoring the party.
but if party decide to attack slime b.
then state agro check faction b will removed and it will act as faction b behavior
(attack party and faction a)

#==============================================================================
this script general usage: (not only used for agro system)

  tag the state with this:
   
    <eff: manual_opponents x y z>
x= array
1: game_party
2: game_troop_same_state
3: game_troop_different_state

y= state used in same/different state check. if not used will use the tagged state
instead

z= true/false - default false
that state removed upon hit by allies/actor or not. (for agro system)

example 1:
    <eff: manual_opponents [1,3] 45>
translate to:
set the opponents to game party and all game troop which state not 45.
and that state not removed even when hit by actor/friends unit.

example 2:
    <eff: manual_opponents [3]>
    you add that notetags to state 23
set the opponents to game troop which state not 23. 
and will remove the state 23 whenever hit by friend units / actor. 


#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Manual_Opponents"] = true
#==============================================================================
# ** Rest of the script
#==============================================================================
module Effect
  module Manual_Opponents
    Effect_Manager.register_effect(:manual_opponents)
    Effect_Manager.register_effect(:manual_friends)
  end
end

class Game_Enemy < Game_Battler  
  
  def state_effect_manual_opponents_turn_start(state, effect)
    @manual_opponents_unit = nil if bribed?
    return if bribed?
    enemy_mode = effect.value1[0].to_i
    enemy_mode = [effect.value1[0].to_i] if effect.value1[0].is_a?(String)
    enemy_mode = effect.value1[0].to_a if effect.value1[0].is_a?(Range)
    check_state = state.id
    check_state = effect.value1[1].to_i if effect.value1[1]
    added_unit = []
    for mode in enemy_mode
      case mode
      when 1
        added_unit = $game_party.battle_members
      when 2
          for enemy in $game_troop.members
            if enemy.state?(check_state)
              added_unit.push(enemy) 
            end
          end #all troop that not faction member        
      when 3
          for enemy in $game_troop.members
            if !enemy.state?(check_state)
              added_unit.push(enemy) 
            end
          end #all troop that not faction member

      end #end case
      
    end#end for
    manual_unit = Game_Troop.new
    manual_unit.add_enemies_group(added_unit)
    @manual_opponents_unit = manual_unit
    
  end#end state effect add
  
  def state_effect_manual_opponents_guard(user, state, effect)
    remove_upon_hit = false
    remove_upon_hit = effect.value1[2] if effect.value1[2]
    remove_state(state.id) if (user.actor? || friends_unit.members.include?(user)) && remove_upon_hit
  end

  def state_effect_manual_opponents_remove(state, effect)
    @manual_opponents_unit = nil
  end

  #friends section
    def state_effect_manual_friends_turn_start(state, effect)
    @manual_friends_unit = nil if bribed?
    return if bribed?
    
    enemy_mode = effect.value1[0].to_i
    enemy_mode = [effect.value1[0].to_i] if effect.value1[0].is_a?(String)
    enemy_mode = effect.value1[0].to_a if effect.value1[0].is_a?(Range)
    check_state = state.id
    check_state = effect.value1[1].to_i if effect.value1[1]
    added_unit = []
    for mode in enemy_mode
      case mode
      when 1
        added_unit = $game_party.battle_members
      when 2
          for enemy in $game_troop.members
            if enemy.state?(check_state)
              added_unit.push(enemy) 
            end
          end #all troop that not faction member        
      when 3
          for enemy in $game_troop.members
            if !enemy.state?(check_state)
              added_unit.push(enemy) 
            end
          end #all troop that not faction member

      end #end case
      
    end#end for
    manual_unit = Game_Troop.new
    manual_unit.add_enemies_group(added_unit)
    @manual_opponents_unit = manual_unit
    
  end#end state effect add
  
  def state_effect_manual_friends_guard(user, state, effect)
    remove_upon_hit = false
    remove_upon_hit = effect.value1[2] if effect.value1[2]
    remove_state(state.id) if (user.actor? || friends_unit.members.include?(user)) && remove_upon_hit
  end

  def state_effect_manual_friends_remove(state, effect)
    @manual_opponents_unit = nil
  end

  
end

class Game_Troop < Game_Unit
  alias manual_opponents_initialize initialize
  def initialize
    manual_opponents_initialize
    @enemies = []
  end
  
  def add_enemies_group(unit)
    for enemy in unit
    @enemies.push(enemy)
    end
  end
  
end