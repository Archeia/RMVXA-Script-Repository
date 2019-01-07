=begin
Aeon Party
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
This script allows you to summon actors in the style of FFX's aeons.
----------------------
Instructions
----------------------
See the thread or blog post for a change.

Also if using an actor battler script add:
SceneManager.scene.create_spriteset
below:
a = $game_actors[x]
$game_party.aeons.push(a)
in your common event.
----------------------
Change Log
----------------------
1.0 -> 1.1 Added a fix for some popup systems which showed death when
           summoning aeons. Reason with the fix below.
           Added support for actor battler scripts.
----------------------
Known bugs
----------------------
None
=end

$imported = {} if $imported.nil?
$imported["Fomar0153-Aeon Party"] = true

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
    SceneManager.scene.create_spriteset # added for actor sprites
    aeon_process_victory
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * When a character is first created they have 0 HP and hence get death 
  #   applied, if this happens in a battle and you are using popups
  #   you get a popup that death has been applied. This is the fix for that.
  #--------------------------------------------------------------------------
  alias no_death_on_initialize initialize
  def initialize
    no_death_on_initialize
    @hp = 1
  end
end