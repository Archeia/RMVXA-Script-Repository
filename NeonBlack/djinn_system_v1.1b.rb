##-----------------------------------------------------------------------------
## Djinn System v1.1b
## Created by Neon Black
##
## Only for non-commercial use.  See full terms of use and contact info at:
## http://cphouseset.wordpress.com/liscense-and-terms-of-use/
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.1b - 8.19.2013
##  Fixed a small issue with djinn equip types
## v1.1a - 6.16.2013
##  Fixed an issue related to equip item parameters
## v1.1 - 1.20.2013
##  Addressed some lag issues
##  Added SE for a djinn ending cooldown on the map
## v1.0a - 1.14.2013
##  Minor changes related to CPBE
## v1.0 - 1.8.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported = {} if $imported.nil?                                              ##
$imported["CP_DJINN"] = 1.1                                                   ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This scipt allows you to make either weapons or armour that act as djinn
## similar to the djinn system from Golden Sun.  These djinn can be added or
## removed from the party just like any other item using the event commands and
## pretty much act like any normal piece of equipment while equipped.
##
## This script has 2 script call commands that can be used to give the party
## new "summons" similar to the summons that use djinn from Golden Sun as well
## as a few tags used by both skills and equips to set summons and djinn.
##
##    Tags:
## <fire djinn 80>
##  - Used to tag weapons or armour and cause them to become djinn.  The number
##    is the skill that is used when the djinn is "released" in battle.  The
##    word "fire" is the djinn's element.  Elements are defined in the config
##    section.  Check there for more info on elements.
##
## <summon> -and- </summon>
##  - Used to tag a skill and cause it to become a summon.  Summon skills will
##    appear in the summon skill menu as long as the party is able to use the
##    skill.  Between these two tags you would place the djinn element and a
##    number to tell the script what elements are required to use the skill.
##    Example of a skill that requires 2 fire djinn and 1 water djinn:
##
##       <summon>
##       2 fire
##       1 water
##       </summon>
##
##    Script Calls:
## add_djinn_summon(4)
##  - Adds summon skill with an id of "4" to the list of summons.  If the skill
##    is not tagged with the tags above, it will not appear in the list.
##
## remove_djinn_summon(4)
##  - Removes the summon skill with the id of "4".  Any number can be used on
##    both of these script calls.
##
##    Command Tags:
## If you are using CP's Battle Engine version 1.2 or higher, you will need to
## add command tags to allow the djinn and djinn summon commands to work.
## These tags may be added to ABILITIES hash in the script, or in the command
## block in actor/class notetags.  The commands are as follows:
##
##   <commands>
##   :djinn
##   :djinn_summon
##   </commands>
##
## :djinn
##  - Adds the djinn command to the actor's command window.
## :djinn_summon
##  - Adds the djinn summon command to the actor's command window.
##
##----------------------------------------------------------------------------##
                                                                              ##
module CP    # Do not touch                                                   ##
module DJINN #  these lines.                                                  ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------

# If this is set to true, djinn are taken from the list of weapons.  If this is
# set to false, djinn are taken from the list of armours.
DJINN_WEAPONS = false

# The elements and the associated icon IDs.  Element names are used by every
# aspect of the game.  These are NOT case sensative and as such, both "FIRE"
# and "fire" would mean the same thing.  Icon IDs are used by the floating
# djinn box in battle and nowhere else.  Make sure each element is set up
# properly to avoid errors.
ELEMENTS ={

# "Name"  => ID,
  "Fire"  => 187,
  "Ice"   => 188,
  "Earth" => 189,
  "Light" => 190,
  
}

# These are the names of the Djinn and Summon commands in battle and the Djinn
# option in the main menu.
DJINN_COMM = "Djinn"
SUMMON_COMM = "Summon"
MENU_NAME = "Djinn"

# This string is the text that appears on the floating djinn box above where
# the icons of the free djinn are displayed.
DJINN_BOX = "Free Djinn"

# These are the battle log strings that appear when certain actions are
# performed in battle.  You can use the tags <djinn> and <actor> in them to
# display the name of the djinn or person related to the djinn.
RELEASE_DJINN = '<actor> releases <djinn>!'
EQUIP_DJINN = '<djinn> was set back to <actor>.'
SUMMON_FAIL = 'But there were not enough Djinn....'

# These are the texts to display when the help box is displayed in CPBE v1.2 or
# higher.  Remember that you can use \n for a new line.
DJINN_HELP = "Release a djinn to activate it's special effect."
SUMMON_HELP = "Use standby djinn to summon a powerful entity."

# This is the animation played when a djinn on cooldown is re-equipped to a
# player in battle.  If a viewed battle system is used, this /should/ display
# the animation itself, otherwise, just the sounds are played.
EQUIP_ANIM = 107

# This is the SE that plays when a djinn is re-equipped while walking around on
# the map.  The second value is the volume and the third value is the pitch.
EQUIP_SE = ["Saint9", 80, 100]

