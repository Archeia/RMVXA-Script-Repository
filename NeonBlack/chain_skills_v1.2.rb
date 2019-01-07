##----------------------------------------------------------------------------##
## Chain Skills v1.2
## Created by Neon Black
##
## Only for non-commercial use.  See full terms of use and contact info at:
## http://cphouseset.wordpress.com/liscense-and-terms-of-use/
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.2 - 3.19.2013
##  Added combo skills
## v1.1 - 2.25.2013
##  Added finisher skills
##  Added customizable finisher options
##  Bugfixes and changes
## v1.0 - 1.31.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_CHAIN_SKILLS"] = 1.2                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows skill sets to be defined as a chain skills command.
## Skills in this skill subset can be selected one after another to form a
## skill chain that will then be executed all at once.
##
##------
##    Notebox Tags:
##
## chain blocks[5]
##  - This tag can be used on actors, classes, and skills.  When used on an
##    actor or class, this tag is the default number of "blocks" the actor has
##    for a skill chain (with class taking priority.  When used on a skill,
##    this tag is the number of skill blocks required to use the skill.  The
##    value (5 in this case) can be set to any number.
## chain blocks[+2]  -or-  chain blocks[-2]
##  - This tag can be used on classes, weapons, armors, and states.  When used
##    on any of these, the tag increases or decreases the number of blocks the
##    actor has to use on skills.  There are cumulative, for example, +3, +2,
##    and -1 would result in +4 blocks.
## chain follow[2]  -or-  chain follow[2, 3, 4]  -etc.-
##  - This tag can be used on skills.  If this tag is present, the skill can
##    only be used after a skill with an ID present in the tag.  For example,
##    a skill tagged with "chain follow[22]" can only be used after skill ID 22
##    while a skill tagged with "chain follow[54, 55]" can be used after skills
##    ID 54 or 55.  You can have as many skill IDs in this tag as you wish.  A
##    skill can be told it can follow itself as well as any other skill.
## chain usage[1]
##  - This tag can be used on skills.  If this tag is present, the skill can
##    only be used the number of times defined in the tag per chain.  For
##    example, if the number "2" is used, the skill can only be in the chain
##    twice.
## <chain finisher>
##  - This tag can be used on skills.  If a skill is tagged with this, the skill
##    will end a chain, even if there are other skills that could be used.
##----------------------------------------------------------------------------##
                                                                              ##
module CP    # Do not touch                                                   ##
module CHAIN #  these lines.                                                  ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# These are the default values if no tags are used in skills or actors.  CHAIN
# is the default number of blocks an actor has, COST is the default number of
# blocks required per skill, and USAGE is the default number of times a skill
# may be used in a single chain, set high by default to make it "limitless".
DEFAULT_CHAIN = 3
DEFAULT_COST  = 1
DEFAULT_USAGE = 100

# If this value is set to true, only a single target may be used for "one
# enemy", "one ally", or "one ally (dead)" scopes.  If the target is lost in
# the middle of the chain for some reason, skills with these scopes will be
# skipped.  If this value is set to false, a new target is found instead.
SINGLE_TARGET = true

# This array contains the ID of the skill subsets that will be used as chain
# skill sets.  All other skill subsets function normally.
CHAIN_COMMS = [1]

# These are the minimum and maximum number of blocks an actor may have.
MIN_BLOCKS = 1
MAX_BLOCKS = 12

# These settings are used for the chain gauge.  If the first setting is set to
# false, the rest of the settings are ignored.  IMAGE determines the file name
# of the chain image which must be placed in "Graphics/System".  Gauge block is
# the horizontal offset of each block in the image, which can be different if
# you want each block to overlap.  Finally, OFFSET_XY is the x and y offsets of
# the chain from it's default location.
USE_GAUGE = true
GAUGE_IMAGE = "ChainGauge"
GAUGE_BLOCK = 26
OFFSET_XY = [10, 0]

