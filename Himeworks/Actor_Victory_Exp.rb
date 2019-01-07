=begin
#===============================================================================
 Title: Actor Victory Exp
 Author: Hime
 Date: Nov 18, 2013
 URL: http://himeworks.com/2013/11/18/actor-victory-exp/
--------------------------------------------------------------------------------
 ** Change log
 Nov 18, 2013
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
 
 This script changes the exp gained from battle to consider each actor
 separately. The default system assumes all actors gain the same amount
 of base exp from the troop, and does not provide any support for additional
 exp modifiers such as level difference.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Plug and play.
 
 In the configuration, you can choose how you want the message to be displayed.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ActorVictoryExp"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Actor_Victory_Exp

    # Message to show in the victory screen. Takes an actor's name and the
    # exp gained
    Display_Format = "%s obtained %d Exp"
    
#===============================================================================
# ** Rest of script
#===============================================================================
  end
end

module BattleManager
  
  class << self
    alias :th_actor_victory_exp_display_exp :display_exp
    alias :th_actor_victory_exp_gain_exp :gain_exp
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def self.display_exp
    $game_party.all_members.each do |actor|
      exp = actor.gained_exp
      if exp > 0
        text = sprintf(TH::Actor_Victory_Exp::Display_Format, actor.name, exp)
        $game_message.add('\.' + text)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def self.gain_exp
    $game_party.all_members.each do |actor|
      actor.gain_exp(actor.gained_exp)
    end
    wait_for_message
  end
end

class Game_Actor < Game_Battler
  
  alias :th_actor_victory_exp_initialize :initialize
  def initialize(actor_id)
    th_actor_victory_exp_initialize(actor_id)
    clear_gained_exp
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def clear_gained_exp
    @gained_exp = 0
  end
  
  alias :th_actor_victory_exp_on_battle_start :on_battle_start
  def on_battle_start
    th_actor_victory_exp_on_battle_start
    clear_gained_exp
  end
  
  alias :th_actor_victory_exp_on_battle_end :on_battle_end
  def on_battle_end
    th_actor_victory_exp_on_battle_end
    clear_gained_exp
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. exr is calculated as an exp modifier now.
  #-----------------------------------------------------------------------------
  def final_exp_rate
    battle_member? ? 1 : reserve_members_exp_rate
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def gained_exp
    if @gained_exp == 0
      @gained_exp = calculate_exp_from_enemies
    end
    return @gained_exp
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def calculate_exp_from_enemies
    total_exp = $game_troop.dead_members.inject(0) do |r, enemy|
      r += exp_from_enemy(enemy)
    end
    total_exp *= exr
    return total_exp
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def exp_from_enemy(enemy)
    enemy.exp
  end
end