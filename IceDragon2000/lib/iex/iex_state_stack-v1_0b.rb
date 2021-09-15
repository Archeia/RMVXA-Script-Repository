#==============================================================================#
# ** IEX(Icy Engine Xelion) - State Stack
#------------------------------------------------------------------------------#
# ** Original Code : BEM (Battle Engine Melody)
# ** Credit Author : Yanfly (http://wiki.pockethouse.com/)
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (States)
# ** Script Type   : State Stacking
# ** Date Created  : 12/04/2010
# ** Date Modified : 12/05/2010
# ** Version       : 1.0b
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# First things first, I created this script, BUT the code is from BEM (With a couple edits)
# So before you go crediting me, Credit Yanfly.
# Anyway, apart from that, this script allows states to be stacked upon each
# other. This is mostly for Stat Buffs, sleep.gif I didn't mess with anything else..
# Unstacking is caused when the state is Offsetted by another state.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# 1.0
#  Notetags! Placed in State noteboxes
#------------------------------------------------------------------------------#
# <stat: +/-x>
# These will raise/lower the stat by a set amount, simply replace x.
# +/- is optional, if neither is used the number is assumed to be positive
#
# <stat: x%>
# These will change the stat by a percentage, simply replace x.
# Values above 100% increase the stat, while one below will lower the stat
#
# Valid stats are:
# maxhp, maxmp, atk, def, spi, agi
#
# <stack max: x>
# By default all states have a stack of 1
# You can change this, by placing the following into the states Notetag.
# Simply replace x with your required number
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Even though this script uses BEMs State Stacking methods (I was lazy)
# It is "NOT compatable" with BEM, it WILL crash.
# This was intended for use with the
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# 12/05/2010 - V1.0  Completed Script
# 12/05/2010 - V1.0a Added more details, and did a few fixes
# 12/06/2010 - V1.0b Fixed the Hp/Mp decimal bug
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#  
#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_State_Stack"] = true