# These settings are for finishing a chain.  The BUTTON option is the symbol for
# the button that can be pressed in order to end a chain instantly.  TEXT is the
# name of the finish option to add to the skill list.  Either of these can be
# set to nil if you do not want to use them.  ICON and HELP are used to make the
# finish option look prettier in the menu.
FINISH_BUTTON = :A
FINISH_TEXT = "Finish"
FINISH_ICON = 0
FINISH_HELP = "Confirm selection and use skills"

## Do not touch this line##
ACTOR_COMBOS = {}##########

## This hash contains the basic combo attacks for chain skills.  When the skills
## in the first array are used in that order, they become the skills in the
## second array.  This hash is used by all actors.
COMBOS ={
  [129, 129, 129] => [135],
}

## Similar to above, these hashes contain skill combos for an individual actor.
## To add combos for another actor, copy from "ACTOR_COMBOS" down to the
## reverse bracket "}" and paste a copy of it underneath the reverse bracket.
## Then change the number in "ACTOR_COMBOS[1]" to the actor's ID.  Note that
## these take priority over the combos above.
ACTOR_COMBOS[1] ={
  [129, 129, 129] => [134],
}


##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end
end

module BattleManager  ## Easier method for getting the chain array.
  def self.chain_array
    return SceneManager.scene.chain_array || []
  end
end

class Game_Battler < Game_BattlerBase
  attr_accessor :temp_chain_action  ## Allows a temp action to be set in chains.
  
  alias :cp_c_act :current_action
  def current_action
    return @temp_chain_action || cp_c_act
  end
end

class Game_Actor < Game_Battler   ## Creates a new skill with the cost of all
  def temp_array_cost(skill)      ## skills in the chain.
    tpc, mpc, hpc, gpc, blk = 0, 0, 0, 0, 0
    ipc, spc, swc, vwc, apc, wec, aec = [], [], [], [], [], [], []
    (BattleManager.chain_array + [skill.id]).each do |id|
      skill = $data_skills[id]
      next unless skill
      tpc += skill_tp_cost(skill)  ## Does extra costs if a cost manager has
      mpc += skill_mp_cost(skill)  ## been imported.
      if $imported["YEA-SkillCostManager"] || $imported["CP_SKILLCOSTS"]
        hpc = skill_hp_cost(skill)
        gpc = skill_gold_cost(skill)
      end
      if $imported["CP_SKILLCOSTS"]
        ipc += skill.item_cost
        spc += skill.req_state + skill.state_cost
        swc += skill.req_switch
        vwc += skill.req_variable
        apc += skill.req_actor
        wec += skill.req_w
        aec += skill.req_a
      end
      blk += skill.chain_blocks
    end
    return false if blk > chain_blocks
    temp_skill = RPG::Skill.new  ## Temp skill created for the test.
    temp_skill.tp_cost = tpc
    temp_skill.mp_cost = mpc
    temp_skill.hp_cost = hpc
    temp_skill.gold_cost = gpc
    temp_skill.item_cost = ipc
    temp_skill.req_state = spc.uniq
    temp_skill.req_switch = swc.uniq
    temp_skill.req_variable = vwc.uniq
    temp_skill.req_actor = apc.uniq
    temp_skill.req_w = wec.uniq
    temp_skill.req_a = aec.uniq
    return usable?(temp_skill)
  end
  
  def usage_unused(skill)  ## Checks if the skill has been used max times.
    BattleManager.chain_array.count(skill.id) < skill.chain_usage
  end
  
  def same_targets(skill)  ## Ensures the skill uses the same kind of target.
    return true if BattleManager.chain_array.empty?
    return true if skill.for_user?
    BattleManager.chain_array.each do |id|
      next if $data_skills[id].for_user?
      return skill.for_friend? == $data_skills[id].for_friend?
    end
    return true
  end
  
  def chain_follow(item)  ## Checks if the skill properly follows another skill.
    return true if item.chain_follow.empty?
    i = BattleManager.chain_array[-1] || 0
    return item.chain_follow.include?(i)
  end
  
  def chain_blocks  ## Calculates the number of blocks an actor has.
    r = self.class.chain_blocks || actor.chain_blocks
    r += self.class.chain_modifier || 0
    r = states.inject(r) {|o, n| o += n.chain_modifier}
    r = equips.compact.inject(r) {|o, n| o += n.chain_modifier}
    return [[r, 1, CP::CHAIN::MIN_BLOCKS].max, CP::CHAIN::MAX_BLOCKS].min
  end
