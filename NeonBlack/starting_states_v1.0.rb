##-----------------------------------------------------------------------------
## Starting States v1.0
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 3.15.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["Starting_States"] = 1.0                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows you to create states that are applied to a battler at the
## start of a battle.  This can be done using anything in the database that can
## have features such as actors, enemies, weapons, or states.  To add these
## starting states, use the following tag:
##
## starting state[5]  -or-  starting states[1, 2, 5]
##  - Start the battle with the state IDs between the brackets applied.  Any
##    number of states may be applied either by using one tag or multiple tags.
##
## When using CP Stacking States, you can add this tag several times to apply
## a state to the stack several times.  When using CP State Graphics, you can
## use battler graphics and names to disguise one monster as another.  If a
## monster is disguised in this way, the letter at the end of the name is
## applied to monsters using the NEW name.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


module BattleManager  ## Added a few lines to allow actor states to apply.
  class << self
    alias :cp_starting_states_setup :setup
  end
  
  def self.setup(*args)
    $game_party.members.each do |mem|
      mem.setup_start_states
    end
    cp_starting_states_setup(*args)
  end
end

class Game_Battler < Game_BattlerBase
  def setup_start_states ## The common method used by both actors and enemies.
    features(:starting_state_list).each do |fet|
      add_state(fet.value)
    end
  end
end

class Game_Enemy < Game_Battler
  alias :cp_starting_states_init :initialize
  def initialize(*args)  ## Starts a monster off and refreshes HP/MP.
    cp_starting_states_init(*args)
    setup_start_states
    @hp = mhp
    @mp = mmp
  end
end


class RPG::BaseItem
  def features
    add_start_states
    return @features
  end
  
  def add_start_states
    return if @start_states_made; @start_states_made = true
    note.split(/[\r\n]+/).each do |line|
      case line
      when /starting states?\[([\d, ]+)\]/i
        $1.to_s.split(/,/).each do |d|
          f = RPG::BaseItem::Feature.new(:starting_state_list, 0, d.to_i)
          @features.push(f)
        end
      end
    end
  end
end


##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------