#==============================================================================
# ** IEX::SSK
#------------------------------------------------------------------------------
#==============================================================================
class RPG::State
  
  def iex_ssk_st_cache
    @iex_ssk_st_cache_complete = false
    @stack = 1
    @stack_burn = 1
    @stat_rate ={}
    @stat_set = {}
    for st in ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi']
      @stat_rate[st]= 100
      @stat_set[st] = 0
    end  
    @stat_rate['atk'] = @atk_rate
    @stat_rate['def'] = @def_rate
    @stat_rate['spi'] = @spi_rate
    @stat_rate['agi'] = @agi_rate
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<(?:MAX_STACK|max stack|stack|stack_limit|stack limit):?[ ]*(\d+)>/i
      @stack = [$1.to_i, 1].max
    when /<(\w+):?[ ]*([\+\-]?\d+)>/i  
      @stat_set[$1.to_s.downcase] = $2.to_i
    when /<(\w+):?[ ]*([\+\-]?\d+)([%?…])>/i      
      @stat_rate[$1.to_s.downcase] = $2.to_i
    end  
      }
    @iex_ssk_st_cache_complete = true
  end
  
  def stack_max
    iex_ssk_st_cache unless @iex_ssk_st_cache_complete
    return @stack
  end
  
  ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi'].each { |meth|
  aStr = %Q(
  def #{meth}_set
    iex_ssk_st_cache unless @iex_ssk_st_cache_complete
    return @stat_set['#{meth}']
  end
  
  def #{meth}_rate
    iex_ssk_st_cache unless @iex_ssk_st_cache_complete
    return @stat_rate['#{meth}']
  end
  )
  module_eval(aStr)
  }
  
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#==============================================================================
class Game_Battler
  
  attr_accessor :state_stack
  
  alias iex_ssk_gb_initialize initialize unless $@
  def initialize
    iex_ssk_gb_initialize
    @state_stack = {}
  end

  #--------------------------------------------------------------------------
  # new method: remained_rules
  #--------------------------------------------------------------------------
  def remained_rules(state_id)
    state = $data_states[state_id]
    return if state == nil
    increase_stack(state)
    mode = 2
    case mode
    when 0 # No changes
      return
    when 1 # Reset Turns
      @state_turns[state_id] = state.hold_turn
    when 2 # Add Turns
      @state_turns[state_id] = 0 if !@state_turns.include?(state_id)
      @state_turns[state_id] += state.hold_turn
    end
  end

  #--------------------------------------------------------------------------
  # overwrite method: apply_state_changes
  #--------------------------------------------------------------------------
  def apply_state_changes(obj)
    plus = obj.plus_state_set
    minus = obj.minus_state_set
    for i in plus
      next if state_resist?(i)
      next if dead?
      next if i == 1 and @immortal
      if state?(i)
        remained_rules(i)
        @remained_states.push(i) unless @remained_states.include?(i)
        next
      end
      if rand(100) < state_probability(i)
        @added_states.push(i) unless @added_states.include?(i)
        add_state(i)
      end
    end
    for i in minus
      next unless state?(i)
      remove_state(i)
      @removed_states.push(i) unless @removed_states.include?(i)
    end
    for i in @added_states & @removed_states
      @added_states.delete(i)
      @removed_states.delete(i)
    end
  end

  #--------------------------------------------------------------------------
  # alias method: add_state
  #--------------------------------------------------------------------------
  alias add_state_bem add_state unless $@
  def add_state(state_id)
    add_state_bem(state_id)
    increase_stack(state_id)
  end
  
  #--------------------------------------------------------------------------
  # alias method: remove_state
  #--------------------------------------------------------------------------
  alias remove_state_bem remove_state unless $@
  def remove_state(state_id)
    decrease_stack(state_id)
    if @state_stack.has_key?(state_id)
      if @state_stack[state_id] <= 0
        remove_state_bem(state_id)
        clear_stack(state_id)
      end
    else
      remove_state_bem(state_id)
    end  
    #@removed_states.delete(state_id)
    @added_states.delete(state_id)
  end
  
  #--------------------------------------------------------------------------
  # new method: clear_stack
  #--------------------------------------------------------------------------
  def clear_stack(state_id)
    state_id = state_id.id if state_id.is_a?(RPG::State)
    @state_stack = {} if @state_stack == nil
    @state_stack.delete(state_id)
  end

  #--------------------------------------------------------------------------
  # * Remove Battle States (called when battle ends)
  #--------------------------------------------------------------------------
  alias iex_remove_states_battle remove_state unless $@
  def remove_states_battle
    for state in states
      clear_stack(state.id) if state.battle_only
    end  
    iex_remove_states_battle
  end
  
  ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi'].each { |meth|
  aStr = %Q(
  def #{meth}
    n = [base_#{meth} + @#{meth}_plus, 1].max
    for state in states
      stack(state).times do
        n = n * state.#{meth}_rate / 100.0
      end
    end
    for state in states
      next if state.#{meth}_set == 0
      n += state.#{meth}_set * stack(state)
    end
    if '#{meth}'.downcase == 'maxhp'
      @hp = [Integer(n), @hp].min
    elsif '#{meth}'.downcase == 'maxmp'  
      @mp = [Integer(n), @mp].min
    end  
    return Integer(n)
  end
  )
  module_eval(aStr)
  }
  #--------------------------------------------------------------------------
  # new method: increase_stack
  #--------------------------------------------------------------------------
  def increase_stack(state_id, value = 1)
    state_id = state_id.id if state_id.is_a?(RPG::State)
    state = $data_states[state_id]
    return unless state?(state.id)
    return if state_id == 1
    @state_stack = {} if @state_stack == nil
    @state_stack[state_id] = 0 if @state_stack[state_id] == nil
    original_stack = @state_stack[state_id]
    @state_stack[state_id] += value
    @state_stack[state_id] = [@state_stack[state_id], state.stack_max].min
    return if @state_stack[state_id] == original_stack
    @added_states.push(state_id) if !@added_states.include?(state_id)
  end
  
  #--------------------------------------------------------------------------
  # new method: decrease_stack
  #--------------------------------------------------------------------------
  def decrease_stack(state_id, value = 1)
    state_id = state_id.id if state_id.is_a?(RPG::State)
    increase_stack(state_id, -value)
    @state_stack = {} if @state_stack == nil
    @state_stack.delete(state_id) if @state_stack[state_id].to_i <= 0
  end

  #--------------------------------------------------------------------------
  # new method: stack
  #--------------------------------------------------------------------------
  def stack(state_id)
    state_id = state_id.id if state_id.is_a?(RPG::State)
    state = $data_states[state_id]
    return 0 unless state?(state.id)
    @state_stack = {} if @state_stack == nil
    max_stack = state.stack_max
    return [[@state_stack[state_id].to_i, 1].max, max_stack].min
  end
  
end