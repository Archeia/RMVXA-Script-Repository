#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Kread's AI Packages
# Author: Kread-EX
# Version 1.2
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
#-------------------------------------------------------------------------------------------------
 
# This line detects the used engine.
 
Exe = 'Game'
 
if (FileTest.exist?(Exe + '.rvproj') || FileTest.exist?(Exe + '.rgss2a'))
  Engine = :VX
else
  Engine = :XP
end
 
#===========================================================
# ** KreadCFG
#------------------------------------------------------------------------------
# Configuration module. If you're using VX, you don't need this.
#===========================================================
 
if Engine == :XP
 
module KreadCFG
 
  # Put in here the IDs of enemies using the HEALY Package.
  AIHealy = [34]
 
  # Put in here the IDs of enemies using the PROTECT Package.
  AIProtect = [36]
 
  # Put in here the IDs of enemies using the SUPPORT Package.
  AISupport = [37]
 
  # Put in here the IDs of enemies using the WILD Package.
  AIWild = [38]
 
  # Put in here the IDs of enemies using the BALANCED Package.
  AIBalanced = [39]
 
end
 
end
 
#===========================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  Add a few VX properties to XP skills.
#===========================================================
 
if Engine == :XP
 
class RPG::Skill
  #--------------------------------------------------------------------------
  # * Determine the base damage
  #--------------------------------------------------------------------------
  def base_damage
    return @power
  end
  #--------------------------------------------------------------------------
  # * Determine if a skill targets an enemy
  #--------------------------------------------------------------------------
  def for_opponent?
    return [1, 2].include?(self.scope)
  end
  #--------------------------------------------------------------------------
  # * Determine if a skill targets an ally
  #--------------------------------------------------------------------------
  def for_friend?
    return [3, 4, 5, 6].include?(self.scope)
  end
  #--------------------------------------------------------------------------
  # * Determine if a skill targets a dead ally
  #--------------------------------------------------------------------------
  def for_dead_friend?
    return [5, 6].include?(self.scope)
  end
  #--------------------------------------------------------------------------
  # * Determine if a skill targets all
  #--------------------------------------------------------------------------
  def for_all?
    return [2, 4, 6].include?(self.scope)
  end
  #--------------------------------------------------------------------------
end
 
end
 
if Engine == :VX
#===========================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class deals with party members. Refer to "$game_party" for the
#  instance of this class.
#===========================================================
 
class Game_Party
  #--------------------------------------------------------------------------
  # * Return the actors array (VX only)
  #--------------------------------------------------------------------------
  def actors
    return members
  end
end
 
end
 
#===========================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class deals with troops. Refer to "$game_troop" for the instance of
#  this class.
#===========================================================
 
class Game_Troop
  #--------------------------------------------------------------------------
  # * Return a dead member
  #--------------------------------------------------------------------------
  def return_fallen
    @enemies.each {|enn| return enn if enn.dead?}
    return nil
  end
  if Engine == :VX
    #--------------------------------------------------------------------------
    # * Return the enemies array (VX only)
    #--------------------------------------------------------------------------
    def enemies
      return @enemies
    end
  end
  #--------------------------------------------------------------------------
  # * Return the weakest ally (HP-wise)
  #--------------------------------------------------------------------------
  def return_weakest
    value = 9999999999
    returnar = nil
    @enemies.each {|enn|
      if enn.hp < value
        value = enn.hp
        returnar = enn
      end
    }
    return returnar
  end
  #--------------------------------------------------------------------------
  # * Return a ally with ailments
  #--------------------------------------------------------------------------
  def return_sicko
    @enemies.each {|enn| return enn if enn.states.size > 0}
    return nil
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass for the Game_Actor
#  and Game_Enemy classes.
#===========================================================
 
