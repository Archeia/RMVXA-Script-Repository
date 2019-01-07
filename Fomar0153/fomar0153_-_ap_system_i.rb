=begin
AP System Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Implements an ap system for you to use when creating skill
ystems that utilise AP.
----------------------
Instructions
----------------------
You will need to create an attribute to use for AP.
Then set is as a trait, although it says % just put
the number you want the enemy to give as AP.
----------------------
Known bugs
----------------------
None
=end
module Vocab
  ObtainAp         = "%s AP was obtained!"
end

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● New Method gain_ap
  #--------------------------------------------------------------------------
  def gain_ap(ap)
    # your code goes here
  end
end

module BattleManager

  # Set you AP Element
  AP_Element = 11

  #--------------------------------------------------------------------------
  # ● Rewrote self.display_exp
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab::ObtainExp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
    if $game_troop.ap_total > 0
      text = sprintf(Vocab::ObtainAp, $game_troop.ap_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # ● Rewrote self.gain_exp
  #--------------------------------------------------------------------------
  def self.gain_exp
    $game_party.all_members.each do |actor|
        actor.gain_exp($game_troop.exp_total)
    end
    wait_for_message
    $game_party.all_members.each do |actor|
    actor.gain_ap($game_troop.ap_total)
    end
    wait_for_message
  end
end

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● New Method ap_total
  #--------------------------------------------------------------------------
  def ap_total
    dead_members.inject(0) {|r, enemy| r += enemy.ap }
  end
end

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● New Method ap_total
  #--------------------------------------------------------------------------
  def ap
    return (self.element_rate(BattleManager::AP_Element) * 100).to_i
  end
end