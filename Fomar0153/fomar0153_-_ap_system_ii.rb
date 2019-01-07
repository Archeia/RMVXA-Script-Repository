=begin
AP System Script II
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Implements an ap system for you to use when creating skill
systems that utilise AP.
----------------------
Instructions
----------------------
Notetag <ap x> e.g. <ap 4> <ap 100>
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
    if enemy.note =~ /<ap (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
end