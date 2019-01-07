=begin
Effect -  Recruit Enemy
requested by : pikalyze

SCRIPT Requirement:
1)EST - BRIBE AND BATTLE ROYALE
http://pastebin.com/Nd8nXkaa

2)EST - Clone Actor
http://pastebin.com/w0TfMS8G

3)Tsukihime - Effect Manager
http://www.rpgmakervxace.net/topic/7395-effect-manager/

4)Tsukihime - simple text input script
http://www.rpgmakervxace.net/topic/4238-simple-text-input/page__hl__%2Btsukihime+%2Btext+%2Binput



tag the enemy with:

<eff: enemy_recruit x y rename? rand? sex>

x = actor id #required
y = level #required
rename? = true/false #true  - will be able to rename actor when adding it. 
                     #false - use default name in actor database
                     #default true if nil
rand? = true/false   #random name when the entered name is blank
                     #true  - will pick name using random name array in module
                     #false - will use default name for that actor_id
                     #default false if nil
sex = male or female #male  - will pick name from RANDOM_NAME_ARRAY_MALE
                     #female- will pick name from RANDOM_NAME_ARRAY_FEMALE
                     #default pick male name

example usage:
<eff: enemy_recruit 3 10>
will recruit actor using base actor 3 and will have lv 10
able to rename actor when adding it to party.
when naming it with blank name....
it will use default name in database (actor 3 name)

<eff: enemy_recruit 3 10 true true male>
will recruit actor using base actor 3 and will have lv 10
able to rename when adding it to party, 
random name when naming it with blank name
will choose male name in array

<eff: enemy_recruit 3 10 false>
will recruit actor using base actor 3 and will have lv 10
cannot rename when adding it to party, 
it will use default name in database (actor 3 name)

that enemy will recruited to party.
for the scene where you able to reject it. i use common event instead.
it's simpler than writing my own scene. too lazy :D.

=end
$imported = {} if $imported.nil?
$imported["Effect Enemy Recruit"] = true
#==============================================================================
# ** Rest of the script
#==============================================================================
module ESTRIOLE
  RECRUIT_ENEMY_COMMON_EVENT = 1
  TEXT_SHOWN_WHEN_NAMING_ENEMY = "Give it a name"
  RANDOM_NAME_ARRAY_MALE = [#don't remove this
  "Peter",
  "Ray",
  "Ganta",
  "Blanc",
  "Rocky",
  "Rambo",
  ]#don't remove this
  
  RANDOM_NAME_ARRAY_FEMALE = [#don't remove this
  "Prita",
  "Rie",
  "Rose",
  "Tifa",
  "Lightning",
  "Yuna",
  ]#don't remove this
  
end

module Effect
  module Manual_Opponents
    Effect_Manager.register_effect(:enemy_recruit)
  end
end

class Game_Party < Game_Unit
  attr_accessor :recruit_enemy
  alias game_party_initialize_recruit_actor initialize
  def initialize
    game_party_initialize_recruit_actor
    @recruit_enemy=[]
  end
end

class Game_Enemy < Game_Battler  
  
  def enemy_effect_enemy_recruit_battle_end(state, effect)
    return if self.dead?
    return if !self.bribed?
    actor_id = effect.value1[0].to_i
    actor_lv = effect.value1[1].to_i
    rename = effect.value1[2]
    rename = rename == "false"? false : true
    random = effect.value1[3]
    random = random == "true"? true : false
    sex    = effect.value1[4]
    sex    = sex    == "female"? "female" : "male"
    $game_party.recruit_enemy.push([actor_id,actor_lv,rename,random,sex])
  end

end


module BattleManager
  class <<self; alias battle_end_recruit_enemy battle_end; end
  def self.battle_end(result)
    battle_end_recruit_enemy(result)
    if $game_party.recruit_enemy.size !=0
    $game_temp.reserve_common_event(ESTRIOLE::RECRUIT_ENEMY_COMMON_EVENT)
    end
  end
end

class Game_Interpreter
  def recruit_enemy_yes
  id = $game_party.recruit_enemy[0][0]
  level = $game_party.recruit_enemy[0][1]
  size = $data_actors.size
  name = nil
  
  rename = $game_party.recruit_enemy[0][2]  
  random = $game_party.recruit_enemy[0][3]
  sex    = $game_party.recruit_enemy[0][4]
  
  if rename
  enter_text(text=ESTRIOLE::TEXT_SHOWN_WHEN_NAMING_ENEMY,Tsuki::Text_Input::Text_Variable,Tsuki::Text_Input::Max_Chars)
  name = $game_variables[Tsuki::Text_Input::Text_Variable]
    if random
      if sex = "female"
      name = ESTRIOLE::RANDOM_NAME_ARRAY_FEMALE.sample if $game_variables[Tsuki::Text_Input::Text_Variable]==""
      else
      name = ESTRIOLE::RANDOM_NAME_ARRAY_MALE.sample if $game_variables[Tsuki::Text_Input::Text_Variable]==""      
      end
    else
    name = nil if $game_variables[Tsuki::Text_Input::Text_Variable]==""
    end
  end
  $game_party.add_custom_actor(id,level,name)
  end

  def remove_first_recruit_stack
    return if $game_party.recruit_enemy.size == 0
    $game_party.recruit_enemy.delete_at(0)
  end
end