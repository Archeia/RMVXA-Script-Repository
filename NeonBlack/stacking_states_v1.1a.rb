##-----------------------------------------------------------------------------
## Stacking States v1.1a
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.1a - 8.27.2013
##  Unique state fix
## v1.1 - 8.17.2013
##  Fixed a bug where states would wear off too soon
## v1.0 - 3.15.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["Stack_States"] = 1.1                                               ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows tagged states to be stacked multiple times on a single
## battler.  Each stacked state acts as a separate state, which makes the
## effects multiplicative rather than additive increasing the effectiveness of
## the state with each use (when using params and sp-params only).  To use this
## script, tag any states with the following tags:
##
## max stack[5]  -or-  max stacks[5]
##  - Allows the state to stack up to 5 times.  The number can be replaced with
##    any max value you would like.
##
## stack icon[2, 100]  -or-  stack icons[2 100]
##  - Changes the icon ID of a state to 100 when it is stacked exactly 2 times.
##    One of these can be made for each level of the stack and it can use any
##    number for the ID.
##
##
## Whenever a skill or something else adds a state to an actor, the state is
## added once.  To have a skill add more than 1 instance of the state to the
## stack, simply have more than one instance of the "Add State" effect on the
## skill.  This nature also applies to removing states.  When the state is
## removed, only one instance of it is removed from the stack, rather than
## clearing the whole stack.
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


class Game_BattlerBase
  def erase_state(state_id)
    @states -= [state_id]      ## Line added to remove only one instance.
    return if state?(state_id) ## Line added to prevent a stack from bugging.
    @state_turns.delete(state_id)
    @state_steps.delete(state_id)
  end
  
  def max_state_stack?(state_id) ## Determines if the state is at max stacks.
    state_stack(state_id) >= $data_states[state_id].max_stacks
  end
  
  def state_stack(state_id) ## Gets the number of times the state is stacked.
    (@states.count(state_id) || 0)
  end
  
  def state_icons ## "uniq" method added and "icon_index" changed.
    icons = states.uniq.collect {|state| state.icon_index(state_stack(state.id)) }
    icons.delete(0)
    icons
  end
end

class Game_Battler < Game_BattlerBase
  def add_state(state_id)
    if state_addable?(state_id)  ## Line below changed to allow stacking states.
      add_new_state(state_id) unless max_state_stack?(state_id)
      reset_state_counts(state_id)
      @result.added_states.push(state_id).uniq!
    end
  end
  
  def update_state_turns
    states.uniq.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0
    end
  end
end

class RPG::State < RPG::BaseItem
  def max_stacks  ## Modified state class to add stack capabilities.
    create_stack_regs
    @max_stacks || 1
  end
  
  alias :cp_stack_states :icon_index
  def icon_index(stacks = 1)  ## Added an argument to get icons from stacks.
    create_stack_regs
    @stack_icons[stacks] || cp_stack_states
  end
  
  def create_stack_regs
    return if @finished_up_stack_icons; @finished_up_stack_icons = true
    @stack_icons = {}
    note.split(/[\r\n]+/).each do |line|
      case line
      when /max stacks?\[(\d+)\]/i
        @max_stacks = $1.to_i
      when /stack icons?\[(\d+),? (\d+)\]/i
        @stack_icons[$1.to_i] = $2.to_i
      end
    end
  end
end


##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------