end

class Window_BattleSkill < Window_SkillList
  attr_writer :temp_skill  ## Temp skill for the chain.
  
  def enable?(item)  ## Longer check for each item with new params.
    return false if item.id == 0 && BattleManager.chain_array.empty?
    return false if finisher_enabled?(item.id)
    super && @actor.usage_unused(item) && @actor.same_targets(item) &&
    @actor.chain_follow(item) && @actor.temp_array_cost(item)
  end
  
  def finisher_enabled?(id)
    return false if id == 0
    return false if BattleManager.chain_array.empty?
    return false unless $data_skills[BattleManager.chain_array[-1]]
    return $data_skills[BattleManager.chain_array[-1]].chain_finisher
  end
  
  def no_selectable_skills?  ## Determines if any item is selectable.
    return !@data.any? {|skill| skill.id != 0 && enable?(skill)}
  end
  
  def item  ## Gets the item if a temp is used.
    return @temp_skill || super
  end
  
  def chain_skill_display=(window)  ## Gets the chain window.
    @chain_skill_display = window
  end
  
  def make_item_list
    super
    return unless CP::CHAIN::FINISH_TEXT &&
                  CP::CHAIN::CHAIN_COMMS.include?(@stype_id)
    finisher = RPG::Skill.new
    finisher.name = CP::CHAIN::FINISH_TEXT
    finisher.icon_index = CP::CHAIN::FINISH_ICON
    finisher.description = CP::CHAIN::FINISH_HELP
    finisher.chain_finisher = true
    finisher.chain_blocks = 0
    @data.push(finisher)
  end
  
  alias :cp_cskill_ref :refresh
  def refresh  ## Refresh the chain window.
    cp_cskill_ref
    @chain_skill_display.refresh if @chain_skill_display
  end
  
  def process_handling  ## Adds a key to end selection entirely.
    return unless open? && active
    return process_finish if finish_trigger && !BattleManager.chain_array.empty?
    super
  end
  
  def finish_trigger
    CP::CHAIN::FINISH_BUTTON && Input.trigger?(CP::CHAIN::FINISH_BUTTON)
  end
  
  def process_finish  ## Finish process.
    call_handler(:finish)
  end
  
  def update_help
    super  ## Update the gauge.
    @chain_skill_display.refresh_gauge if @chain_skill_display
  end
  
  alias :cp_cskill_show :show
  def show  ## Recalculate height.
    @norm_height = self.height
    cp_cskill_show
    return self unless @chain_skill_display &&
                       CP::CHAIN::CHAIN_COMMS.include?(@stype_id)
    @chain_skill_display.show
    return self if self.y > @chain_skill_display.y
    return self unless self.y + self.height >= @chain_skill_display.y
    self.height = @chain_skill_display.y - self.y
    refresh
    return self
  end
  
  alias :cp_cskill_hide :hide
  def hide  ## Recalculate height.
    cp_cskill_hide
    self.height = @norm_height if @norm_height
    @chain_skill_display.hide if @chain_skill_display
    return self
  end
  
  def actor  ## Gets the window actor.
    return @actor
  end
  
  def select_ending
    select(item_max - 1)
  end
end

