=begin
 ** EST - BRIBE AND BATTLE ROYALE v1.3
 author : estriole
 
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 version history
 v1.0 - finish the script
 v1.1 - change some method to alias for better compatibility
 v1.2 - add some method alive and dead method for each faction & bribed
 v1.3 - fix some bugs where the faction a or b cannot target bribed member
 
 now you could use
 $game_party.alive_faction_a_members.size
 to check how many faction_a members still alive
 or
 $game_party.alive_bribed_members.size
 to check how many bribed members still alive
 (will be use for actor recruiting system add on later. but still stuck a little
 on it :D)
 
 this script have two function:
 1) make bribed enemy:
 bribed enemy will attack other enemy beside all bribed members. how you make the
 enemy to be bribed. just add the state to that enemy.
 (for the bribe system is up to you ex: bribed by hitting enemy with skill that
 give money, for complex one... enemy have loyalty, etc)
 
 note: bribed enemy is excluded from $game_troop.alive_members
 so you cannot hit them (hey they are your allies... don't hit kill them will you)
 unfortunately i haven't added function so our actor could heal the bribed enemy.
 since it need to rewrite the windows actor selection. and could be problems
 with compatibility with other script.
 
 2) do battle royale
 currently this support battle royale.
 we assign enemy to faction. example:
 slimeA, slimeB is faction A
 batA, batB is faction B
 then slime will hit either our party or faction B members.
 and bat will hit either our party or faction A members.
 thus the battle royale begin
 
 to set the faction just add the state at battle start using troop event pages
 example : turn 0.
 slimeA +faction A state, slimeB +faction A state
 BatA +faction B state, BatB +faction B state.
 
 this script already tested to work with normal battle system and
 victor animated battle system (victor map battle havent tested yet)
 i also used it with yanfly ace battle engine.
 if any bugs occur using above system just tell me and i will try to fix it.
 
 unfortunately i don't use other battle system and thus i might not make
 compatibility with other battle system. especially tankentai (just because it's
 hard to make compatibility with tankentai)..
   
 FOR SCRIPTER ONLY
 if you want more than two factions... example 6 team battle royale...
 (althought i doubt how you set the troops position :D)  
 just do this following steps
 1) add in module ESTRIOLE the faction state
 2) define the faction_x? method (see faction a and b example)
 3) add one more conditional in check_custom_opponents_unit_value
    if faction_x?
    faction_opponents_unit = Game_Troop.new
    faction_opponents_unit.setup_faction_opponents(ESTRIOLE::FACTION_X_STATE)
    @custom_opponents_unit = faction_opponents_unit
    end
   
    after if faction_b? condition and above if bribed? condition
   
 4) do the same with def check_custom_friends_unit_value
    if faction_x?
    faction_friends_unit = Game_Troop.new
    faction_friends_unit.setup_faction_friends(ESTRIOLE::FACTION_X_STATE)
    @custom_friends_unit = faction_friends_unit
    end
   
    after if faction_b? condition and above if bribed? condition
   
 done. now you have 3 faction for 4 way battle
 
=end
 
############### CONFIGURATION ##################################################
 
module ESTRIOLE
  BRIBE_STATE     = 48
  FACTION_A_STATE = 46
  FACTION_B_STATE = 47
end
 
######### DO NOT EDIT PAST THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING #########
 