# The number of turns a djinn remains on standby after being used for a summon.
# Base turns is the number of turns the first djinn of each element takes to
# come off of cooldown.  Added turn is added to the base turns for each
# additional djinn of an element to be used.  For example, if several fire
# djinn are used for a summon, the first one would be on cooldown for 2 turns,
# the second for 3, the third for 4, etc.  Finally, step turns is the number of
# steps required outside of battle to reduce the cooldown by 1 turn.
BASE_TURNS = 2
ADDED_TURN = 1
STEP_TURNS = 20

# The height of character sprites.  This is used by the djinn scene in the main
# menu.  If you are using sprites taller than the default sprites, this value
# will need to be increased.
CHARA_HEIGHT = 32

# The base summons the party has at the start of the game.  Place each ID in
# followed by a comma.
BASE_SUMMONS = [128, 129, 130, 131, 132, 133, 134, 135]

##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


## Used to get the base arrays for skills and djinn items.
def self.summons
  temp = $data_skills.select {|s| next unless s; s.summon?}
  return temp.select {|s| $game_system.d_summon_ids.include?(s.id)}
end

def self.djinn_base
  return DJINN_WEAPONS ? $data_weapons : $data_armors
end

SUMMONRS = /<summon>/i
SUMMONRE = /<\/summon>/i
SUMMONTC = /(\d+) (.+)/i
DJINNID  = /<(.+) djinn (\d+)>/i

end
end

## Creates djinn type items and summons.
class RPG::Skill < RPG::UsableItem
  def summon?
    get_summon_djinn if @summon.nil?
    return @summon
  end
  
  def djinn_cost
    get_summon_djinn if @djinn.nil?
    return @djinn
  end
  
  def get_summon_djinn
    @summon = false; @djinn = {}
    stag = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::DJINN::SUMMONRS
        @summon = true
        stag = true
      when CP::DJINN::SUMMONTC
        next unless stag
        @djinn[$2.to_s.downcase] = $1.to_i
      when CP::DJINN::SUMMONRE
        break
      end
    end
  end
end

class RPG::BaseItem
  def djinn?
    return false unless self.is_a?(CP::DJINN::DJINN_WEAPONS ? RPG::Weapon : RPG::Armor)
    get_djinn_state if @djinn_id.nil?
    return @djinn_id > 0 || @djinn_type != "CP"
  end
  
  def djinn_id
    get_djinn_state if @djinn_id.nil?
    return @djinn_id
  end
  
  def djinn_type
    get_djinn_state if @djinn_type.nil?
    return @djinn_type
  end
  
  def get_djinn_state
    @djinn_type = "CP"; @djinn_id = 0
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when CP::DJINN::DJINNID
        @djinn_type = $1.to_s.downcase
        @djinn_id = $2.to_i
      end
    end
  end
end

## Allows retrieval of the djinn summon array.
class Game_System
  def d_summon_ids
    @d_summons = CP::DJINN::BASE_SUMMONS if @d_summons.nil?
    return @d_summons
  end
  
  def add_d_summon(id)
    d_summon_ids
    @d_summons.push(id) unless @d_summons.include?(id)
  end
  
  def rem_d_summon(id)
    d_summon_ids
    @d_summons -= [id]
  end
end

## Allows the array to be added to and removed from.
class Game_Interpreter
  def add_djinn_summon(id)
    $game_system.add_d_summon(id)
  end
  
  def remove_djinn_summon(id)
    $game_system.rem_d_summon(id)
  end
end

