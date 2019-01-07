=begin
EST - SUIKODEN BRIBE RUN
request by Deenos from RMID
simulate bribe run suikoden style
100% success running by paying enemy gold

enemy have their own price to pay by setting notetags
<bribe_cost 1000>
will set the cost to 1000
if not given notetags it will use default in module ESTRIOLE

Cannot bribe if escape is disabled (boss battle etc)
  
=end

$imported = {} if $imported.nil?
$imported["EST - SUIKODEN BRIBE RUN"] = true

module ESTRIOLE
  BRIBE_RUN_COMMAND_VOCAB = "Bribe"
  BRIBE_RUN_START_ESCAPE_VOCAB = "%s's party bribe enemies by paying %d %s!"
  BRIBE_RUN_DEFAULT_COST = 100
end

class Window_PartyCommand < Window_Command
  alias bribe_run_make_command_list make_command_list
  def make_command_list
    bribe_run_make_command_list
    bribe_vocab = ESTRIOLE::BRIBE_RUN_COMMAND_VOCAB
    add_command(bribe_vocab, :bribe, BattleManager.can_bribe?)
  end
end

class Scene_Battle < Scene_Base

  alias bribe_run_create_party_command_window create_party_command_window
  def create_party_command_window
    bribe_run_create_party_command_window
    @party_command_window.set_handler(:bribe, method(:command_bribe))
    @party_command_window.unselect    
  end

  def command_bribe
    turn_start unless BattleManager.process_bribe
  end
  
end


module BattleManager
  def self.process_bribe
    bribe_text = ESTRIOLE::BRIBE_RUN_START_ESCAPE_VOCAB
    bribe_cost = $game_troop.bribe_cost
    $game_message.add(sprintf(bribe_text, $game_party.name,bribe_cost,Vocab.currency_unit))
    success = true
    Sound.play_escape
    process_abort
    wait_for_message
    return success
  end
  def self.can_bribe?
    @can_escape and $game_party.gold >= $game_troop.bribe_cost
  end
end

class RPG::Enemy
  def bribe_cost
    if @bribe_cost.nil?
      if @note =~ /<bribe_cost (.*)>/i
        @bribe_cost = $1.to_i
      else
        @bribe_cost = ESTRIOLE::BRIBE_RUN_DEFAULT_COST.to_i
      end
    end
    @bribe_cost.to_i
  end    
end

class Game_Enemy < Game_Battler
  def bribe_cost
    enemy.bribe_cost.to_i
  end  
end

class Game_Troop < Game_Unit
  def bribe_cost
    bribe_cost = 0
    for member in alive_members
    bribe_cost += member.bribe_cost
    end
    return bribe_cost
  end    
end