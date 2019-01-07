=begin
Aeon Party
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
This script allows you to summon actors in the style of FFX's aeons.
----------------------
Instructions
----------------------
See the thread or blog post for a change.
----------------------
Known bugs
----------------------
None
=end
class Game_Party < Game_Unit
  
  attr_accessor :aeons
  
  alias aeon_initialize initialize
  def initialize
    aeon_initialize
    @aeons = []
  end
  
  alias aeon_battle_members battle_members
  def battle_members
    return aeon_battle_members if @aeons == []
    return @aeons
  end
  
  alias aeon_all_dead? all_dead?
  def all_dead?
    if aeon_all_dead?
      if @aeons == []
        return true
      else
        @aeons = []
        clear_actions
        return false
      end
    end
    return false
  end
  
  def on_battle_end
    @aeons = []
    super
  end
end


module BattleManager
  
  class << self
    alias aeon_process_victory process_victory
  end
  
  def self.process_victory
    $game_party.aeons = []
    aeon_process_victory
  end
end