class Window_ChainDisplay < Window_Base
  def initialize(skill_wind)  ## New window for chain display.
    super(0 - standard_padding, 0, window_width, window_height)
    @skill_window = skill_wind
    @gauge = Sprite.new
    self.opacity = 0
    hide
    set_positions
    refresh
  end
  
  def window_width
    Graphics.width + standard_padding * 2
  end
  
  def window_height
    fitting_height(2)
  end
  
  def set_positions  ## Sets the window and gauge positions.
    self.y = Graphics.height - (120 + self.height)
    oxy = CP::CHAIN::OFFSET_XY
    @gauge.y = self.y + standard_padding + line_height / 2 + oxy[1]
    @gauge.x = 0 + oxy[0]
  end
  
  def dispose  ## Dispose the gauge.
    @gauge.dispose
    super
  end
  
  def refresh_gauge  ## Creates the gauge from basic parts.
    return unless CP::CHAIN::USE_GAUGE && @skill_window.actor
    bitmap = Cache.system(CP::CHAIN::GAUGE_IMAGE)
    ofs = bitmap.width / 5
    wd = (@skill_window.actor.chain_blocks + 1) * CP::CHAIN::GAUGE_BLOCK + ofs
    @gauge.bitmap = Bitmap.new(wd, bitmap.height)
    @gauge.oy = @gauge.height / 2
    rect = Rect.new(0, 0, ofs, bitmap.height)
    xpl = 0
    @gauge.bitmap.blt(xpl, 0, bitmap, rect)
    blocks = 0
    vals = @skill_window.item ? @skill_window.item.chain_blocks : 0
    BattleManager.chain_array.each {|id| blocks += $data_skills[id].chain_blocks}
    @skill_window.actor.chain_blocks.times do |i|
      xpl += CP::CHAIN::GAUGE_BLOCK
      if i < blocks
        rect.x = ofs * 2
      elsif i < blocks + vals && @skill_window.active
        rect.x = ofs * 3
      else
        rect.x = ofs * 1
      end
      @gauge.bitmap.blt(xpl, 0, bitmap, rect)
    end
    xpl += CP::CHAIN::GAUGE_BLOCK
    rect.x = ofs * 4
    @gauge.bitmap.blt(xpl, 0, bitmap, rect)
  end
  
  def back_color  ## Color and opacity of the back.
    Color.new(0, 0, 0, back_opacity)
  end
  
  def back_opacity
    return 128
  end
  
  def refresh
    contents.clear
    refresh_gauge
    draw_back
    draw_skills
  end
  
  def draw_back  ## Draws the skill names in the chain.
    contents.fill_rect(0, line_height, contents.width, line_height, back_color)
  end
  
  def draw_skills
    rect = Rect.new(contents.width - standard_padding, line_height,
                    contents.width, line_height)
    return unless BattleManager.chain_array
    i = 0
    BattleManager.chain_array.reverse_each do |id|
      i += 1
      skill = $data_skills[id]
      rect.x -= contents.text_size(skill.name).width + 24
      draw_item_name(skill, rect.x, rect.y, true, rect.width)
      next if i == BattleManager.chain_array.size
      rect.x -= contents.text_size(" > ").width
      contents.draw_text(rect, " > ")
      break if rect.x <= 0
    end
  end
  
  def show  ## Shows and hides the gauge.
    @gauge.visible = true
    super
  end
  
  def hide
    @gauge.visible = false
    super
  end
end