class Game_Party
  ## Counts djinn cooldown steps, but not "perfectly".
  alias cp_djinn_p_walk on_player_walk
  def on_player_walk
    cp_djinn_p_walk
    @djinn_walk = 0 if @djinn_walk.nil?
    @djinn_walk += 1
    if @djinn_walk >= CP::DJINN::STEP_TURNS
      val = update_djinn_masks(true)
      @djinn_walk -= CP::DJINN::STEP_TURNS
      RPG::SE.new(*CP::DJINN::EQUIP_SE).play unless val.empty?
    end
  end
  
  ## Gets the IDs of all djinn in the party.
  def djinn
    get_all_djinn if @all_djinn.nil?
    return @all_djinn
  end
  
  def get_all_djinn
    list = all_items.select {|item| item.djinn?}
    @all_djinn = list.collect {|item| item.id}
  end
  
  ## Organized djinn across all characters.
  def organize_djinn
    get_all_djinn
    update_djinn_masks
    list = floating_djinn
    temp = list.select {|i| djinn.include?(i)}
    members.each do |mem|
      if mem.djinn.size > max_djinn
        (mem.djinn.size - max_djinn).times do
          temp.push(mem.pop_djinn)
        end
      elsif mem.djinn.size < max_djinn - 1
        (max_djinn - (mem.djinn.size + 1)).times do
          break if temp.empty?
          mem.add_djinn(temp.pop)
        end
      end
    end
    temp.each do |dj|
      members.each do |mem|
        next if mem.djinn.size == max_djinn
        mem.add_djinn(dj)
        break
      end
      return if temp.empty?
    end
  end
  
  ## Swaps djinn between two characters.
  def swap_djinn(index1, index2)
    actor1 = members[index1 % members.size]
    dj1    = index1 / members.size
    actor2 = members[index2 % members.size]
    dj2    = index2 / members.size
    actor1.djinn[dj1], actor2.djinn[dj2] = actor2.djinn[dj2], actor1.djinn[dj1]
    actor1.update_djinn
    actor2.update_djinn
  end
  
  ## Gets the max djinn a single character can hold.
  def max_djinn
    i = djinn.size / members.size
    i += 1 if djinn.size % members.size != 0
    return i
  end
  
  ## Checks for djinn not equipped to current party members.
  def floating_djinn
    list = []
    members.each do |mem|
      next if mem.djinn.empty?
      list += mem.djinn
    end
    return djinn - list
  end
  
  ## Checks for djinn currently not equipped.
  def free_djinn(element)
    i = 0
    djinn_masks.each do |dj, ary|
      next unless CP::DJINN.djinn_base[dj].djinn_type == element.downcase
      i += 1 if ary[0] == :removed
    end
    return i
  end
  
  ## Checks for free djinn and subtracts for pending summons.
  def free_djinn_minus_used(element)
    i = free_djinn(element)
    battle_members.each do |mem|
      mem.actions.each do |act|
        next if act.nil? || !act.dsummon?
        next unless act.item.djinn_cost[element.downcase]
        return i if BattleManager.actor.input == act
        i -= act.item.djinn_cost[element.downcase]
      end
    end
    return i
  end
  
  ## Checks if djinn cost can be paid and returns true.  Else, returns false.
  def pay_djinn_cost(actor, skill)
    payment = {}
    cost = skill.djinn_cost.clone
    cost.keys.each {|k| payment[k] = []}
    actor.djinn.each do |djinn|
      next unless djinn_masks[djinn][0] == :removed
      dj = CP::DJINN.djinn_base[djinn]
      next unless cost.include?(dj.djinn_type) && cost[dj.djinn_type] > 0
      payment[dj.djinn_type].push(djinn)
      cost[dj.djinn_type] -= 1
    end
    all_members.each do |mem|
      next if mem == actor
      mem.djinn.each do |djinn|
        next unless djinn_masks[djinn][0] == :removed
        dj = CP::DJINN.djinn_base[djinn]
        next unless cost.include?(dj.djinn_type) && cost[dj.djinn_type] > 0
        payment[dj.djinn_type].push(djinn)
        cost[dj.djinn_type] -= 1
      end
    end
    if cost.values.any? {|n| n > 0}
      return false
    else
      payment.values.each do |ary|
        val = CP::DJINN::BASE_TURNS + 1
        ary.each do |id|
          djinn_masks[id][0] = :standby
          djinn_masks[id][1] = val
          val += CP::DJINN::ADDED_TURN
        end
      end
      return true
    end
  end
  
  ## Standard gain item command modded to sort djinn after use.
  alias cp_djinn_gain gain_item
  def gain_item(item, amount, include_equip = false)
    return unless item
    cp_djinn_gain(item, amount, include_equip)
    if CP::DJINN.djinn_base.include?(item) && item.djinn?
      organize_djinn
      update_djinn_masks
    end
  end
  
  ## Allows only one of each djinn to be gained.
  alias cp_djinn_max_num max_item_number
  def max_item_number(item)
    return 1 if item.djinn?
    return cp_djinn_max_num(item)
  end
  
  ## Add or remove members and organize djinn.
  alias cp_djinn_add_actor add_actor
  def add_actor(id)
    cp_djinn_add_actor(id)
    organize_djinn
  end
  
  alias cp_djinn_rem_actor remove_actor
  def remove_actor(id)
    $game_actors[id].empty_djinn
    cp_djinn_rem_actor(id)
    organize_djinn
  end
  
  ## Super method for ensuring proper djinn management.
  def update_djinn_masks(standby = false)
    @djinn_masks = {} if @djinn_masks.nil?
    @djinn_masks = @djinn_masks.select {|k, i| djinn.include?(k)}
    return unless @djinn_masks.size != djinn.size || standby
    temp = []
    djinn.each do |id|
      next if standby && @djinn_masks[id] && @djinn_masks[id][0] != :standby
      ele = CP::DJINN.djinn_base[id].djinn_type
      @djinn_masks[id] = [:removed, 0, ele] if @djinn_masks[id].nil?
      next unless standby && @djinn_masks[id][0] == :standby
      @djinn_masks[id][1] -= 1 if @djinn_masks[id][1] > 0
      next unless @djinn_masks[id][1] <= 0
      @djinn_masks[id][0] = :equipped
      temp.push(id)
    end
    return temp
  end
  
  ## Returns the djinn mask array for use.
  def djinn_masks
    update_djinn_masks if @djinn_masks.nil?
    return @djinn_masks
  end
end

