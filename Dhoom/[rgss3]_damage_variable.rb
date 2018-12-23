#State notetag: <damage_var: variable id>
module Dhoom
  module REGEXP
    module State
      DAMAGE_VAR = /<(?:damage_var|DAMAGE_VAR):[ ]*(\d+)>/i
    end
  end
end

class RPG::State < RPG::BaseItem
 
  attr_reader :damage_var
 
  def load_notetags_damage_var
    self.note.split(/[\r\n]+/).each { |line|    
      case line
      when Dhoom::REGEXP::State::DAMAGE_VAR
        @damage_var = $1.to_i       
      end
    }
  end  
end
 
module DataManager
 
  class <<self; alias load_database_ddamage_var load_database; end
  def self.load_database
    load_database_ddamage_var
    load_notetags_damage_var
  end
 
 
  def self.load_notetags_damage_var
    for obj in $data_states
      next if obj.nil?
      obj.load_notetags_damage_var
    end
  end
end

class << BattleManager
  alias dhoom_damagevar_batman_setup setup
  def setup(troop_id, can_escape = true, can_lose = false)
    dhoom_damagevar_batman_setup(troop_id, can_escape, can_lose)
    reset_damage_variables
  end
  
  def reset_damage_variables
    $data_states.each do |state|
      $game_variables[state.damage_var] = 0 if state && state.damage_var
    end
  end
end

class Game_ActionResult
  alias dhoom_damagevar_gmbat_make_damage make_damage
  def make_damage(value, item)
    dhoom_damagevar_gmbat_make_damage(value, item)
    @battler.states.each do |state|
      $game_variables[state.damage_var] += value if state.damage_var
    end
  end
end