class Game_Enemy < Game_Battler
  attr_accessor :manual_opponents_unit
  attr_accessor :manual_friends_unit
 
  alias battle_royale_opponents_unit opponents_unit
  def opponents_unit
  return @manual_opponents_unit if manual_opponents_unit
  check_custom_opponents_unit_value
  return @custom_opponents_unit
  end
 
  alias battle_royale_friends_unit friends_unit
  def friends_unit
  return @manual_friends_unit if manual_friends_unit
  check_custom_friends_unit_value
  return @custom_friends_unit
  end
 
  def alive_opponents_unit
  opponents_unit.select {|actor| actor.alive? }
  end
  def dead_opponents_unit
  opponents_unit.select {|actor| actor.dead? }    
  end
  def alive_friends_unit
  friends_unit.select {|actor| actor.alive? }
  end
  def dead_friends_unit
  friends_unit.select {|actor| actor.dead? }    
  end
 
  def check_custom_opponents_unit_value
    @custom_opponents_unit = battle_royale_opponents_unit
    if faction_a?
    faction_opponents_unit = Game_Troop.new
    faction_opponents_unit.royale_flag = true
    faction_opponents_unit.setup_faction_opponents(ESTRIOLE::FACTION_A_STATE)
    @custom_opponents_unit = faction_opponents_unit
    end
    if faction_b?
    faction_opponents_unit = Game_Troop.new
    faction_opponents_unit.royale_flag = true
    faction_opponents_unit.setup_faction_opponents(ESTRIOLE::FACTION_B_STATE)
    @custom_opponents_unit = faction_opponents_unit
    end
    if bribed?
    bribed_opponents_unit = Game_Troop.new
    bribed_opponents_unit.royale_flag = true
    bribed_opponents_unit.setup_bribed_opponents
    @custom_opponents_unit = bribed_opponents_unit
    end
  end
 
  def check_custom_friends_unit_value
    @custom_friends_unit = battle_royale_friends_unit
    if faction_a?
    faction_friends_unit = Game_Troop.new
    faction_friends_unit.royale_flag = true
    faction_friends_unit.setup_faction_friends(ESTRIOLE::FACTION_A_STATE)
    @custom_friends_unit = faction_friends_unit
    end
    if faction_b?
    faction_friends_unit = Game_Troop.new
    faction_friends_unit.royale_flag = true
    faction_friends_unit.setup_faction_friends(ESTRIOLE::FACTION_B_STATE)
    @custom_friends_unit = faction_friends_unit
    end
    if bribed?
    faction_friends_unit = Game_Troop.new
    faction_friends_unit.royale_flag = true
    faction_friends_unit.setup_bribed_friends
    @custom_friends_unit = faction_friends_unit
    end  
  end
 
  def bribed?
  state?(ESTRIOLE::BRIBE_STATE) #bribe state here
  end
 
  def faction_a?
  state?(ESTRIOLE::FACTION_A_STATE) #state that mark faction A
  end
 
  def faction_b?
  state?(ESTRIOLE::FACTION_B_STATE) #state that mark faction B
  end
 
end
 
class Game_Troop < Game_Unit
  attr_reader   :enemies
  attr_accessor :royale_flag
  
  def battle_members
    @enemies.select {|member| member.exist? }
  end
 
  def alive_faction_a_members
    members.select {|member| member.alive? and member.faction_a? }
  end
 
  def dead_faction_a_members
    members.select {|member| member.dead? and member.faction_a? }
  end
 
  def alive_faction_b_members
    members.select {|member| member.alive? and member.faction_b? }
  end
 
  def dead_faction_b_members
    members.select {|member| member.dead? and member.faction_b? }
  end
 
  def alive_bribed_members
    members.select {|member| member.alive? and member.bribed? }
  end
 
  def dead_bribed_members
    members.select {|member| member.dead? and member.bribed? }
  end
 
  def setup_bribed_opponents
    @enemies = []
    for i in 0..$game_troop.enemies.size-1
#~     @enemies.push($game_troop.enemies[i]) if $game_troop.enemies[i]!=ex_enemy
    @enemies.push($game_troop.enemies[i]) if !$game_troop.enemies[i].state?(ESTRIOLE::BRIBE_STATE)
    end #all troop except bribed
  end
 
  def setup_bribed_friends
    @enemies = []
    for i in 0..$game_party.actors.size-1
    @enemies.push($game_actors[$game_party.actors[i]])
    end #all actors
    for i in 0..$game_troop.enemies.size-1
#~     @enemies.push($game_troop.enemies[i]) if $game_troop.enemies[i]==inc_enemy
    @enemies.push($game_troop.enemies[i]) if $game_troop.enemies[i].state?(ESTRIOLE::BRIBE_STATE)
    end #all bribed troop
  end
 
  def setup_faction_opponents(faction_state)
    @enemies = []
    for i in 0..$game_party.actors.size-1
    @enemies.push($game_actors[$game_party.actors[i]])
    end #all actors
    for i in 0..$game_troop.enemies.size-1
      if !$game_troop.enemies[i].state?(faction_state) || $game_troop.enemies[i].state?(ESTRIOLE::BRIBE_STATE)
        @enemies.push($game_troop.enemies[i])
      end
    end #all troop that not faction member
  end
 
  def setup_faction_friends(faction_state)
    @enemies = []
    for i in 0..$game_troop.enemies.size-1
      if $game_troop.enemies[i].state?(faction_state) && !$game_troop.enemies[i].state?(ESTRIOLE::BRIBE_STATE)
        @enemies.push($game_troop.enemies[i])
      end
    end #all troop that faction member
  end
 
  alias alive_members_battle_royale alive_members
  def alive_members
    return @enemies if @royale_flag
    bribed_members = members.select {|member| member.alive? && member.state?(ESTRIOLE::BRIBE_STATE) }
    final_alive_members = alive_members_battle_royale - bribed_members
    return final_alive_members
  end
  #changed to alias to make it compatible if anyone modify game troop alive members
  
end
 
class Game_Party < Game_Unit
  attr_reader   :actors
end