class Game_Actor < Game_Battler
  attr_accessor :djinn
  
  ## Several methods for djinn checking and management.
  def djinn
    update_djinn
    return @djinn
  end
  
  def add_djinn(dj)
    update_djinn
    @djinn.push(dj)
  end
  
  def pop_djinn
    update_djinn
    return @djinn.pop
  end
  
  def has_djinn?(id)
    return djinn.include?(id)
  end
  
  def update_djinn
    @djinn = [] if @djinn.nil?
    @djinn = @djinn.select {|i| $game_party.djinn.include?(i)}
  end
  
  def empty_djinn
    @djinn = []
  end
  
  ## Simplifies djinn and summon commands to prevent cost usage.
  def use_djinn(item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  
  ## Adds djinn to equipped items.
  alias cp_djinn_fo feature_objects
  def feature_objects
    cp_djinn_fo + djinn_objects.compact
  end
  
  alias cp_param_plus param_plus
  def param_plus(param_id)
    djinn_objects.compact.inject(cp_param_plus(param_id)) {|r, item| r += item.params[param_id]}
  end
  
  ## Gets all the equipped djinn.
  def djinn_objects
    result = []
    djinn.each do |id|
      next unless id
      object = CP::DJINN.djinn_base[id]
      next unless object
      next unless $game_party.djinn_masks[id][0] == :equipped
      result.push(object)
    end
    return forced_djinn(result)
  end
  
  ## Prepares and checks if a djinn is forcibly added for test checking.
  def force_djinn(id_add = nil, id_rem = nil)
    @fr_djinn = [] if @fr_djinn.nil?
    @fa_djinn = [] if @fa_djinn.nil?
    @fr_djinn.push(CP::DJINN.djinn_base[id_rem]) if id_rem && id_rem > 0
    @fa_djinn.push(CP::DJINN.djinn_base[id_add]) if id_add && id_add > 0
  end
  
  def forced_djinn(result)
    result -= @fr_djinn if @fr_djinn
    result += @fa_djinn if @fa_djinn
    return result
  end
end

class Scene_Battle < Scene_Base
  ## Aliased window methods to allow djinn window creation.
  alias cp_djinn_windows create_all_windows
  def create_all_windows
    cp_djinn_windows
    create_freefloating_window
    create_djinn_window
    create_dsummon_window
  end
  
  alias cp_djinn_actor_cmd create_actor_command_window
  def create_actor_command_window
    cp_djinn_actor_cmd
    @actor_command_window.set_handler(:djinn,        method(:command_djinn))
    @actor_command_window.set_handler(:djinn_summon, method(:command_dsummon))
  end
  
  def create_djinn_window
    @djinn_window = Window_BattleDjinn.new(@help_window, @info_viewport, @freefloating_window)
    @djinn_window.set_handler(:ok,     method(:on_djinn_ok))
    @djinn_window.set_handler(:cancel, method(:on_djinn_cancel))
    return unless $imported["CP_BATTLEVIEW_2"] && CP::BATTLERS.style5
    @djinn_window.y = 0
    @djinn_window.viewport = @skill_viewport
  end
  
  def create_dsummon_window
    @dsummon_window = Window_BattleDSummon.new(@help_window, @info_viewport, @freefloating_window)
    @dsummon_window.set_handler(:ok,     method(:on_dsummon_ok))
    @dsummon_window.set_handler(:cancel, method(:on_dsummon_cancel))
    return unless $imported["CP_BATTLEVIEW_2"] && CP::BATTLERS.style5
    @dsummon_window.y = 0
    @dsummon_window.viewport = @skill_viewport
  end
  
  def create_freefloating_window
    @freefloating_window = Window_Freefloating.new(@info_viewport)
    @freefloating_window.hide
  end
  
  ## The commands for when djinn and summons are used.
  def command_djinn
    @djinn_window.actor = BattleManager.actor
    @djinn_window.refresh
    @djinn_window.show.activate
    @freefloating_window.show
  end
  
  def command_dsummon
    @dsummon_window.actor = BattleManager.actor
    @dsummon_window.refresh
    @dsummon_window.show.activate
    @freefloating_window.show
  end
  
  def on_djinn_ok
    @freefloating_window.hide
    @skill = $data_skills[@djinn_window.item.djinn_id]
    BattleManager.actor.input.set_djinn(@skill.id, @djinn_window.item.id)
    if !@skill.need_selection? ||
       $game_party.djinn_masks[@djinn_window.item.id][0] == :removed
      @djinn_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  
  def on_djinn_cancel
    @djinn_window.hide
    @freefloating_window.hide
    @actor_command_window.activate
  end
  
  def on_dsummon_ok
    @freefloating_window.hide
    @skill = @dsummon_window.item
    BattleManager.actor.input.set_dsummon(@skill.id)
    if !@skill.need_selection?
      @dsummon_window.hide
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  
  def on_dsummon_cancel
    @dsummon_window.hide
    @freefloating_window.hide
    @actor_command_window.activate
  end
  
  alias cp_djinn_on_e_cancel on_enemy_cancel
  def on_enemy_cancel
    cp_djinn_on_e_cancel
    on_cancel_a_window
  end
  
  alias cp_djinn_on_a_cancel on_actor_cancel
  def on_actor_cancel
    cp_djinn_on_a_cancel
    on_cancel_a_window
  end
  
  def on_cancel_a_window
    case @actor_command_window.current_symbol
    when :djinn
      @djinn_window.activate
      @freefloating_window.show
    when :djinn_summon
#~       BattleManager.actor.input.set_attack
      @dsummon_window.activate
      @freefloating_window.show
    end
  end
  
  alias cp_djinn_on_e_ok on_enemy_ok
  def on_enemy_ok
    @djinn_window.hide
    @dsummon_window.hide
    cp_djinn_on_e_ok
  end
  
  alias cp_djinn_on_a_ok on_actor_ok
  def on_actor_ok
    @djinn_window.hide
    @dsummon_window.hide
    cp_djinn_on_a_ok
  end
  
  ## Super method that modifies actions when djinn or summons are used.
  alias cp_djinn_old_item use_item
  def use_item
    item = @subject.current_action.item
    if @subject.current_action.djinn?
      djinn = @subject.current_action.djinn
      if $game_party.djinn_masks[djinn.id][0] == :equipped
        $game_party.djinn_masks[djinn.id][0] = :removed
        @log_window.display_release_djinn(@subject, djinn)
        @log_window.display_use_item(djinn, item)
        @subject.use_djinn(item)
        refresh_status
        targets = @subject.current_action.make_targets.compact
        show_animation(targets, item.animation_id)
        targets.each {|target| item.repeats.times { invoke_item(target, item) } }
      else
        do_set_djinn(@subject, djinn)
      end
    elsif @subject.current_action.dsummon?
      if $game_party.pay_djinn_cost(@subject, item)
        @log_window.display_use_item(@subject, item)
        @subject.use_djinn(item)
        refresh_status
        targets = @subject.current_action.make_targets.compact
        show_animation(targets, item.animation_id)
        targets.each {|target| item.repeats.times { invoke_item(target, item) } }
      else
        @log_window.display_use_item(@subject, item)
        @log_window.display_dsummon_fail(@subject, item)
        abs_wait_short
      end
    else
      cp_djinn_old_item
    end
  end
  
  ## Sets a djinn to a character, both in and out of the party.
  def do_set_djinn(subject, djinn)
    $game_party.djinn_masks[djinn.id][0] = :equipped
    if $game_party.battle_members.include?(subject)
      subject.animation_id = CP::DJINN::EQUIP_ANIM
      @log_window.display_equip_djinn(subject, djinn)
      wait_for_animation
    else
      @log_window.display_equip_djinn(subject, djinn)
      abs_wait_short
    end
  end
  
  alias cp_djinn_turn_end turn_end
  def turn_end
    returned = $game_party.update_djinn_masks(true)
    unless returned.empty?
      $game_party.all_members.each do |mem|
        returned.each do |id|
          next unless mem.has_djinn?(id)
          do_set_djinn(mem, CP::DJINN.djinn_base[id])
        end
      end
    end
    cp_djinn_turn_end
  end
end

## The freefloating djinn window, used to determine available djinn.
class Window_Freefloating < Window_Base
  def initialize(info_viewport)
    @info_viewport = info_viewport
    super(0, y_pos, window_width, fitting_height(4))
    @offset = 0
  end
  
  def y_pos
    if $imported["CP_BATTLEVIEW_2"] && CP::BATTLERS.style5
      @info_viewport.rect.y - fitting_height(4)
    else
      @info_viewport.rect.y
    end
  end
  
  def window_width
    return 52 * col_max + standard_padding * 2
  end
  
  def col_max
    i = (CP::DJINN::ELEMENTS.size / 2)
    return CP::DJINN::ELEMENTS.size % 2 > 0 ? i + 1 : i
  end
  
  def refresh
    contents.clear
    draw_text(2, 0, contents.width - 4, line_height, CP::DJINN::DJINN_BOX, 1)
    i = 0
    CP::DJINN::ELEMENTS.each do |name, icon|
      rect = Rect.new(52 * (i % col_max), line_height * (2 + i / col_max), 52, line_height)
      text = $game_party.free_djinn_minus_used(name)
      wide = contents.text_size(text).width + 26
      rect.x += (52 - wide) / 2
      draw_icon(icon, rect.x, rect.y)
      rect.x += 24
      draw_text(rect, text)
      i += 1
    end
  end
  
  def shift?
    return false if $imported["CP_BATTLEVIEW_2"] && CP::BATTLERS.style5
    return true
  end
  
  def show
    refresh
    if shift?
      @offset = width
      @info_viewport.ox += @offset
      @info_viewport.rect.x = width
    end
    super
  end
  
  def hide
    if shift?
      @info_viewport.ox -= @offset
      @info_viewport.rect.x = 0
      @offset = 0
    end
    super
  end
end

class Game_Action
  ## Added special methods to allow djinn and summons to be detected.
  def set_djinn(item_id, djinn_id)
    set_skill(item_id)
    @djinn_id = djinn_id
    self
  end
  
  def set_dsummon(item_id)
    set_skill(item_id)
    @dsummon = true
    self
  end
  
  alias cp_djinn_skill set_skill
  def set_skill(item_id)
    cp_djinn_skill(item_id)
    @dsummon = false
    @djinn_id = 0
  end
  
  alias cp_djinn_item set_item
  def set_item(item_id)
    cp_djinn_item(item_id)
    @dsummon = false
    @djinn_id = 0
  end
  
  def djinn?
    return djinn ? djinn.id > 0 : false
  end
  
  def djinn
    @djinn_id = 0 if @djinn_id.nil?
    return CP::DJINN.djinn_base[@djinn_id]
  end
  
  def dsummon?
    return @dsummon ? true : false
  end
end

## Adds the new commands to the actor window.
class Window_ActorCommand < Window_Command
  alias cp_standard_cmd_list make_command_list
  def make_command_list
    return unless @actor
    cp_standard_cmd_list
    unless $imported["CP_BATTLEVIEW_2"] && $imported["CP_BATTLEVIEW_2"] >= 1.2
      add_djinn_command
      add_djinn_summon_command
    end
  end
  
  alias cp_djinn_addon_command addon_command if method_defined?(:addon_command)
  def addon_command(comm)
    if comm == :djinn
      add_djinn_command
    elsif comm == :djinn_summon
      add_djinn_summon_command
    else
      cp_djinn_addon_command(comm)
    end
  end
  
  def add_djinn_command
    add_command(CP::DJINN::DJINN_COMM, :djinn, !@actor.djinn.empty?)
  end
  
  def add_djinn_summon_command
    add_command(CP::DJINN::SUMMON_COMM, :djinn_summon, !CP::DJINN.summons.empty?)
  end
  
  alias cp_djinn_addon_help_update addon_help_update if method_defined?(:addon_help_update)
  def addon_help_update(sym)
    cp_djinn_addon_help_update(sym)
    case sym
    when :djinn
      @help_window.set_text(CP::DJINN::DJINN_HELP)
    when :djinn_summon
      @help_window.set_text(CP::DJINN::SUMMON_HELP)
    end
  end
end

## The window to display usable djinn in battle.
class Window_BattleDjinn < Window_BattleSkill
  def initialize(hw, iv, fw)
    super(hw, iv)
    @freefloating_window = fw
  end
  
  def make_item_list
    @data = []
    if @actor
      @actor.djinn.each do |dj|
        temp = CP::DJINN.djinn_base[dj]
        @data.push(temp)
      end
    end
  end
  
  def enable?(item)
    @actor && $game_party.djinn_masks[item.id][0] != :standby
  end
  
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      case $game_party.djinn_masks[skill.id][0]
      when :removed
        change_color(power_down_color)
      when :standby
        change_color(crisis_color)
        cdtime = $game_party.djinn_masks[skill.id][1]
      else
        change_color(normal_color)
      end
      draw_icon(skill.icon_index, rect.x, rect.y)
      rect.x += 24
      rect.width -= 24
      draw_text(rect, skill.name)
      draw_skill_cooldown(rect, cdtime)
    end
  end
  
  def draw_skill_cooldown(rect, cdtime)
    change_color(normal_color, false)
    draw_text(rect, cdtime, 2)
  end
end

## The djinn summon window for use in battle.
class Window_BattleDSummon < Window_BattleSkill
  def initialize(hw, iv, fw)
    super(hw, iv)
    @freefloating_window = fw
  end
  
  def make_item_list
    @data = CP::DJINN.summons
  end
  
  def enable?(item)
    return true
  end
  
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      change_color(normal_color)
      draw_item_name(skill, rect.x, rect.y)
      draw_skill_cost(rect, skill)
    end
  end
  
  def draw_skill_cost(rect, skill)
    temp = []
    CP::DJINN::ELEMENTS.each do |name, icon|
      i = skill.djinn_cost[name.downcase]
      next unless i || i == 0
      color = $game_party.free_djinn_minus_used(name) >= i ? normal_color :
                                                             power_down_color
      temp.push([i, color, name, icon])
    end
    temp.reverse_each do |r|
      change_color(r[1])
      draw_text(rect, r[0], 2)
      rect.width -= (contents.text_size(r[0]).width + 24)
      draw_icon(r[3], rect.x + rect.width, rect.y)
    end
  end
end

## Log window texts for use in battle.
class Window_BattleLog < Window_Selectable
  def display_release_djinn(subject, djinn)
    text = CP::DJINN::RELEASE_DJINN.gsub(/<actor>/i, subject.name)
    text.gsub!(/<djinn>/i, djinn.name)
    add_text(text)
    wait
  end
  
  def display_equip_djinn(subject, djinn)
    text = CP::DJINN::EQUIP_DJINN.gsub(/<actor>/i, subject.name)
    text.gsub!(/<djinn>/i, djinn.name)
    replace_text(text)
  end
  
  def display_dsummon_fail(subject, djinn)
    text = CP::DJINN::SUMMON_FAIL.gsub(/<actor>/i, subject.name)
    text.gsub!(/<djinn>/i, djinn.name)
    wait
    add_text(text)
  end
end

## Modify the main menu window to include the Djinn command.
class Window_MenuCommand < Window_Command
  alias cp_djinn_add_commands add_original_commands
  def add_original_commands
    cp_djinn_add_commands
    add_command(CP::DJINN::MENU_NAME, :djinn, djinn_command_usable?)
  end
  
  def djinn_command_usable?
    return !$game_party.djinn.empty? && main_commands_enabled
  end
end

class Scene_Menu < Scene_MenuBase
  alias cp_djinn_c_cmd_wind create_command_window
  def create_command_window
    cp_djinn_c_cmd_wind
    @command_window.set_handler(:djinn, method(:command_djinn_menu))
  end
  
  def command_djinn_menu
    SceneManager.call(Scene_Djinn)
  end
end

## The Djinn scene.
## Did this and then my laptop broke for a week, so not 100% sure I can do the
## comments on it at the moment. (I'm lazy, sue me.)
class Scene_Djinn < Scene_MenuBase
  def start
    super
    create_status_windows
    create_help_window
    create_main_list
  end
  
  def create_status_windows
    @status1_window = Window_DjinnStatus.new(0)
    @status2_window = Window_DjinnStatus.new(Graphics.width / 2)
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.y = Graphics.height - @help_window.height
  end
  
  def create_main_list
    @list_window = Window_DjinnPartyList.new(@help_window, @status1_window,
                                             @status2_window)
    @list_window.select(0)
    @list_window.activate
    @list_window.set_handler(:cancel, method(:unselect_djinn))
    @list_window.set_handler(:ok,     method(:select_djinn))
  end
  
  def select_djinn
    if @list_window.pending_index == @list_window.index
      set_djinn
      @list_window.redraw_item(@list_window.index)
      @list_window.pending_index = -1
    elsif @list_window.pending_index >= 0
      $game_party.swap_djinn(@list_window.index, @list_window.pending_index)
      @list_window.refresh
      @list_window.pending_index = -1
    else
      @list_window.pending_index = @list_window.index
    end
    @list_window.activate
    @list_window.call_update_help
  end
  
  def unselect_djinn
    if @list_window.pending_index >= 0
      @list_window.pending_index = -1
      @list_window.activate
    else
      return_scene
    end
  end
  
  def set_djinn
    i = @list_window.index
    actor = $game_party.members[i % $game_party.members.size]
    djinn = actor.djinn[i / $game_party.members.size]
    status = $game_party.djinn_masks[djinn][0]
    case status
    when :equipped
      $game_party.djinn_masks[djinn][0] = :removed
    when :removed
      $game_party.djinn_masks[djinn][0] = :equipped
    end
  end
end

class Window_DjinnPartyList < Window_Selectable
  attr_accessor :pending_index
  
  def initialize(help_window, status1, status2)
    @help_window = help_window
    @status1 = status1
    @status2 = status2
    @pending_index = -1
    height = Graphics.height - (@status1.height + @help_window.height)
    super(0, @status1.height, Graphics.width, height)
    refresh
  end
  
  def item_max
    return [$game_party.djinn.size, row_max * col_max].max
  end
  
  def col_max
    return $game_party.members.size
  end
  
  def row_max
    return $game_party.max_djinn
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / 4 - spacing
  end
  
  def item_height
    line_height
  end
  
  def contents_width
    [super - super % col_max, (item_width + spacing) * col_max - spacing].max
  end
  
  def ch
    return CP::DJINN::CHARA_HEIGHT + 2
  end
  
  def contents_height
    [super, row_max * item_height + ch].max
  end
  
  def spacing
    return 10
  end
  
  def item_rect(index)
    rect = super(index)
    rect.y += ch
    rect
  end
  
  def refresh
    super
    col_max.times {|i| draw_djinn_graphic(i)}
  end
  
  def draw_djinn_graphic(index)
    rect = item_rect(index)
    actor = $game_party.members[index]
    fx = rect.x + rect.width / 2
    draw_actor_graphic(actor, fx, ch - 1)
  end
  
  def draw_item(index)
    draw_item_background(index)
    rect = item_rect(index)
    actor = $game_party.members[index % col_max]
    id = actor.djinn[index / col_max]
    return unless id
    djinn = CP::DJINN.djinn_base[id]
    draw_djinn_item(actor, djinn, rect)
  end
  
  def draw_djinn_item(actor, djinn, rect)
    case $game_party.djinn_masks[djinn.id][0]
    when :removed
      change_color(power_down_color)
    when :standby
      change_color(crisis_color)
    else
      change_color(normal_color)
    end
    draw_icon(djinn.icon_index, rect.x, rect.y)
    draw_text(rect.x + 24, rect.y, rect.width - 26, line_height, djinn.name)
  end
  
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  
  def page_row_max
    (height - padding - padding_bottom - ch) / item_height
  end
  
  def top_col
    self.ox / (item_width + spacing)
  end
  
  def bottom_col
    top_col + 3
  end
  
  def ensure_cursor_visible
    super
    while index % col_max > bottom_col
      self.ox += item_width + spacing
    end
    while index % col_max < top_col
      self.ox -= item_width + spacing
    end
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
  
  def call_update_help
    update_help if active
  end
  
  def update_help
    aid = @index % col_max
    actor = $game_party.members[aid]
    djinn = actor.djinn[@index / col_max]
    
    if @pending_index >= 0
      if actor != @status1.actor
        djin2 = @status1.actor.djinn[@pending_index / col_max]
        dlmask = d2mask = nil
        d1mask = $game_party.djinn_masks[djinn][0] unless djinn.nil?
        d2mask = $game_party.djinn_masks[djin2][0] unless djin2.nil?
        djinn = nil if d1mask != :equipped
        djin2 = nil if d2mask != :equipped
        @status1.make_actor_change(nil, djinn, djin2)
        @status2.make_actor_change(actor, djin2, djinn)
      elsif @index == @pending_index
        if djinn.nil?
          @status1.temp_actor = nil
        else
          case $game_party.djinn_masks[djinn][0]
          when :standby
            @status1.temp_actor = nil
          when :removed
            @status1.make_actor_change(nil, djinn)
          when :equipped
            @status1.make_actor_change(nil, nil, djinn)
          end
          @status2.actor = nil
          @status2.temp_actor = nil
        end
      else
        @status1.temp_actor = nil
        @status2.actor = nil
      end
    else
      @status1.actor = actor
      @status1.temp_actor = nil
      @status2.actor = nil
    end
    @status1.refresh
    @status2.refresh
    @actor = actor
    
    if @help_window
      super
      id = actor.djinn[@index / col_max]
      @help_window.set_item(CP::DJINN.djinn_base[id]) if id
    end
  end
end

class Window_DjinnStatus < Window_Base
  attr_accessor :actor
  attr_accessor :temp_actor
  
  def initialize(x)
    super(x, 0, Graphics.width / 2, fitting_height(5))
    @actor = nil
    @temp_actor = nil
  end
  
  def refresh
    contents.clear
    return unless @actor
    actor_basic_info
    actor_class_info
    actor_hp_info
    actor_param_info
  end
  
  def actor_basic_info
    draw_actor_name(@actor, 2, 0, contents.width / 2)
    draw_actor_face(@actor, 0, line_height)
  end
  
  def actor_class_info
    wd = contents.width / 2
    if @temp_actor.nil? || @actor.class == @temp_actor.class
      change_color(normal_color)
    else
      change_color(power_up_color)
    end
    actor = @temp_actor ? @temp_actor : @actor
    draw_actor_class(actor, wd + 2, 0, wd)
  end
  
  def actor_hp_info
    wd = (contents.width - 98) / 2
    change_color(system_color)
    actor = @temp_actor ? @temp_actor : @actor
    draw_text(96,      line_height, wd, line_height, Vocab::hp_a)
    draw_text(96 + wd, line_height, wd, line_height, Vocab::mp_a)
    if @temp_actor.nil? || @actor.mhp == @temp_actor.mhp
      change_color(normal_color)
    elsif @actor.mhp > @temp_actor.mhp
      change_color(power_down_color)
    elsif @actor.mhp < @temp_actor.mhp
      change_color(power_up_color)
    end
    draw_text(96,      line_height, wd, line_height, actor.mhp, 2)
    if @temp_actor.nil? || @actor.mmp == @temp_actor.mmp
      change_color(normal_color)
    elsif @actor.mmp > @temp_actor.mmp
      change_color(power_down_color)
    elsif @actor.mmp < @temp_actor.mmp
      change_color(power_up_color)
    end
    draw_text(96 + wd, line_height, wd, line_height, actor.mmp, 2)
  end
  
  def actor_param_info
    wd = (contents.width - 98) / 2
    actor = @temp_actor ? @temp_actor : @actor
    6.times do |i|
      i += 2
      n = i % 2; lh = (line_height * 1) + (i / 2) * line_height
      change_color(system_color)
      draw_text(96 + wd * n, lh, wd, line_height, Vocab::param(i))
      param_color(i)
      draw_text(96 + wd * n, lh, wd, line_height, actor.param(i), 2)
    end
  end
  
  def param_color(param_id)
    if @temp_actor.nil? || @actor.param(param_id) == @temp_actor.param(param_id)
      change_color(normal_color)
    elsif @actor.param(param_id) > @temp_actor.param(param_id)
      change_color(power_down_color)
    elsif @actor.param(param_id) < @temp_actor.param(param_id)
      change_color(power_up_color)
    end
  end
  
  def actor=(actor)
    return if actor == @actor
    @actor = actor
    @temp_actor = nil if @actor.nil?
  end
  
  def temp_actor=(actor)
    return if actor == @temp_actor
    @temp_actor = actor
  end
  
  def make_actor_change(actor = nil, id_a = nil, id_r = nil)
    @actor = actor unless actor.nil?
    return if @actor.nil?
    @temp_actor = Marshal.load(Marshal.dump(@actor))
    force_djinn(id_a, id_r)
  end
  
  def force_djinn(id_a = nil, id_r = nil)
    @temp_actor.force_djinn(id_a, id_r)
  end
end

##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------