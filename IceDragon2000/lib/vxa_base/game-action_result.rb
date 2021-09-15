#encoding:UTF-8
# Game_ActionResult
#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of battle actions. It is used internally for
# the Game_Battler class. 
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :used                     # used flag
  attr_accessor :missed                   # missed flag
  attr_accessor :evaded                   # evaded flag
  attr_accessor :critical                 # critical flag
  attr_accessor :success                  # success flag
  attr_accessor :hp_damage                # HP damage
  attr_accessor :mp_damage                # MP damage
  attr_accessor :tp_damage                # TP damage
  attr_accessor :hp_drain                 # HP drain
  attr_accessor :mp_drain                 # MP drain
  attr_accessor :added_states             # added states
  attr_accessor :removed_states           # removed states
  attr_accessor :added_buffs              # added buffs
  attr_accessor :added_debuffs            # added debuffs
  attr_accessor :removed_buffs            # removed buffs/debuffs
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    clear_hit_flags
    clear_damage_values
    clear_status_effects
  end
  #--------------------------------------------------------------------------
  # * Clear Hit Flags
  #--------------------------------------------------------------------------
  def clear_hit_flags
    @used = false
    @missed = false
    @evaded = false
    @critical = false
    @success = false
  end
  #--------------------------------------------------------------------------
  # * Clear Damage Values
  #--------------------------------------------------------------------------
  def clear_damage_values
    @hp_damage = 0
    @mp_damage = 0
    @tp_damage = 0
    @hp_drain = 0
    @mp_drain = 0
  end
  #--------------------------------------------------------------------------
  # * Create Damage
  #--------------------------------------------------------------------------
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  #--------------------------------------------------------------------------
  # * Clear Status Effects
  #--------------------------------------------------------------------------
  def clear_status_effects
    @added_states = []
    @removed_states = []
    @added_buffs = []
    @added_debuffs = []
    @removed_buffs = []
  end
  #--------------------------------------------------------------------------
  # * Get Added States as an Object Array
  #--------------------------------------------------------------------------
  def added_state_objects
    @added_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # * Get Removed States as an Object Array
  #--------------------------------------------------------------------------
  def removed_state_objects
    @removed_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # * Determine Whether Some Sort of Status (Parameter or State) Was Affected
  #--------------------------------------------------------------------------
  def status_affected?
    !(@added_states.empty? && @removed_states.empty? &&
      @added_buffs.empty? && @added_debuffs.empty? && @removed_buffs.empty?)
  end
  #--------------------------------------------------------------------------
  # * Determine Final Hit 
  #--------------------------------------------------------------------------
  def hit?
    @used && !@missed && !@evaded
  end
  #--------------------------------------------------------------------------
  # * Get Text for HP Damage
  #--------------------------------------------------------------------------
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::hp, @hp_drain)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
    else
      fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      sprintf(fmt, @battler.name)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text for MP Damage
  #--------------------------------------------------------------------------
  def mp_damage_text
    if @mp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::mp, @mp_drain)
    elsif @mp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::mp, @mp_damage)
    elsif @mp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::mp, -@mp_damage)
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text for TP Damage
  #--------------------------------------------------------------------------
  def tp_damage_text
    if @tp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::tp, @tp_damage)
    elsif @tp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorGain : Vocab::EnemyGain
      sprintf(fmt, @battler.name, Vocab::tp, -@tp_damage)
    else
      ""
    end
  end
end