class Scene_Battle  ## Holds onto the chain array.
  attr_reader :chain_array
  
  alias :cp_cskill_create_swind :create_skill_window
  def create_skill_window  ## Adds the new window and window handler.
    cp_cskill_create_swind
    @skill_window.set_handler(:finish, method(:shift_press_finish))
    @chain_display_window = Window_ChainDisplay.new(@skill_window)
    @skill_window.chain_skill_display = @chain_display_window
  end
  
  alias :cp_chain_command_skill :command_skill
  def command_skill  ## Alias the command skill to reset the chain.
    @chain_array = []
    @skill_window.temp_skill = nil
    cp_chain_command_skill
  end
  
  alias :cp_chain_skill_ok :on_skill_ok
  def on_skill_ok  ## Checks if the skill set is a chain and processes.
    @chain_array.push(@skill_window.item.id) unless @skill_window.item.id == 0
    if !CP::CHAIN::CHAIN_COMMS.include?(@actor_command_window.current_ext)
      cp_chain_skill_ok
    elsif @skill_window.no_selectable_skills? ||
          @skill_window.item.chain_finisher
      @skill_window.refresh
      @chain_shift_press = true if @skill_window.item.id == 0
      finish_skill_chain_select
    else
      @skill_window.refresh
      @skill_window.activate
    end
  end
  
  def shift_press_finish  ## The handler for if shift is pressed.
    @chain_shift_press = true
    Sound.play_ok
    finish_skill_chain_select
  end
  
  def finish_skill_chain_select  ## The end method for either chain finish.
    @skill_window.select_ending if CP::CHAIN::FINISH_TEXT
    @skill_window.deactivate
    @skill_window.temp_skill = create_skill_chain_skill
    @chain_display_window.refresh
    cp_chain_skill_ok
  end
  
  alias :cp_chain_skill_cancel :on_skill_cancel
  def on_skill_cancel  ## Determines cancel type based on chain.
    if @chain_array.empty?
      cp_chain_skill_cancel
    else
      @chain_array.pop
      @skill_window.refresh
      @skill_window.activate
    end
  end
  
  alias :cp_cskill_e_cancel :on_enemy_cancel
  def on_enemy_cancel  ## Pops the chain if a chain is being used.
    cancel_cskill_pop
    cp_cskill_e_cancel
  end
  
  alias :cp_cskill_a_cancel :on_actor_cancel
  def on_actor_cancel
    cancel_cskill_pop
    cp_cskill_a_cancel
  end
  
  def cancel_cskill_pop  ## Perform a chain pop.
    return if @chain_array.nil? || @chain_array.empty?
    @chain_array.pop unless @chain_shift_press
    @chain_shift_press = false
    @skill_window.temp_skill = nil
    @skill_window.refresh
  end
  
  def create_skill_chain_skill         ## Creates the chain skill and a temp
    @remove_chain_skills_array ||= []  ## array for later removal.
    skill = RPG::Skill.new
    skill.id = $data_skills.size
    skill.chain_skill = true
    skill.chain_array = @chain_array
    skill.scope = get_chain_scope || $data_skills[@chain_array[0]].scope
    $data_skills.push(skill)
    @remove_chain_skills_array.push(skill)
    return skill
  end
  
  def get_chain_scope  ## Determines the scope of the entire chain.
    @chain_array.each do |id|
      skill = $data_skills[id]
      return 1 if [1].include?(skill.scope)
      return 7 if [7, 9].include?(skill.scope)
    end
    return nil
  end
  
  alias :cp_chain_use_item :use_item
  def use_item  ## Changes use_item for a chain method.
    item = @subject.current_action.item
    if item.chain_skill
      mtarg = @subject.current_action.target_index
      btarg = @subject.current_action.make_targets.compact
      skip_num = 0
      action_array = @subject.current_action.item.chain_array
      action_array.each_with_index do |id,n|
        if skip_num > 0
          skip_num -= 1
          next
        end
        st = [id]
        skills_hash = CP::CHAIN::COMBOS.dup
        if CP::CHAIN::ACTOR_COMBOS.include?(@subject.id)
          CP::CHAIN::ACTOR_COMBOS[@subject.id].each { |k,r| skills_hash[k] = r }
        end
        skills_hash.each do |k,r|
          next if k.empty?
          setup = action_array[n,k.size]
          if setup == k
            skip_num = k.size - 1
            st = r
            break
          end
        end
        st.each do |id2|
          @subject.temp_chain_action = Game_Action.new(@subject)
          @subject.current_action.set_skill(id2)
          @subject.current_action.target_index = mtarg
          next if CP::CHAIN::SINGLE_TARGET &&
                  @subject.current_action.item.need_selection? &&
                  @subject.current_action.make_targets.compact != btarg
          next unless @subject.current_action.valid?
          cp_chain_use_item
          @log_window.wait_and_clear
          break if $game_troop.alive_members.empty?  ## Break if battle won.
        end
        break if $game_troop.alive_members.empty?  ## Break if battle won.
      end
      @subject.temp_chain_action = nil
    else
      cp_chain_use_item
    end
  end
  
  alias :cp_cskills_turn_end :turn_end
  def turn_end  ## Removes chains from the skills data.
    $data_skills -= @remove_chain_skills_array || []
    @remove_chain_skills_array = []
    cp_cskills_turn_end
  end