class Game_Battler
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_reader    :last_hp
  attr_reader    :last_sp
  attr_reader    :last_states
  if Engine == :VX
    #--------------------------------------------------------------------------
    # * Return the states IDs (VX)
    #--------------------------------------------------------------------------
    def states_ids
      return @states
    end
  end
  #--------------------------------------------------------------------------
  # * Store current state
  #--------------------------------------------------------------------------
  def store_state
    @last_hp, @last_sp, @last_states = @hp, @sp, @states.dup
    if Engine == :VX
      @last_state_turns = @state_turns.dup
    else
      @last_states_turn = @states_turn.dup
    end
  end
  #--------------------------------------------------------------------------
  # * Restore memorized state
  #--------------------------------------------------------------------------
  def restore_state
    @hp, @sp, @states = @last_hp, @last_sp, @last_states.dup
    if Engine == :VX
      @state_turns = @last_state_turns.dup
    else
      @states_turn = @last_states_turn.dup
    end
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It's used within the Game_Troop class
#  ($game_troop).
#===========================================================
 
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_reader    :package_action
  attr_reader    :package_target
  attr_accessor :package
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     troop_id     : troop ID
  #     member_index : troop member index
  #--------------------------------------------------------------------------
  alias_method :krx_ai_pack_game_enemy_initialize, :initialize
  def initialize(troop_id, member_index)
    krx_ai_pack_game_enemy_initialize(troop_id, member_index)
    make_enemy_package
  end
  #--------------------------------------------------------------------------
  # * Determine the package of the enemy
  #--------------------------------------------------------------------------
  def make_enemy_package
    @package = nil
    if Engine == :XP
      if KreadCFG::AIHealy.include?(self.id)
        @package = :healy
      elsif KreadCFG::AIProtect.include?(self.id)
        @package = :protect
      elsif KreadCFG::AISupport.include?(self.id)
        @package = :support
      elsif KreadCFG::AIWild.include?(self.id)
        @package = :wild
      elsif KreadCFG::AIBalanced.include?(self.id)
        @package = :balanced
      end
    else
      self.enemy.note.split(/[\r\n]+/).each {|line|
        @package = $1.downcase.intern if line =~ /<(?:PACKAGE|package):[ ](.*)>/i
      }
    end
  end
  #--------------------------------------------------------------------------
  # * Make Action
  #--------------------------------------------------------------------------
  unless method_defined?(:krx_ai_pack_make_action)
    alias_method :krx_ai_pack_make_action, :make_action
  end
  def make_action
    if @package.nil?
      krx_ai_pack_make_action
      return
    end
    make_xp_package_action if Engine == :XP
    make_vx_package_action if Engine == :VX
  end
  #--------------------------------------------------------------------------
  # * Make Package action (XP)
  #--------------------------------------------------------------------------
  if Engine == :XP
    def make_xp_package_action
      self.current_action.clear
      return unless self.movable?
      # Extract current effective actions
      @available_actions = []
      rating_max = 0
      self.actions.each {|action|
        # Confirm turn conditions
        n = $game_temp.battle_turn
        a = action.condition_turn_a
        b = action.condition_turn_b
        next if (b == 0 && n != a) || (b > 0 && (n < 1 || n < a || n % b != a % b))
        # Confirm HP conditions
        next if self.hp * 100.0 / self.maxhp > action.condition_hp
        # Confirm level conditions
        next if $game_party.max_level < action.condition_level
        # Confirm switch conditions
        switch_id = action.condition_switch_id
        next if switch_id > 0 && !$game_switches[switch_id]
        # Add this action to applicable conditions
        @available_actions.push(action)
      }
      package_result = self.method('process_' + @package.to_s + '_package').call
      package_action, package_target = package_result[0], package_result[1]
      # No action found
      if package_action.nil?
        krx_ai_pack_make_action
        return
      end
      # Sets the action
      self.current_action.kind = package_action.kind
      self.current_action.basic = package_action.basic
      self.current_action.skill_id = package_action.skill_id
      self.current_action.target_index = package_target.index
    end
  else
    #--------------------------------------------------------------------------
    # * Make Package action (VX)
    #--------------------------------------------------------------------------
    def make_vx_package_action
      @action.clear
      return unless movable?
      @available_actions = []
      enemy.actions.each {|action|
        next unless conditions_met?(action)
        if action.kind == 1
          next unless skill_can_use?($data_skills[action.skill_id])
        end
        @available_actions.push(action)
      }
      package_result = self.method('process_' + @package.to_s + '_package').call
      package_action, package_target = package_result[0], package_result[1]
      if package_action.nil?
        krx_ai_pack_make_action
        return
      end
      # Sets the action
      @action.kind = package_action.kind
      @action.basic = package_action.basic
      @action.skill_id = package_action.skill_id
      @action.target_index = package_target.index
    end
  end
  #--------------------------------------------------------------------------
  # * Process the HEALY Package
  #--------------------------------------------------------------------------
  def process_healy_package
    # 1st priority: revive fallen allies.
    if $game_troop.return_fallen != nil
      @available_actions.each {|action|
        if action.skill_id != 0 && $data_skills[action.skill_id].for_dead_friend?
          return [action, $game_troop.return_fallen]
        end
      }
    end
    # 2nd priority: heal the negative statuses.
    if $game_troop.return_sicko != nil
      @available_actions.each {|action|
        if action.skill_id != 0 && action.kind == 1
          skill = $data_skills[action.skill_id]
          enn = $game_troop.return_sicko
          if skill.for_friend? && !skill.for_dead_friend?
            if ((Engine == :XP && (skill.minus_state_set & enn.states).size > 0) ||
            (Engine == :VX && (skill.minus_state_set & enn.states_id).size > 0))
              return [action, $game_troop.return_sicko]
            end
          end
        end
      }
    end
    # 3rd priority: heal the weakest ally (if damaged).
    if $game_troop.return_weakest.hp <= $game_troop.return_weakest.maxhp
      @available_actions.each {|action|
        if action.skill_id != 0 && action.kind == 1
          if $data_skills[action.skill_id].for_friend? && !$data_skills[action.skill_id].for_dead_friend?
            if $data_skills[action.skill_id].base_damage < 0
              return [action, $game_troop.return_weakest]
            end
          end
        end
      }
    end
    # No action found, resume default AI.
    return [nil, nil]
  end
  #--------------------------------------------------------------------------
  # * Process the PROTECT Package
  #--------------------------------------------------------------------------
  def process_protect_package
    target = nil
    unsorted_actions = []
    while unsorted_actions.size < @available_actions.size
      ind = rand(@available_actions.size)
      unless unsorted_actions.include?(@available_actions[ind])
        unsorted_actions.push(@available_actions[ind])
      end
    end
    # 1st priority: buff allies.
    unsorted_actions.each {|action|
      if action.skill_id != 0 && action.kind == 1
        skill = $data_skills[action.skill_id]
        if skill.for_friend? && skill.plus_state_set.size > 0
          target = determine_target(skill)
          next if target.nil?
          return [action, target]
        end
      end
    }
    # 2nd priority: heal the weakest ally under 75% HP.
    if $game_troop.return_weakest.hp <= ($game_troop.return_weakest.maxhp * 0.75).round
      unsorted_actions.each {|action|
        if action.skill_id != 0 && action.kind == 1
          if $data_skills[action.skill_id].for_friend? && !$data_skills[action.skill_id].for_dead_friend?
            if $data_skills[action.skill_id].base_damage < 0
              return [action, $game_troop.return_weakest]
            end
          end
        end
      }
    end
    # 3rd priority: debuff enemies.
    unsorted_actions.each {|action|
      if action.skill_id != 0 && action.kind == 1
        skill = $data_skills[action.skill_id]
        if skill.for_opponent? && skill.plus_state_set.size > 0
          target = determine_target(skill)
          next if target.nil?
          return [action, target]
        end
      end
    }
    # No action found, resume default AI.
    return [nil, nil]
  end
  #--------------------------------------------------------------------------
  # * Process the SUPPORT Package
  #--------------------------------------------------------------------------
  def process_support_package
    # This package doesn't give any priority. The character will just spam support skills
    # with 0 power. If none of the skills can work, the default AI will resume.
    # I recommand to give a rating of 1 to support skills with this package, and a high rating to
    # attack skills, so the default AI won't try to use ineffective skills.
    unsorted_actions = []
    while unsorted_actions.size < @available_actions.size
      ind = rand(@available_actions.size)
      unless unsorted_actions.include?(@available_actions[ind])
        unsorted_actions.push(@available_actions[ind])
      end
    end
    unsorted_actions.each {|action|
      if action.skill_id != 0 && action.kind == 1
        skill = $data_skills[action.skill_id]
        if skill.base_damage == 0
          target = determine_target(skill)
          next if target.nil?
          return [action, target]
        end
      end
    }
    # No action found, resume default AI.
    return [nil, nil]
  end
  #--------------------------------------------------------------------------
  # * Process the WILD Package
  #--------------------------------------------------------------------------
  def process_wild_package
    # Then again, this package doesn't give priority. The characters will just calculate the average
    # damage caused by all their attacks and always select the most damaging.
    unsorted_actions = []
    while unsorted_actions.size < @available_actions.size
      ind = rand(@available_actions.size)
      unless unsorted_actions.include?(@available_actions[ind])
        unsorted_actions.push(@available_actions[ind])
      end
    end
    damages = []
    unsorted_actions.each {|action|
      next if action.kind != 1
      if action.skill_id != 0 && action.kind == 1
        skill = $data_skills[action.skill_id]
        if skill.base_damage > 0
          damages.push(determine_target_damage(skill))
        end
      end
    }
    # No action found, resume default AI.
    return [nil, nil] if damages.size == 0
    # Now, just checked what caused the most average damage.
    max = 0
    ind = nil
    for i in 0...damages.size
      if damages[i].is_a?(Array)
        for j in 0...damages[i].size
          if damages[i][j] > max
            max = damages[i][j]
            ind = [i, j]
          end
        end
      elsif damages[i] > max
        max = damages[i]
        ind = i
      end
    end
    if ind.is_a?(Array)
      return [unsorted_actions[ind[0]], $game_party.actors[ind[1]]]
    else
      return [unsorted_actions[ind], $game_party.actors[0]]
    end
  end
  #--------------------------------------------------------------------------
  # * Process the BALANCED Package
  #--------------------------------------------------------------------------
  def process_balanced_package
    # No priorities again, and no orientation either. Basically, this package choose a random skill
    # but only if it works and against a acceptable target.
    # Best used in conjunction with Battle Events.
    unsorted_actions = []
    while unsorted_actions.size < @available_actions.size
      ind = rand(@available_actions.size)
      unless unsorted_actions.include?(@available_actions[ind])
        unsorted_actions.push(@available_actions[ind])
      end
    end
    unsorted_actions.each {|action|
      if action.skill_id != 0 && action.kind == 1
        skill = $data_skills[action.skill_id]
        target = determine_target(skill)
        next if target.nil?
        return [action, target]
      elsif action.kind == 0
        return [action, $game_party.random_target_actor]
      end
    }
    # No action found, resume default AI.
    return [nil, nil]
  end
  #--------------------------------------------------------------------------
  # * Returns a target on who the skill will work
  #--------------------------------------------------------------------------
  def determine_target(skill)
    if skill.for_friend?
      $game_troop.enemies.each {|enn|
        enn.store_state
        enn.skill_effect(self, skill)
        if enn.hp != enn.last_hp ||
        ((Engine == :XP) && enn.states != enn.last_states) ||
        ((Engine == :VX) && enn.states_ids != enn.last_states)
          enn.restore_state
          return enn
        end
        enn.restore_state
      }
    elsif skill.for_opponent?
      $game_party.actors.each {|act|
        act.store_state
        act.skill_effect(self, skill)
        if act.hp != act.last_hp ||
        ((Engine == :XP) && act.states != act.last_states) ||
        ((Engine == :VX) && act.states_ids != act.last_states)
          act.restore_state
          return act
        end
        act.restore_state
      }
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # * Returns a target on who the skill will do max damage
  #--------------------------------------------------------------------------
  def determine_target_damage(skill)
    if skill.for_all?
      damage = 0
      $game_party.actors.each {|act|
        act.store_state
        act.skill_effect(self, skill)
        if (Engine == :XP && act.damage.is_a?(String)) ||
        (Engine == :VX && act.hp_damage.is_?(String))
          damage += 0
        else
          damage += Engine == :XP ? act.damage : act.hp_damage
        end
        act.restore_state
      }
      return damage
    else
      damages = []
      $game_party.actors.each {|act|
        act.store_state
        act.skill_effect(self, skill)
        damage = Engine == :XP ? act.damage : act.hp_damage
        act.restore_state
        damages.push(damage.is_a?(String) ? 0 : damage)
      }
      return damages
    end
  end
  #--------------------------------------------------------------------------
end