end

module CP  ## Common methods for all later classes.
module REGEXP
module CHAIN
  BLOCKS_1 = /chain blocks\[(\+|-)?(\d+)\]/i
  USAGE_1  = /chain usage\[(\d+)\]/i
  FOLLOW_1 = /chain follow\[([\d, ]+)\]/i
  FINISH_1 = /<chain finisher>/i
  
  def default_chain_blocks
    return 0
  end
  
  def chain_modifier
    get_chain_blocks if @chain_modifier.nil?
    return @chain_modifier
  end
  
  def chain_blocks
    get_chain_blocks if @chain_blocks.nil?
    return @chain_blocks
  end
  
  def get_chain_blocks
    @chain_modifier = default_chain_blocks
    @chain_blocks = default_chain_blocks
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when BLOCKS_1
        case $1.to_s
        when '-'
          @chain_modifier = -$2.to_i
        when '+'
          @chain_modifier = $2.to_i
        else
          @chain_blocks = $2.to_i
        end
      end
    end
  end
end
end
end

class RPG::Skill < RPG::UsableItem  ## Creates neccessary skill data.
  attr_accessor :chain_skill, :chain_array, :chain_finisher
  attr_writer   :chain_blocks
  
  attr_accessor :hp_cost, :gold_cost, :item_cost, :req_state, :req_switch,
                :req_variable, :req_actor, :req_w, :req_a
  
  attr_accessor :hp_cost_percent, :mp_cost_percent, :tp_cost_percent,
                :gold_cost_percent, :cast_ani
  
  include CP::REGEXP::CHAIN
  
  alias :cp_chain_init :initialize
  def initialize(*args)
    cp_chain_init(*args)
    yanfly_skill_additions
  end
  
  def yanfly_skill_additions
    @hp_cost_percent ||= 0
    @mp_cost_percent ||= 0
    @tp_cost_percent ||= 0
    @gold_cost_percent ||= 0
    @hp_cost ||= 0
    @gold_cost ||= 0
    @cast_ani ||= 0
  end
  
  def chain_usage
    get_chain_blocks if @chain_usage.nil?
    return @chain_usage
  end
  
  def chain_follow
    get_chain_blocks if @chain_follow.nil?
    return @chain_follow
  end
  
  def chain_finisher
    get_chain_blocks if @chain_finisher.nil?
    return @chain_finisher
  end
  
  def get_chain_blocks
    @chain_modifier = default_chain_blocks
    @chain_usage = CP::CHAIN::DEFAULT_USAGE
    @chain_blocks = CP::CHAIN::DEFAULT_COST if @chain_blocks.nil?
    @chain_follow = []
    @chain_finisher = false if @chain_finisher.nil?
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when BLOCKS_1
        @chain_blocks = $2.to_i unless ['-', '+'].include?($1.to_s)
      when USAGE_1
        @chain_usage = $1.to_i
      when FOLLOW_1
        @chain_follow = $1.to_s.delete(' ').split(/,/).collect {|i| i.to_i}
      when FINISH_1
        @chain_finisher = true
      end
    end
  end
end

class RPG::Actor < RPG::BaseItem
  include CP::REGEXP::CHAIN  ## Extra chain info to other classes.
  
  def default_chain_blocks
    return CP::CHAIN::DEFAULT_CHAIN
  end
end

class RPG::Class < RPG::BaseItem
  include CP::REGEXP::CHAIN
  
  def default_chain_blocks
    return false
  end
end

class RPG::EquipItem < RPG::BaseItem
  include CP::REGEXP::CHAIN
end

class RPG::State < RPG::BaseItem
  include CP::REGEXP::CHAIN
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###