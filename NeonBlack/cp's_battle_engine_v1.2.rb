##----------------------------------------------------------------------------##
## CP's Battle Engine v1.2b
## Created by Neon Black
##
## Only for non-commercial use.  See full terms of use and contact info at:
## http://cphouseset.wordpress.com/liscense-and-terms-of-use/
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.2a+ in progress
##  1.2b released 1.26.2013 - Fixes vanishing enemy glitch
## v1.2 - 1.14.2013
##  Added new actor/enemy tags similar to 2k3 options
##  Added a simple sideview mode
##  Added in battle party change options
##  Changed battle animation queue into an array
##  Changed the fix for the "to screen" overlay bug
##  Numerous other small changes.
## v1.1 - 11.14.2012
##  Added mode 5 to replicate VX/2k styles
##  Removed compatibility with Foe Info View and Pop-ups v1.0 and v1.1
##  Fixed a bug related to skill and item window sizes
##  Slight tweaks and bugfixes
## v1.0a - 10.16.2012
##  Single line fix
## v1.0 - 9.11.2012
##  Final bugfixes and cleanup
## v0.3 - 9.10.2012
##  Numerous bugfixes
## v0.2 - 8.23.2012
##  Reorganized script
## v0.1 - 8.30.2012
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported = {} if $imported.nil?                                              ##
$imported["CP_BATTLEVIEW_2"] = 1.2                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script modifies the battle system to be more visually pleasing and
## gives it a few different additional features.  There are numerous notebox
## tags available to change how several aspects of the battle system work.
##
##------
##    Notebox Tags:
##      Monster note tags:
##
## attack[x]
##  - Sets a monster's normal attack animation to animation "x".  This affects
##    skills set to "normal attack" animation.
## attack skill[x]
##  - Sets the monster's normal attack skill to skill "x".  This is the skill
##    they will use when they are berserk or confused.
## defend skill[x]
##  - Same as above, but with defend.  Doesn't really have any effect on
##    monsters.
##
##      Actor/Class note tags:
##    Note that Actor takes priority in all these tags.
## battler[name]
##  - Sets the actor's battler graphic to graphic "name".  Note that it must be
##    a file present in the folder "graphics/battlers".  This only has effect
##    in mode 4.
## side battler[name]
##  - Sets the name of the image to use for battlers in sideview mode.  If this
##    is not set, the character's left facing graphic is used.
## attack skill[x]
##  - Sets the actor's basic attack skill to kill "x".  This affects the basic
##    attack command as well as any party attack command or other command that
##    makes the actor auto attack.  Class version of this tag takes priority
##    over Actor version.
## defend skill[x]
##  - Same as above only with the defend skill.  Class version of this tag
##    takes priority over Actor version.
## hide mp  -or-  hide tp
##  - Hides the stat reguardless of any other conditions.  This stat will not
##    appear for the character during battle.
##
##      Monster and Actor/Class note tags:
## <flying>
##  - Causes the actor or enemy to bob up and down in battle as if they are
##    flying or floating.
## <transparent>
##  - Causes the actor or enemy to become partially transparent.
## <mirror>
##  - Mirrors the actor or enemy's battler sprite.
##
##      Skill note tags:
## cast anim[x]
##  - Sets the skill's casting animation to animation "x".  This plays on the
##    user of the skill before it is cast.
##
##    Weapon note tags:
## attack skill[x]
##  - Sets a characters default attack skill to skill ID "x" while the weapon
##    is equipped.  This takes priority over Actor and Class tags.
##
##------
##    Setting up Actor Command Blocks:
## The commands an actor has in battle can be modified using the notebox.  Note
## that you do not need to define this on any actor and actors that do not have
## this in their notebox will use the array at line 292 instead.  This will
## allow you to have certain commands on certain characters but not on other
## characters.  To do this, set up a section of the notebox in the following
## format:
##
##   <commands>
##   :attack
##   :defend
##   :skill
##   Name => 10
##   :item
##   :party
##   </commands>
##
## <commands>
##  - Designates the start of the actor's commands.  Must be used before any
##    skills are checked for.
## :attack
##  - The basic attack command will go here in the menu.
## :defend
##  - The basic defend command will go here in the menu.
## :skill
##  - All skill subsets an actor has will be placed here.  These are the basic
##    skill subsets that house the normal gameplay skills.
## :item
##  - The items command will go here in the menu.
## :party
##  - Allows the party member to switch out on their turn.
## Name => 10
##  - Used to designate a special skill.  The format is (I feel) relatively
##    simple.  The "Name" part is the name of the skill that will display in
##    the command window.  The number is the ID of the skill.  Note that the
##    skill conditions must still be met in order for the skill to be used.
##----------------------------------------------------------------------------##
                                                                              ##
module CP       # Do not touch                                                ##
module BATTLERS #  these lines.                                               ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
#    Graphical Config:

# First things first.  This is the number of battlers you will have in battle.
# Be careful as this may have undesired effects with certain scripts outside
# of battle.
BATTLERS_MAX = 4

# Allows members from the system tab to be added during test battles to
# increase the party size.
ADD_SYSTEM_MEMBERS = false

# This is the number of frames a single frame of battle animation will last.
# Lower numbers produce quicker and smoother animations.  3 or 4 are the best
# values.
ANIM_RATE = 4

# This is the option for determining battle style.  There are 4 modes it can be
# set to based on the values you choose.
# Mode 1 = Looks like the default battle engine.
# Mode 2 = Similar but displays faces in the status window.
# Mode 3 = Displays character battlers.  See above for note tags to set these.
# Mode 4 = Displays faces outside any window.
# Mode 5 = Simulates RM2K and RMVX styles with slight variations.
BATTLE_STYLE = 1

# This variable holds the battle style.  You can change this in game to change
# the battle style.
VARIABLE = 51

# In mode 2, this is the opacity of the status window.  In modes 3 and 4, this
# is the opacity of the actor command window.
WINDOW_OPACITY = 100

# If this option is set to true, the help window will always be open during
# actor command selection.
SHOW_HELP_WINDOW = false

# This is the size of the text for name, hp, mp, and tp in modes 2, 3, and 4.
LINE_HEIGHT = 16

# This determines if MP and TP are hidden when the user has no skills that use
# those types of pools.  For example, if a user does not have any skills that
# use MP, MP will be hidden until one is obtained.
HIDE_UNUSED_POOLS = false

# Determines if the skill and item windows will have variable sizes based on
# the number available.  If true, it will start with 1 row and add more if
# there are more items.  In modes 1 and 2 this will try to fill the screen, in
# modes 3 and 4 this will cap at 4 rows before scrolling.
VAR_HEIGHT = false

# This is the y placement offset of the monsters in battle.  This will allow
# you to shift all monster groups up or down without having to modify the
# groups themselves.
Y_OFFSET = 0

# This option corrects troop placement when the window is resized.  No matter
# the window size, the troop position will be centered in the window based on
# the placement in the editor.  Turn this off is using a script like Yanfly
# Core Engine that already does this.
RESIZE_CORRECTION = true

# This is the offset for animations that cover the screen and target the
# players party.  This will allow these animations to be shifted down and
# actually cover the actors.  This is disabled in sideview battles.
ANIM_OFFSET = 120

# This is the placement of actor battlers in mode 3 from the bottom of the
# screen.  Use this to shift them up or down.
Y_PLACEMENT = -12

# This is the zoom of actor battlers.  Use this to make them larger or smaller
# than normal battlers.  This only affects mode 3 and does not affect sideview
# battlers.
ZOOM = 100

# This is the cast animation for when an item is used.  Setting it to nil will
# prevent an animation from being displayed.
ITEM_ANIM = nil

# This hash contains the animations for when different skill types are used.
# Note that the skill note tag above takes priority.  To use, use the format
# "x => y," where "x" is the ID of the skill group and "y" is the animation to
# display.
CAST_ANIMS ={
  1 => 43,
  2 => 81,
}

##------
#    Party Config:

# These are the names for the new options that can be added to the party
# command window.
AUTO_NAME = "Auto"
RUSH_NAME = "All-out"
GUARD_NAME = "Defend"
PARTY_NAME = "Members"
SWITCH_NAME = "Switch"

# These are the commands to display in the party menu.
# :fight - Allows the player to select each action.
# :auto - Actors choose commands by auto.
# :rush - All actors attack the first enemy.
# :defend - All actors defend.
# :escape - Allows the player to flee from battle.
COMMANDS =[
  :fight,
  :auto,
  :rush,
  :guard,
  :party,
  :escape,
]

# These are the default abilities each actor in the party has.  If an actor has
# an empty list of commands they will get this list instead.  The notebox
# version of this takes priority.  See the instructions section titled
# "Setting up Actor Command Blocks" for a list of valid commands.  Additional
# commands from add-on scripts may be used here as well.
ABILITIES =[
  :attack,
  :skill,
  :defend,
  :item,
  :party,
]

# This option determines what a character's state must be in order to switch
# them in battle.
# 0 = Members always movable.
# 1 = Members must be alive.
# 2 = Members must be able to act.
# 3 = Members must be able to recieve input.
# 4 = Members may not be inflicted with status at all.
MOVE_MEMBERS = 1

# If this option is enabled, the player can only use the switch command from
# the party command window once per turn.
RESTRICT_USAGE = true

# This sets the change in speed of party members who are switched out on their
# turn.  Increasing this number makes the switch occur sooner.
SWITCH_SPEED = 0

# These are lines of text that can display when certain functions are performed
# in battle.  You can use the strings <target>, <user>, and <skill> in the line
# and they will be automatically replaced with the name of the user, target, or
# skill.
SWITCH_LOG = "<target> has switched out with <user>."

# This hash contains the help text to be displayed while the cursor is over a
# skill group during battle.  Note that each number is the same as the ID of
# the skill type in the data base, 0 is for while "items" is highlighted, and
# -1 is for while "party" is highlighted from the actor command window.  You
# can have a second line by adding "\n" to the string."
SKILL_HELP_TEXT ={
 -1 => "Switch places with a member on reserve.",
  0 => "Uses an item from the party's inventory.",
  1 => "Attack with a variety of offensive skills.",
  2 => "Cast a variety of offensive and supportive magics.",
}

##------
#    Sideview Battle System Config:
# This is the option to determine if sideview is turned on or off by default.
BATTLE_SIDE = false

# This is the switch that holds the sideview battle option.  You can turn this
# switch ON to enable sideview and OFF to disable it.
SBS_SWITCH = 52

# These values are the X and Y positions of the actors' feet when the sideview
# system is enabled.  Each number represents party position.
SBS_POS ={
  1  => [  462, 180  ],
  2  => [  480, 210  ],
  3  => [  492, 248  ],
  4  => [  500, 288  ],
}

# This option determines if animations are flipped when used by enemies.  This
# allows the animations to display properly no matter if the party or troop is
# using the skill.
FLIP_ANIM = true

##------
#    Add-on Config:
#  These are additional config options for scripts deemed compatible with
#  CPBE.  These include such things as allowing the said scripts to be enabled
#  or disabled by a switch, adding additional options, or extended cross
#  support.  Each add-on's options are listed below the name and supported
#  version of the script.

#    CP Battle Pop-ups v1.2+
# While the following switch is ON, battle pop-ups will NOT display.
POP_SWITCH = 51

##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


HIDE_V = /hide (hp|mp|tp)/i
NAME   = /battler\[(.+)\]/i
SIDE   = /side battler\[(.+)\]/i
ATTACK = /attack\[(\d+)\]/i
CAST   = /cast anim\[(\d+)\]/i
SCOMM  = /:(attack|skill|defend|item)/
NCOMM  = /(.*) => (\d+)/
COPEN  = /<commands>/i
CCLOSE = /<\/commands>/
ATK_ID = /attack skill\[(\d+)\]/i
DEF_ID = /defend skill\[(\d+)\]/i
TRANS  = /<transparent>/i
FLY    = /<flying>/i
MIRROR = /<mirror>/i

def self.styles; return [1, 2, 3, 4, 5]; end

def self.style  ## Gets the currently active style of the system.
  unless styles.include?($game_variables[VARIABLE])
    $game_variables[VARIABLE] = BATTLE_STYLE
  end
  return $game_variables[VARIABLE]
end

def self.sideview
  $game_switches[SBS_SWITCH] = BATTLE_SIDE unless @init_side; @init_side = true
  return $game_switches[SBS_SWITCH]
end

def self.style1; return style == 1; end
def self.style2; return style == 2; end
def self.style3; return style == 3; end
def self.style4; return style == 4; end
def self.style5; return style == 5; end

def self.classic; return [1, 2, 5].include?(style); end
def self.dated;   return [3, 4].include?(style);    end
def self.basic;   return [1, 5].include?(style);    end

def self.faceless; return [1, 3].include?(style); end
def self.face;     return [2, 4].include?(style); end

def self.clear_pop
  return $game_switches[POP_SWITCH]
end

end
end

module BattleManager
  def self.input_start
    if @phase != :input
      @phase = :input
      $game_troop.increase_turn  ## Turn increase moved up here to fix the
      $game_party.make_actions   ## turn counting on foes.
      $game_troop.make_actions
      clear_actor
    end
    return !@surprise && $game_party.inputable?
  end
  
  def self.turn_start
    @phase = :turn
    clear_actor  ## Removed turn count from here.
    make_action_orders
  end
end

class Game_Message
  alias cp_bv2_add add
  def add(text)
    cp_bv2_add(text)
    return unless CP::BATTLERS.style5 && $game_party.in_battle
    @background = 2
  end
end

class Game_Action
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?  ## Added this line to add enemy healing AI.
        evaluate_item if @target_index < 0
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.alive_members
      end
    end
  end
end

class Game_Battler < Game_BattlerBase
  attr_accessor :c_blinking  ## Used to add blinking in modes 3 and 4.
  
  alias cp_bv2_gb_init initialize
  def initialize
    cp_bv2_gb_init
    @c_blinking = false
  end
end

class Game_Enemy < Game_Battler
  def atk_animation_id
    if enemy.nattack_id == 0  ## Gets the animation of a foe's skill.
      rs = $data_skills[attack_skill_id].animation_id == -1 ? 1 :
           $data_skills[attack_skill_id].animation_id
    else
      rs = enemy.nattack_id
    end
    return rs
  end
  
  def attack_skill_id  ## Gets the basic attack and defend skills of a foe.
    enemy.sattack_id
  end
  
  def guard_skill_id
    enemy.sdefend_id
  end
  
  def flying?
    enemy.motion_flying
  end
  
  def transparent?
    enemy.motion_trans
  end
  
  def mirrored?
    enemy.motion_mirror
  end
end

class Game_Actor < Game_Battler
  attr_accessor :screen_x_pos_bv2
  attr_accessor :screen_y_pos_bv2
  attr_accessor :side_battler
  
  def animation_mirror  ## Mirrors animations displayed on actors.
    @animation_mirror = false unless @animation_mirror
    if CP::BATTLERS.sideview && CP::BATTLERS::FLIP_ANIM
      return !@animation_mirror
    else
      return @animation_mirror
    end
  end
  
  alias cp_bv2_setup setup
  def setup(actor_id)
    cp_bv2_setup(actor_id)  ## Creates an actor's battler.
    @battler_name = actor.battler_name
    @battler_name = self.class.battler_name if @battler_name == ""
    @side_battler = actor.side_battler
    @side_battler = self.class.side_battler if @side_battler == ""
  end
  
  def use_sprite?  ## Makes the actor use a sprite in certain modes.
    return true if CP::BATTLERS.sideview
    return false if CP::BATTLERS.basic
    return true if CP::BATTLERS.face
    return @battler_name == "" ? false : true
  end
  
  def all_commands  ## Gets all of an actor's commands with skills.
    res = commands.size
    return res unless commands.include?(:skill)
    res += added_skill_types.size - 1
    return res
  end
  
  def commands  ## Gets the actor's base commands.
    return actor.commands unless actor.commands.empty?
    return self.class.commands unless self.class.commands.empty?
    return CP::BATTLERS::ABILITIES
  end
  
  def attack_skill_id  ## Gets the actor's base attack skill.
    unless weapons.empty? || weapons[0].attack_skill == 0
      return weapons[0].attack_skill
    end
    return actor.sattack_id unless actor.sattack_id == 0
    return self.class.sattack_id unless self.class.sattack_id == 0
    return 1
  end
  
  def guard_skill_id  ## Gets the actor's base guard skill.
    return actor.sdefend_id unless actor.sdefend_id == 0
    return self.class.sdefend_id unless self.class.sdefend_id == 0
    return 2
  end
  
  def hide_mp?  ## Hide MP and TP under certain conditions.
    return true if actor.hide_mp?
    if CP::BATTLERS::HIDE_UNUSED_POOLS
      skills.each do |skill|
        if $imported["CP_SKILLCOSTS"]
          return false if skill_mp_cost(skill) > 0
          return false if skill.all_mp
        else
          return false if skill.mp_cost > 0
        end
      end
      return true
    end
    return false
  end
  
  def hide_tp?
    return true if actor.hide_tp?
    if CP::BATTLERS::HIDE_UNUSED_POOLS
      skills.each do |skill|
        if $imported["CP_SKILLCOSTS"]
          return false if skill_tp_cost(skill) > 0
          return false if skill.all_tp
        else
          return false if skill.tp_cost > 0
        end
      end
      return true
    end
    return false
  end
  
  def flying?
    actor.motion_flying
  end
  
  def transparent?
    actor.motion_trans
  end
  
  def mirrored?
    actor.motion_mirror
  end
end

class Game_Party < Game_Unit
  def max_battle_members  ## The max allowed battle characters.
    return CP::BATTLERS::BATTLERS_MAX
  end
  
  alias cp_bv2_setup_bt_addition setup_battle_test_members
  def setup_battle_test_members  ## Adds system members.
    cp_bv2_setup_bt_addition
    return unless CP::BATTLERS::ADD_SYSTEM_MEMBERS
    $data_system.party_members.each {|m| add_actor(m)}
  end
end

class Window_BattleLog < Window_Selectable
  def max_line_number  ## Changes the window for mode 5.
    return CP::BATTLERS.style5 ? 4 : 6
  end
  
  def back_opacity
    return CP::BATTLERS.style5 ? 0 : 64
  end
end

class Window_PartyCommand < Window_Command
  def visible_line_number  ## Mods the size of an party's battle window.
    return CP::BATTLERS.dated ? CP::BATTLERS::COMMANDS.size : 4
  end
  
  def make_command_list  ## Creates a list of the commands.
    CP::BATTLERS::COMMANDS.each do |com|
      case com
      when :fight
        add_command(Vocab::fight,  :fight)
      when :auto
        add_command(CP::BATTLERS::AUTO_NAME, :auto)
      when :rush
        add_command(CP::BATTLERS::RUSH_NAME, :rush)
      when :guard
        add_command(CP::BATTLERS::GUARD_NAME, :block)
      when :escape
        add_command(Vocab::escape, :escape, BattleManager.can_escape?)
      when :party
        add_command(CP::BATTLERS::PARTY_NAME, :party, SceneManager.scene.switch? &&
                $game_party.all_members.size > $game_party.max_battle_members)
      end
    end
  end
end

class Window_ActorCommand < Window_Command
  def visible_line_number  ## Gets the size of the actor's battle window.
    return 4 if @actor.nil? || CP::BATTLERS.classic
    i = @actor.all_commands
    h = @help_window ? @help_window.height : 0
    return [i, (Graphics.height - (120 + h)) / line_height].min
  end
  
  def make_command_list  ## Makes the list of commands.
    size1 = fitting_height(visible_line_number)
    size2 = Graphics.height - 120
    self.height = [size1, size2].min unless self.disposed?
    return unless @actor
    @actor.commands.each do |comm|
      if comm.is_a?(Symbol)  ## Gets each command by it's symbol.
        case comm
        when :attack
          add_command(Vocab::attack, :attack, @actor.attack_usable?,
                      @actor.attack_skill_id)
        when :skill
          @actor.added_skill_types.sort.each do |stype_id|
            name = $data_system.skill_types[stype_id]
            add_command(name, :skill, true, stype_id)
          end
        when :defend
          add_command(Vocab::guard, :guard, @actor.guard_usable?,
                      @actor.guard_skill_id)
        when :item
          add_command(Vocab::item, :item)
        when :party
          add_command(CP::BATTLERS::SWITCH_NAME, :party,
                  $game_party.all_members.size > $game_party.max_battle_members)
        else
          addon_command(comm)
        end
      elsif comm.is_a?(Array)
        can_use = @actor.usable?($data_skills[comm[1]])
        add_command(comm[0], :cp_command, can_use, comm[1])
      end
    end
  end
  
  unless method_defined?(:addon_command)
    def addon_command(comm)
    end
  end
  
  def update
    super  ## Makes the window stay open or closed during modes 3/4.
    return if CP::BATTLERS.classic
    self.hide if !active
    self.show if (active || ![0, 255].include?(openness))
  end
  
  def update_help  ## Updates the help window if it is turned on.
    case current_symbol  ## Get the command's help by symbol.
    when :attack, :guard, :cp_command
      @help_window.set_item($data_skills[current_ext])
    when :skill
      @help_window.set_text("") unless CP::BATTLERS::SKILL_HELP_TEXT.include?(current_ext)
      @help_window.set_text(CP::BATTLERS::SKILL_HELP_TEXT[current_ext])
    when :item
      @help_window.set_text(CP::BATTLERS::SKILL_HELP_TEXT[0])
      @help_window.set_text("") unless CP::BATTLERS::SKILL_HELP_TEXT.include?(0)
    when :party
      @help_window.set_text(CP::BATTLERS::SKILL_HELP_TEXT[-1])
      @help_window.set_text("") unless CP::BATTLERS::SKILL_HELP_TEXT.include?(-1)
    else
      addon_help_update(current_symbol)
    end
  end
  
  unless method_defined?(:addon_help_update)
    def addon_help_update(sym)
    end
  end
end

class Window_BattleStatus < Window_Selectable
  def window_width  ## Creates the party box width by mode.
    return CP::BATTLERS.classic ? Graphics.width - 128 : Graphics.width
  end
  
  def window_height  ## Gets the size of the party box by mode.
    return fitting_height(visible_line_number) if CP::BATTLERS.basic
    return 96 + standard_padding * 2  ## This is technically the same.
  end  ## The values that need this are more or less hard coded anyway....
  
  def col_max  ## Gets the max columns for other modes.
    return CP::BATTLERS.basic ? 1 : $game_party.max_battle_members
  end
  
  def spacing  ## Spacing.  Modded for certain types for a better feel.
    return 32 if CP::BATTLERS.basic
    return 0 if CP::BATTLERS.style2
    return standard_padding * 2
  end
  
  def item_height  ## Changes the height based on the current mode.
    return CP::BATTLERS.basic ? line_height : 96
  end
  
  def line_height  ## Changes the height of window items based on mode.
    return CP::BATTLERS.basic ? 24 : CP::BATTLERS::LINE_HEIGHT
  end
  
  alias cp_bv2_old_draw_item draw_item
  def draw_item(index)  ## Draws different contents based on the mode.
    return cp_bv2_old_draw_item(index) if CP::BATTLERS.basic
    contents.font.size = line_height
    actor = $game_party.battle_members[index]
    rect = rect_by_style(index)
    draw_bv2_face(actor, rect, index) if CP::BATTLERS.style2
    draw_basic_area_bv2(rect, actor)
    draw_gauge_area_bv2(rect, actor)
    contents.font.size = Font.default_size
  end
  
  def draw_bv2_face(actor, rect, nd)  ## Modded faces for modes 2/3.
    face_name = actor.face_name; face_index = actor.face_index
    bitmap = Cache.face(face_name)
    bt = Bitmap.new(96, 96)
    src = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    bt.blt(0, 0, bitmap, src)
    size = Rect.new((96 - rect.width) / 2, 0, rect.width, rect.height)
    contents.blt(rect.x, rect.y, bt, size, trans?(nd) ? 255 : translucent_alpha)
  end
  
  def trans?(index)  ## Determines if the face is transparent or not.
    return true if @index == -1
    return (index == @index)
  end
  
  def rect_by_style(index)  ## Gets the item rectangle based on the style.
    rect = item_rect(index)
    return rect if CP::BATTLERS.faceless
    sides = rect.width - 96
    if sides > 0
      rect.width -= sides
      rect.x += sides / 2
    end
    cw = contents.width / CP::BATTLERS::BATTLERS_MAX
    rect.width = [rect.width, cw].min if CP::BATTLERS.style2
    return rect
  end
  
  def draw_basic_area_bv2(rect, actor)  ## Draws the basic HUD items.
    bottom = rect.y + rect.height
    i_w = contents.text_size(actor.name).width
    ncen = (rect.width - i_w) / 2
    total_icons = actor.state_icons.size + actor.buff_icons.size
    icen = [rect.width - total_icons * 24, rect.width % 24].max
    faces = CP::BATTLERS.face
    iy = faces ? bottom - line_height * 2 - 24 : rect.y
    ny = faces ? rect.y : bottom - line_height * 3
    draw_object_back(rect.x, ny, rect.width, ncen)
    draw_actor_name(actor, rect.x + ncen, ny, rect.width)
    draw_actor_icons(actor, rect.x + icen / 2, iy, rect.width - icen)
  end
  
  def draw_object_back(x, y, width, edge)
    l_h = line_height - 6  ## The fancy back used by the name on the HUD.
    c1 = gauge_back_color
    c1.alpha = 0
    c2 = gauge_back_color
    c2.alpha = 192
    temp = Bitmap.new(width, l_h)
    temp.gradient_fill_rect(0, 0, edge, l_h, c1, c2)
    temp.gradient_fill_rect(0 + width - edge, 0, edge, l_h, c2, c1)
    temp.fill_rect(0 + edge, 0, width - edge * 2, l_h, c2)
    contents.blt(x, y + 6, temp, temp.rect)
  end
  
  def draw_gauge_area_bv2(rect, actor)
    if $data_system.opt_display_tp  ## Draws either with or without TP.
      draw_gauge_area_with_tp_bv2(rect, actor)
    else
      draw_gauge_area_without_tp_bv2(rect, actor)
    end
  end
  
  def draw_gauge_area_with_tp_bv2(rect, actor)
    return draw_gauge_area_without_tp_bv2(rect, actor, :mp) if actor.hide_tp?
    return draw_gauge_area_without_tp_bv2(rect, actor, :tp) if actor.hide_mp?
    bottom = rect.y + rect.height  ## The with TP drawing.
    cen = rect.width / 2
    draw_actor_hp(actor, rect.x,       bottom - line_height * 2, rect.width)
    draw_actor_mp(actor, rect.x,       bottom - line_height,     cen)
    draw_actor_tp(actor, rect.x + cen, bottom - line_height,     cen)
  end
  
  def draw_gauge_area_without_tp_bv2(rect, actor, val = :mp)
    bottom = rect.y + rect.height  ## Without TP.
    i = CP::BATTLERS.style3 ? 2 : val == :mp && actor.hide_mp? ? 1 :
        val == :tp && actor.hide_tp? ? 1 : 2
    draw_actor_hp(actor, rect.x, bottom - line_height * i, rect.width)
    if val == :mp
      return if actor.hide_mp?
      draw_actor_mp(actor, rect.x, bottom - line_height,     rect.width)
    elsif val == :tp
      return if actor.hide_tp?
      draw_actor_tp(actor, rect.x, bottom - line_height,     rect.width)
    end
  end
  
  def draw_gauge_area_with_tp(rect, actor)  ## Modded old methods.
    return draw_gauge_area_without_tp(rect, actor, :mp) if actor.hide_tp?
    return draw_gauge_area_without_tp(rect, actor, :tp) if actor.hide_mp?
    draw_actor_hp(actor, rect.x + 0, rect.y, 72)
    draw_actor_mp(actor, rect.x + 82, rect.y, 64)
    draw_actor_tp(actor, rect.x + 156, rect.y, 64)
  end
  
  def draw_gauge_area_without_tp(rect, actor, val = :mp)
    if val == :mp
      if actor.hide_mp?
        draw_actor_hp(actor, rect.x + 0, rect.y, 220)
      else
        draw_actor_hp(actor, rect.x + 0, rect.y, 134)
        draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
      end
    elsif val == :tp
      if actor.hide_tp?
        draw_actor_hp(actor, rect.x + 0, rect.y, 220)
      else
        draw_actor_hp(actor, rect.x + 0, rect.y, 134)
        draw_actor_tp(actor, rect.x + 144,  rect.y, 76)
      end
    else
      draw_actor_hp(actor, rect.x + 0, rect.y, 220)
    end
  end
  
  def update_cursor  ## Determines how to show the cursor by mode.
    refresh if CP::BATTLERS.style2
    return super if CP::BATTLERS.basic
    cursor_rect.empty
  end
end

class Window_BattleActor < Window_BattleStatus
  def col_max  ## Max columns used by the party target window.
    return CP::BATTLERS.dated ? item_max : 1
  end
  
  def item_max  ## Max items.  Always the same....
    return $game_party.battle_members.size
  end
  
  def window_height  ## The height based on mode.
    return fitting_height(visible_line_number)
  end
  
  def visible_line_number  ## Used for above method.
    return CP::BATTLERS.dated ? 1 : 4
  end
  
  def line_height
    return 24  ## Used to overwrite the super.
  end
  
  def item_width  ## Width.  Always the same....
    return width - (standard_padding * 2)
  end
  
  def item_height  ## Once again, overwrites super.
    return line_height
  end
  
  def contents_width  ## Same as above.
    return (item_width + spacing) * col_max - spacing
  end
  
  def draw_item(index)  ## Draws a horizontal view of battle status.
    actor = $game_party.battle_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  
  def skill_viewport=(skill_viewport)
    @skill_viewport = skill_viewport
  end
  
  alias cp_bv2_show_old show 
  def show  ## Shows the box and selects the first item.
    @skill_viewport.rect.width = Graphics.width - width if @skill_viewport
    return cp_bv2_show_old if CP::BATTLERS.classic
    select(0)
    super
  end
  
  alias cp_bv2_hide_old hide
  def hide  ## Hides the window and stops all blinking.
    cp_bv2_hide_old
    @skill_viewport.rect.width = Graphics.width if @skill_viewport
    $game_party.battle_members.each {|m| m.c_blinking = false}
  end
  
  def process_cursor_move  ## Prevents left/right wrapping.
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(false)                  if Input.repeat?(:RIGHT)
    cursor_left (false)                  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
  end
  
  def current_item_enabled?  ## Gets which members are properly allowed.
    return true if @dead_members
    case CP::BATTLERS::MOVE_MEMBERS
    when 1
      return $game_party.battle_members[@index].alive?
    when 2
      return $game_party.battle_members[@index].movable?
    when 3
      return $game_party.battle_members[@index].inputable?
    when 4
      return $game_party.battle_members[@index].normal?
    else
      return true
    end
    return false
  end
  
  def ensure_cursor_visible  ## Ensures the proper actor is displayed.
    return super if CP::BATTLERS.classic
    self.ox = @index * (item_width + spacing)
  end
  
  def update_cursor  ## Modded to make actors blink.
    return super if CP::BATTLERS.basic
    $game_party.battle_members.each {|m| m.c_blinking = @cursor_all}
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
      mem = $game_party.battle_members[@index]
      mem.c_blinking = true unless mem.nil?
    end
  end
  
  def activate(dead = true)  ## Determines if dead members may be selected.
    super()
    @dead_members = dead
  end
end

class Winodw_ExtraMembers < Window_BattleActor
  def item_max  ## Max items.  Always the same....
    return extra_members.size
  end
  
  def extra_members  ## Members not currently in the party.
    return $game_party.all_members - $game_party.battle_members
  end
  
  def draw_item(index)  ## Draws a horizontal view of battle status.
    actor = extra_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  
  def actor_window=(actor_window)
    @actor_window = actor_window
  end
  
  def current_item_enabled?
    return true if @dead_members
    return false if last_for_dead
    return false if already_switch_in
    case CP::BATTLERS::MOVE_MEMBERS
    when 1
      return extra_members[@index].alive?
    when 2
      return extra_members[@index].movable?
    when 3
      return extra_members[@index].inputable?
    when 4
      return extra_members[@index].normal?
    else
      return true
    end
    return false
  end
  
  def last_for_dead  ## Prevents filling the party with dead members.
    return false unless @actor_window
    return false if $game_party.alive_members.size > 1
    return false unless $game_party.battle_members[@actor_window.index].alive?
    return false if extra_members[@index].alive?
    return true
  end
  
  def already_switch_in  ## Prevents a member from being switched in twice.
    $game_party.battle_members.each do |mem|
      mem.actions.each do |act|
        next if act.item.nil? || act.item.swap_party.nil?
        id = act.item.swap_party
        return true if id == $game_party.all_members.index(extra_members[@index])
      end
    end
    return false
  end

  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end
  
  def activate(dead = true)
    super()
    @dead_members = dead
  end
end

class Window_BattleEnemy < Window_Selectable
  def col_max  ## Mods it's own size based on style.
    return 2 if CP::BATTLERS.classic
    return 3
  end
  
  alias cp_bv2_wind_width window_width
  def window_width  ## Mods it's width based on style.
    return cp_bv2_wind_width if CP::BATTLERS.classic
    return Graphics.width
  end
  
  def update_cursor  ## Causes enemies to blink.
    $game_troop.alive_members.each {|m| m.c_blinking = @cursor_all}
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
      self.top_row = 0
    elsif @index < 0
      $game_troop.alive_members.each {|m| m.c_blinking = false}
      cursor_rect.empty
    else
      mem = $game_troop.alive_members[@index]
      mem.c_blinking = true unless mem.nil?
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end  ## Added method for old script.
    if !active
      $game_troop.alive_members.each {|m| m.c_blinking = false}
    end
  end
  
  def skill_viewport=(skill_viewport)
    @skill_viewport = skill_viewport
  end
  
  alias cp_bv2_show_old show
  def show  ## Changes the info viewport by style.  Ignored with CP Battleview.
    @skill_viewport.rect.width = Graphics.width - width if @skill_viewport
    return cp_bv2_show_old if CP::BATTLERS.classic
    if @info_viewport
      tot = [(item_max / col_max + (item_max % col_max > 0 ? 1 : 0)), 1].max
      self.height = fitting_height(tot)
      create_contents
      refresh
      self.x = 0
      self.y = Graphics.height - height
      hr = @info_viewport.rect.height - height
      @info_viewport.rect.height = hr
      select(0)
    end
    super
  end
  
  alias cp_bv2_hide hide
  def hide  ## Reverts the info viewport to normal.
    cp_bv2_hide
    @skill_viewport.rect.width = Graphics.width if @skill_viewport
    if @info_viewport
      @info_viewport.rect.height = Graphics.height - @info_viewport.rect.y
    end
    $game_troop.alive_members.each {|m| m.c_blinking = false}
  end
end

class Window_BattleSkill < Window_SkillList
  def top_lines  ## Gets the max number of lines.
    return CP::BATTLERS.classic ? 99 : 4
  end
  
  def modded_height  ## Changes the window's height.
    if CP::BATTLERS::VAR_HEIGHT
      lines = [(item_max / col_max + (item_max % col_max > 0 ? 1 : 0)), 1].max
    else
      lines = top_lines
    end  ## Will find the best fit based on the number of items.
    set = (line_height * [top_lines, lines].min) + (standard_padding * 2)
    return [set, @info_viewport.rect.y - y].min
  end
  
  def info_viewport=(window)
    @info_viewport = window
  end
  
  alias cp_bv2_show show
  def show  ## Update the height when the window is shown.
    self.height = modded_height unless CP::BATTLERS.style5
    self.height = fitting_height(4) if CP::BATTLERS.style5
    @info_viewport.visible = false if CP::BATTLERS.style5
    refresh
    cp_bv2_show
  end
  
  def hide  ## Modded to prevent the help window from vanishing.
    @help_window.hide unless CP::BATTLERS::SHOW_HELP_WINDOW
    @info_viewport.visible = true if CP::BATTLERS.style5
    super
  end
end

class Window_BattleItem < Window_ItemList
  def top_lines  ## Same as the class above.
    return CP::BATTLERS.classic ? 99 : 4
  end
  
  def modded_height
    if CP::BATTLERS::VAR_HEIGHT
      lines = [(item_max / col_max + (item_max % col_max > 0 ? 1 : 0)), 1].max
    else
      lines = top_lines
    end
    set = (line_height * [top_lines, lines].min) + (standard_padding * 2)
    return [set, @info_viewport.rect.y - y].min
  end
  
  def info_viewport=(window)
    @info_viewport = window
  end
  
  alias cp_bv2_show show
  def show  ## Update the height when the window is shown.
    self.height = modded_height unless CP::BATTLERS.style5
    self.height = fitting_height(4) if CP::BATTLERS.style5
    @info_viewport.visible = false if CP::BATTLERS.style5
    refresh
    cp_bv2_show
  end
  
  def hide  ## Modded to prevent the help window from vanishing.
    @help_window.hide unless CP::BATTLERS::SHOW_HELP_WINDOW
    @info_viewport.visible = true if CP::BATTLERS.style5
    super
  end
end

class Scene_Battle < Scene_Base  ## The blood and guts of the script!!
  alias cp_bv2_create_info_viewport create_info_viewport
  def create_info_viewport  ## Lots of changes here.
    cp_bv2_create_info_viewport  ## Changes some aspects of certain windows.
    opac = CP::BATTLERS::WINDOW_OPACITY
    @status_window.back_opacity = opac if CP::BATTLERS.style2
    @status_window.opacity = 0 if CP::BATTLERS.dated
    @spriteset.info(@info_viewport, @status_window) if CP::BATTLERS.style4
    return unless CP::BATTLERS.style2
    $game_party.members.each_with_index do |mem, i|
      edge = 64 + @status_window.standard_padding
      rec = @status_window.width - (@status_window.standard_padding * 2)
      rec /= $game_party.max_battle_members
      l_offset = @status_window.height - @status_window.standard_padding
      mem.screen_x_pos_bv2 = edge + rec * i + rec / 2
      mem.screen_y_pos_bv2 = Graphics.height - l_offset
    end
  end
  
  alias cp_bv2_party_window create_party_command_window
  def create_party_command_window
    cp_bv2_party_window  ## Adds commands to the party window.
    @party_command_window.viewport = nil unless CP::BATTLERS.classic
    @party_command_window.set_handler(:auto,  method(:command_auto))
    @party_command_window.set_handler(:rush,  method(:command_rush))
    @party_command_window.set_handler(:block, method(:command_block))
    @party_command_window.set_handler(:party, method(:command_party))
  end
  
  alias cp_bv2_clog_window create_log_window
  def create_log_window
    cp_bv2_clog_window
    return unless CP::BATTLERS.style5
    @log_window.y = Graphics.height - @log_window.height
    @log_window2 = Window_Base.new(0, @log_window.y, @log_window.width,
                                   @log_window.height)
    @log_window2.openness = 255
  end
  
  alias cp_bv2_create_item_window create_item_window
  def create_item_window
    cp_bv2_create_item_window
    @skill_viewport = Viewport.new
    return unless CP::BATTLERS.style5
    @item_window.y = 0
    @skill_window.y = 0
    @item_window.info_viewport = @info_viewport
    @skill_window.info_viewport = @info_viewport
    @skill_viewport.rect.y = @info_viewport.rect.y
    @skill_viewport.rect.height = @item_window.height
    @skill_viewport.z = 100
    @item_window.viewport = @skill_viewport
    @skill_window.viewport = @skill_viewport
  end
  
  alias cp_bv2_actor_window create_actor_command_window
  def create_actor_command_window
    cp_bv2_actor_window  ## Adds a new command to the actor window.
    @actor_command_window.set_handler(:cp_command, method(:command_new_comms))
    @actor_command_window.set_handler(:party,      method(:command_switch))
    return if CP::BATTLERS.classic
    @actor_command_window.viewport = nil  ## May change window opacity.
    @actor_command_window.back_opacity = CP::BATTLERS::WINDOW_OPACITY
  end
  
  alias cp_bv2_help_window create_help_window
  def create_help_window
    cp_bv2_help_window
    return unless CP::BATTLERS::SHOW_HELP_WINDOW
    @help_window.visible = true  ## Prevents removal of the help window.
    @help_window.openness = 0
    @actor_command_window.help_window = @help_window
  end
  
  alias cp_bv2_create_enemy_window create_enemy_window
  def create_enemy_window
    cp_bv2_create_enemy_window
    @enemy_window.skill_viewport = @skill_viewport
    @actor_window.skill_viewport = @skill_viewport
  end
  
  alias cp_bv2_create_actor_window create_actor_window
  def create_actor_window
    cp_bv2_create_actor_window
    @extras_window = Winodw_ExtraMembers.new(@info_viewport)
    @extras_window.actor_window = @actor_window
    @extras_window.set_handler(:ok,     method(:on_extras_ok))
    @extras_window.set_handler(:cancel, method(:on_extras_cancel))
  end
  
  def command_attack  ## Makes the basic attack command like other commands.
    skill = $data_skills[BattleManager.actor.attack_skill_id]
    command_new_comms(skill)
  end
  
  def command_guard  ## Same as attack command but with defend.
    skill = $data_skills[BattleManager.actor.guard_skill_id]
    command_new_comms(skill)
  end
  
  def command_party
    @party_command_window.hide unless CP::BATTLERS.classic
    select_actor_selection
    @actor_window.activate(false)
  end
  
  def command_switch
    unless CP::BATTLERS.classic
      @actor_command_window.hide
      ypos = 0
      ypos = @help_window.y + @help_window.height if @help_window.visible &&
                                                     @help_window.open?
      @extras_window.y = ypos
    end
    BattleManager.actor.input.set_swap_party(0)
    @extras_window.refresh
    @actor_window.select($game_party.battle_members.index(BattleManager.actor))
    @extras_window.show.activate(false)
  end
  
  def command_new_comms(skl = nil)  ## Pushes the selected command.
    skill = skl ? skl : $data_skills[@actor_command_window.current_ext]
    BattleManager.actor.input.set_skill(skill.id)
    if !skill.need_selection?  ## Determines selection type.
      next_command
    elsif skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  
  alias cp_bv2_select_actor select_actor_selection
  def select_actor_selection
    cp_bv2_select_actor
    return if CP::BATTLERS.classic
    ypos = 0  ## Determines where to put the status window.
    ypos = @help_window.y + @help_window.height if @help_window.visible &&
                                                   @help_window.open?
    ypos = @skill_window.y + @skill_window.height if @skill_window.visible
    ypos = @item_window.y + @item_window.height if @item_window.visible
    @actor_window.y = ypos
  end
  
  alias cp_bv2_on_a_ok on_actor_ok
  def on_actor_ok
    if @party_command_window.current_symbol == :party
      if CP::BATTLERS.classic
        @actor_window.hide
      else
        ypos = 0
        ypos = @actor_window.y + @actor_window.height if @actor_window.visible
        @extras_window.y = ypos
      end
      @extras_window.refresh
      @extras_window.show.activate(false)
    else
      cp_bv2_on_a_ok
    end
  end
  
  alias cp_bv2_on_e_cancel on_enemy_cancel
  def on_enemy_cancel
    cp_bv2_on_e_cancel  ## Allows the cursor to return to it's index normally.
    case @actor_command_window.current_symbol
    when :cp_command, :attack, :guard
      @actor_command_window.activate
    end
  end
  
  alias cp_bv2_on_a_cancel on_actor_cancel
  def on_actor_cancel
    cp_bv2_on_a_cancel  ## Same as above.
    if @party_command_window.current_symbol == :party
      @party_command_window.show.activate
    else
      case @actor_command_window.current_symbol
      when :cp_command, :attack, :guard
        @actor_command_window.activate
      end
    end
  end
  
  def on_extras_ok
    if @party_command_window.current_symbol == :party
      i = @actor_window.index
      n = @actor_window.item_max + @extras_window.index
      $game_party.swap_order(i, n)
      $game_party.make_actions
      @status_window.refresh
      @extras_window.hide
      @actor_window.hide
      @spriteset.dispose_actors
      @spriteset.create_actors
      @party_command_window.show.activate
      @already_party = CP::BATTLERS::RESTRICT_USAGE
      @party_command_window.refresh
    else
      n = @actor_window.item_max + @extras_window.index
      BattleManager.actor.input.set_swap_party(n)
      @extras_window.hide
      next_command
    end
  end
  
  def on_extras_cancel
    @extras_window.hide
    if @party_command_window.current_symbol == :party
      i = @actor_window.index
      select_actor_selection
      @actor_window.select(i)
    else
      @actor_command_window.show.activate
    end
  end
  
  alias cp_bv2_status_create create_actor_window
  def create_actor_window
    cp_bv2_status_create  ## Mods the status window viewport OX by style.
    @info_viewport.ox = 128 unless CP::BATTLERS.classic
  end
  
  def show_attack_animation(targets, user = @subject)
    if user.actor?  ## Fixes how animations are shown by battler.
      show_normal_animation(targets, user.atk_animation_id1, false)
      show_normal_animation(targets, user.atk_animation_id2, true)
    else
      show_normal_animation(targets, user.atk_animation_id, false)
    end
  end
    
  def command_auto  ## Creates auto commands on actor selection.
    while BattleManager.next_command
      BattleManager.actor.make_auto_battle_actions
    end
    turn_start
  end
  
  def command_rush  ## Makes all party members auto attack.
    while BattleManager.next_command
      BattleManager.actor.input.set_attack
      BattleManager.actor.input.target_index = 0
      next if BattleManager.actor.input.item.for_opponent?
      BattleManager.actor.input.evaluate_item
    end
    turn_start
  end
  
  def command_block  ## Makes all party members block.
    while BattleManager.next_command
      BattleManager.actor.input.set_guard
    end
    turn_start
  end
  
  alias cp_bv2_turn_start turn_start
  def turn_start  ## Motion of several modified windows.
    @help_window.close if CP::BATTLERS::SHOW_HELP_WINDOW
    if CP::BATTLERS.style5
      @status_window.openness = 0
      @actor_command_window.openness = 0
      @party_command_window.openness = 0
      @log_window2.openness = 255
      $game_message.background = 2
    end
    return cp_bv2_turn_start if CP::BATTLERS.classic
    @actor_command_window.openness = 0 if !@actor_command_window.visible
    cp_bv2_turn_start
  end
  
  def start_actor_command_selection
    @status_window.select(BattleManager.actor.index)
    @party_command_window.close unless CP::BATTLERS.style5
    @actor_command_window.setup(BattleManager.actor)
    @help_window.open if CP::BATTLERS::SHOW_HELP_WINDOW
    return if CP::BATTLERS.classic
    th = @status_window.height + @actor_command_window.height
    @actor_command_window.y = Graphics.height - th
    slo = Graphics.width / $game_party.max_battle_members
    pos = (slo * BattleManager.actor.index) + slo / 2
    @actor_command_window.x = pos - @actor_command_window.width / 2
    @actor_command_window.x = 0 if @actor_command_window.x < 0
    grmw = Graphics.width - @actor_command_window.width
    @actor_command_window.x = grmw if @actor_command_window.x > grmw
  end
  
  def start_party_command_selection
    @help_window.close if CP::BATTLERS::SHOW_HELP_WINDOW
    unless scene_changing?
      if CP::BATTLERS.style5
        @info_viewport.ox = 0 if @info_viewport.ox == 64
        @actor_command_window.openness = 255
        @party_command_window.openness = 255
        @status_window.openness = 255
        @log_window2.openness = 0
      end
      refresh_status
      @status_window.unselect
      @status_window.open
      if BattleManager.input_start
        @actor_command_window.close unless CP::BATTLERS.style5
        @party_command_window.setup
      else
        @party_command_window.deactivate
        turn_start
      end
    end
  end
  
  alias cp_bv2_up_info_view update_info_viewport
  def update_info_viewport  ## Ignores viewport movement in some styles.
    return cp_bv2_up_info_view unless CP::BATTLERS.dated
  end
  
  def process_action
    return if scene_changing?
    if !@subject || !@subject.current_action
      @subject = BattleManager.next_subject
    end
    return turn_end unless @subject
    if @subject.current_action
      @subject.current_action.prepare
      if @subject.current_action.valid?
        @status_window.open unless CP::BATTLERS.style5  ## Only added this.
        execute_action
      end
      @subject.remove_current_action
    end
    process_action_end unless @subject.current_action
  end
  
  def execute_action  ## Creates the casting animations.
    if @subject.current_action.item.swap_party.nil?
      @log_window.display_use_item(@subject, @subject.current_action.item)
      item = @subject.current_action.item
      sid = nil
      sid = :item if item.is_a?(RPG::Item)
      sid = item.stype_id if item.is_a?(RPG::Skill)
      cst = item.is_a?(RPG::UsableItem) ? item.cast_anim : 0
      perform_casting_use(sid, cst)
    end
    @log_window.clear
    use_item
    @log_window.wait_and_clear
  end
  
  def perform_casting_use(type = nil, cast = 0)
    if type.nil?  ## Finds and performs the proper casting animations.
      @subject.sprite_effect_type = :whiten
      abs_wait_short
    elsif cast > 0
      @subject.animation_id = cast
      wait_for_animation
    elsif type == :item && !CP::BATTLERS::ITEM_ANIM.nil?
      @subject.animation_id = CP::BATTLERS::ITEM_ANIM
      wait_for_animation
    elsif type.is_a?(Integer) && CP::BATTLERS::CAST_ANIMS.include?(type)
      @subject.animation_id = CP::BATTLERS::CAST_ANIMS[type]
      wait_for_animation
    else
      @subject.sprite_effect_type = :whiten
      abs_wait_short
    end
  end
  
  def invoke_counter_attack(target, item)  ## Modified counter.
    @log_window.display_counter(target, item)
    attack_skill = $data_skills[target.attack_skill_id]
    if attack_skill.for_opponent?  ## Gets the attack's target.
      tgs = [@subject] * [attack_skill.number_of_targets, 1].max
    else
      tgs = [target] * [attack_skill.number_of_targets, 1].max
    end
    if attack_skill.animation_id < 0  ## Shows the attack anim.
      show_attack_animation(tgs, target)
    else
      show_normal_animation(tgs, attack_skill.animation_id)
    end  ## Performs the counter attack.
    tgs.each {|t| attack_skill.repeats.times {do_counter(target, attack_skill)}}
  end
  
  alias cp_basic_check_substitute check_substitute
  def check_substitute(target, item)  ## Prevents covering friendly attacks.
    return false if @subject.enemy? and target.enemy?
    return cp_basic_check_substitute(target, item)
  end
  
  def do_counter(user, item)  ## Modified counter to properly use party skills.
    target = item.for_opponent? ? @subject : user
    target.item_apply(user, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  
  alias cp_bv2_turn_end turn_end
  def turn_end  ## Process party switch cooldown.
    @already_party = false
    temp = []
    $data_skills.each do |a|
      next if a.nil?
      next if a.swap_party.nil?
      temp.push(a)
    end
    $data_skills -= temp
    cp_bv2_turn_end
  end
  
  def switch?  ## Check if the party has already been switched.
    @already_party = false if @already_party.nil?
    return !@already_party
  end
  
  alias cp_bv2_use_item use_item
  def use_item  ## Process an actor set switch.
    item = @subject.current_action.item
    if !item.swap_party.nil? && item.swap_party > 0
      user_swap_party
    else
      cp_bv2_use_item
    end
  end
  
  unless method_defined?(:user_swap_party)
    def user_swap_party  ## Perform the basic switch.
      item = @subject.current_action.item
      text = CP::BATTLERS::SWITCH_LOG.gsub(/<user>/i, @subject.name)
      text.gsub!(/<target>/i, $game_party.all_members[item.swap_party].name)
      text.gsub!(/<skill>/i, CP::BATTLERS::SWITCH_NAME)
      @log_window.add_text(text)
      i = $game_party.all_members.index(@subject)
      n = item.swap_party
      $game_party.swap_order(i, n)
      @status_window.refresh
      @spriteset.dispose_actors
      @spriteset.create_actors
    end
  end
end

class Game_Action  ## Adds a switch skill and who to switch with.
  def set_swap_party(id = 0)
    if id > 0
      $data_skills.push(RPG::Skill.new)
      $data_skills[-1].swap_party = id
      $data_skills[-1].speed += CP::BATTLERS::SWITCH_SPEED
      $data_skills[-1].id = $data_skills.size - 1
      @item.object = $data_skills[-1]
    else
      @item.object = $data_skills[1]
    end
    self
  end
end

class Animation_Class
  attr_accessor :animation
  attr_accessor :ani_duration
  attr_accessor :ani_mirror
  attr_accessor :ani_rate
  attr_accessor :ani_bitmap1
  attr_accessor :ani_bitmap2
  attr_accessor :ani_sprites
  attr_accessor :ani_duplicated
  attr_accessor :ani_ox
  attr_accessor :ani_oy
end

class Sprite_Base < Sprite
  @@ani_checker_frame = 0
  
  alias cp_bv2_spb_init initialize
  def initialize(*args)
    @ani_array = []  ## Adds an animation array.
    cp_bv2_spb_init(*args)
  end
  
  def dispose
    super  ## Dispose each element of the array.
    @ani_array.each {|ani| dispose_animation(ani)}
  end
  
  def update
    super  ## FIX THE LEGACY BUG!
    update_animation
    @@ani_checker.clear unless @@ani_checker_frame == Graphics.frame_count
    @@ani_spr_checker.clear unless @@ani_checker_frame == Graphics.frame_count
    @@ani_checker_frame = Graphics.frame_count
  end
  
  def animation?  ## Checks if the animation array is empty.
    !@ani_array.empty?
  end
  
  def start_animation(animation, mirror = false)
    if animation  ## Adds a new animation to the array.
      @ani_array.push(Animation_Class.new)
      ani = @ani_array[-1]
      ani.animation = animation
      ani.ani_mirror = mirror
      set_animation_rate(-1)
      ani.ani_duration = ani.animation.frame_max * ani.ani_rate + 1
      load_animation_bitmap(ani)
      make_animation_sprites(ani)
      set_animation_origin(ani)
    end
  end
  
  def set_animation_rate(i = -1)  ## Sets the rate to make anims flow better.
    @ani_array[i].ani_rate = CP::BATTLERS::ANIM_RATE
  end
  
  def load_animation_bitmap(ani = nil)
    return unless ani  ## Loads an animation into the array.
    animation1_name = ani.animation.animation1_name
    animation1_hue = ani.animation.animation1_hue
    animation2_name = ani.animation.animation2_name
    animation2_hue = ani.animation.animation2_hue
    ani.ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    ani.ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(ani.ani_bitmap1)
      @@_reference_count[ani.ani_bitmap1] += 1
    else
      @@_reference_count[ani.ani_bitmap1] = 1
    end
    if @@_reference_count.include?(ani.ani_bitmap2)
      @@_reference_count[ani.ani_bitmap2] += 1
    else
      @@_reference_count[ani.ani_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  
  def make_animation_sprites(ani = nil)
    return unless ani  ## Makes the sprites for the array.
    ani.ani_sprites = []
    if @use_sprite && !@@ani_spr_checker.include?(ani.animation)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        ani.ani_sprites.push(sprite)
      end
      if ani.animation.position == 3
        @@ani_spr_checker.push(ani.animation)
      end
    end
    ani.ani_duplicated = @@ani_checker.include?(ani.animation)
    if !ani.ani_duplicated && ani.animation.position == 3
      @@ani_checker.push(ani.animation)
    end
  end
  
  def set_animation_origin(ani = nil)
    return unless ani  ## Sets the origin... for the array.
    if ani.animation.position == 3
      if viewport == nil
        ani.ani_ox = Graphics.width / 2
        ani.ani_oy = Graphics.height / 2
      else
        ani.ani_ox = viewport.rect.width / 2
        ani.ani_oy = viewport.rect.height / 2
      end
    else
      ani.ani_ox = x - ox + width / 2
      ani.ani_oy = y - oy + height / 2
      if ani.animation.position == 0
        ani.ani_oy -= height / 2
      elsif ani.animation.position == 2
        ani.ani_oy += height / 2
      end
    end
  end
  
  def dispose_animation(ani = nil)
    return unless ani  ## Need I say it?
    if ani.ani_bitmap1
      @@_reference_count[ani.ani_bitmap1] -= 1
      if @@_reference_count[ani.ani_bitmap1] == 0
        @@_reference_count.delete(ani.ani_bitmap1)
        ani.ani_bitmap1.dispose
      end
    end
    if ani.ani_bitmap2
      @@_reference_count[ani.ani_bitmap2] -= 1
      if @@_reference_count[ani.ani_bitmap2] == 0
        @@_reference_count.delete(ani.ani_bitmap2)
        ani.ani_bitmap2.dispose
      end
    end
    if ani.ani_sprites
      ani.ani_sprites.each {|sprite| sprite.dispose }
    end  ## Deletes the position in the array.
    @ani_array.delete_at(@ani_array.index(ani))
  end
  
  def update_animation  ## Updates each animation in the array.
    return unless animation?
    @ani_array.each do |ani|
      ani.ani_duration -= 1
      if ani.ani_duration % ani.ani_rate == 0
        if ani.ani_duration > 0
          frame_index = ani.animation.frame_max
          frame_index -= (ani.ani_duration + ani.ani_rate - 1) / ani.ani_rate
          animation_set_sprites(ani.animation.frames[frame_index], ani)
          ani.animation.timings.each do |timing|
            animation_process_timing(timing, ani) if timing.frame == frame_index
          end
        else
          end_animation(ani)
        end
      end
    end
  end
  
  def end_animation(ani = nil)
    dispose_animation(ani)  ## I think I took something out of this.
  end
  
  def animation_set_sprites(frame, ani = nil)
    return unless ani
    cell_data = frame.cell_data
    ani.ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? ani.ani_bitmap1 : ani.ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if ani.ani_mirror
        sprite.x = ani.ani_ox - cell_data[i, 1]
        sprite.y = ani.ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = ani.ani_ox + cell_data[i, 1]
        sprite.y = ani.ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end  ## Adjust the animation position.
      ofs = CP::BATTLERS.sideview ? 0 : CP::BATTLERS::ANIM_OFFSET
      sprite.y += ofs if ani.animation.to_screen? && @battler && @battler.actor?
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6]  ## Ignore transparency.
      sprite.blend_type = cell_data[i, 7]
    end
  end
  
  def animation_process_timing(timing, ani = nil)
    return unless ani  ## Made once again for the array.
    timing.se.play unless ani.ani_duplicated
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * ani.ani_rate)
    when 2
      if viewport && !ani.ani_duplicated
        viewport.flash(timing.flash_color, timing.flash_duration * ani.ani_rate)
      end
    when 3
      self.flash(nil, timing.flash_duration * ani.ani_rate)
    end
  end
end

class Sprite_Character < Sprite_Base
  def end_animation(*args)
    super(*args)  ## Ensures sprites work.
    @character.animation_id = 0
  end
  
  def move_animation(dx, dy)
    @ani_array.each do |ani|
      if ani.animation && ani.animation.position != 3
        ani.ani_ox += dx
        ani.ani_oy += dy
        ani.ani_sprites.each do |sprite|
          sprite.x += dx
          sprite.y += dy
        end
      end
    end
  end
end

class Sprite_Battler < Sprite_Base
  attr_accessor :viewport4
  
  def opacity=(i)
    n = @battler.transparent? ? i * 0.62 : i
    super(n)
  end
  
  alias cp_bv2_init_vis init_visibility
  def init_visibility
    self.opacity = 255
    cp_bv2_init_vis
  end
  
  def flying_offset
    return self.oy unless @battler.flying?
    frames = 480
    @flying_add = 2.0 + rand if @flying_add.nil?
    @flying_frame = rand(frames).to_f if @flying_frame.nil?
    @flying_frame += @flying_add
    ra = ((@flying_frame % frames).to_f / frames) * 360
    offset = 6 * Math.sin(ra * Math::PI / 180)
    return (self.height - 3) + offset
  end
  
  alias cp_bv2_sb_init initialize
  def initialize(viewport, battler = nil, use = true)
    @used_sprite = use
    if !use
      return super() if CP::BATTLERS.basic
      return super() if battler.battler_name == "" && !CP::BATTLERS.face
    end
    cp_bv2_sb_init(viewport, battler)
    update
  end
  
  alias cp_bv2_sb_update update
  def update  ## Updates the blinking effect in modes 3/4.
    if $imported["CP_BATTLEVIEW"] && $imported["CP_BATTLEVIEW"] >= 1.2
      @battler.popup.clear if CP::BATTLERS.clear_pop
    end
    #return cp_bv2_sb_update if CP::BATTLERS.sideview
    @c_blinking = 0  if @c_blinking.nil?
    @c_blinking += 1; @c_blinking %= 80
    cp_bv2_sb_update
  end
  
  alias cp_bv2_update_bitmap update_bitmap
  def update_bitmap  ## Modified update to get faces and battlers.
    if @used_sprite && CP::BATTLERS.sideview && @battler.actor?
      update_sideview_bitmap
    elsif @battler.enemy? || CP::BATTLERS.faceless
      self.mirror = @battler.mirrored?
      cp_bv2_update_bitmap
    elsif CP::BATTLERS.style4
      if @battler.face_name != @old_face_name ||
         @battler.face_index != @old_face_index
        temp = Cache.face(@battler.face_name)
        face_index = @battler.face_index
        rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
        new_bitmap = Bitmap.new(96, 96)
        new_bitmap.blt(0, 0, temp, rect)
        self.bitmap = new_bitmap
        @old_face_name = @battler.face_name
        @old_face_index = @battler.face_index
        init_visibility
        self.opacity = 1000
      end
    end
  end
  
  unless method_defined?(:update_sideview_bitmap)
    def update_sideview_bitmap  ## Creates a sideview battler.
      unless @battler.side_battler.empty?
        new_bitmap = Cache.battler(@battler.side_battler, @battler.battler_hue)
        self.mirror = @battler.mirrored?
        if bitmap != new_bitmap
          self.bitmap = new_bitmap
          init_visibility
        end
      else
        if @battler.character_name != @old_char_name ||
           @battler.character_index != @old_char_index
          temp = Cache.character(@battler.character_name)
          sign = @battler.character_name[/^[\!\$]./]
          if sign && sign.include?('$')
            cw = temp.width / 3
            ch = temp.height / 4
          else
            cw = temp.width / 12
            ch = temp.height / 8
          end
          n = @battler.character_index
          src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch + ch, cw, ch)
          new_bitmap = Bitmap.new(cw, ch)
          new_bitmap.blt(0, 0, temp, src_rect)
          self.bitmap = new_bitmap
          @old_char_name = @battler.character_name
          @old_char_index = @battler.character_index
          init_visibility
        end
      end
    end
  end
  
  alias cp_bv2_update_position update_position
  def update_position  ## Updates position on modes 2-4.
    self.oy = flying_offset
    if @battler.enemy?
      cp_bv2_update_position
      self.y += CP::BATTLERS::Y_OFFSET unless CP::BATTLERS.sideview
      return unless CP::BATTLERS::RESIZE_CORRECTION
      self.y += Graphics.height - 416
      self.x += (Graphics.width - 544) / 2
    else
      return sideview_pos if CP::BATTLERS.sideview && @used_sprite
      return move_style_2 if CP::BATTLERS.style2
      i = $game_party.battle_members.index(@battler)
      l = Graphics.width / $game_party.max_battle_members
      self.x = l * i + l / 2
      self.y = Graphics.height - 12
      self.z = 100
      return if CP::BATTLERS.face
      zoom = CP::BATTLERS::ZOOM.to_f / 100
      self.y = Graphics.height + CP::BATTLERS::Y_PLACEMENT
      self.zoom_x = zoom
      self.zoom_y = zoom
    end
  end
  
  unless method_defined?(:sideview_pos)
    def sideview_pos
      i = $game_party.battle_members.index(@battler)
      return unless i
      i += 1
      if CP::BATTLERS::SBS_POS.include?(i)
        self.x = CP::BATTLERS::SBS_POS[i][0]
        self.y = CP::BATTLERS::SBS_POS[i][1]
        self.z = 100
      end
    end
  end
  
  def move_style_2  ## Places blank battlers during mode 2.
    return if @battler.screen_x_pos_bv2.nil?
    return if @battler.screen_y_pos_bv2.nil?
    self.x = @battler.screen_x_pos_bv2
    self.y = @battler.screen_y_pos_bv2
    self.z = 100
  end
  
  unless $imported["CP_VIEWED"]
    alias cp_bv2_update_effect update_effect
    def update_effect  ## Updates the blinking effect.
      cp_bv2_update_effect
      return if CP::BATTLERS.sideview
      return unless @effect_type.nil?
      if @battler.c_blinking
        update_blinking_effect
      else
        remove_blinking_effect
      end
    end
  end
  
  def update_blinking_effect  ## Actually does what I said above.
    return if CP::BATTLERS.sideview && @used_sprite
    i = @c_blinking > 40 ? 80 - @c_blinking : @c_blinking
    create_backlit if @backlit_s.nil?
    @backlit_s.opacity = i * 2 + 155
    if @battler_visible
      self.color.set(160, 200, 255, 0)
      self.color.set(255, 120, 120, 0) if @battler.enemy?
      self.color.alpha = i * 2
    end
  end
  
  def remove_blinking_effect  ## Stops the blinking effect.
    remove_backlit if @backlit_s
    self.color.set(255, 255, 255, 0)
  end
  
  def create_backlit  ## Creates the backlit sprite.
    @backlit_s = ::Sprite.new(viewport)
    return unless CP::BATTLERS.dated
    return unless width > 0 && height > 0
    @backlit_s.x = x
    @backlit_s.y = y - 10
    @backlit_s.z = z
    @backlit_s.ox = ox
    @backlit_s.oy = oy
    @backlit_s.zoom_x = zoom_x
    @backlit_s.zoom_y = zoom_y
    @backlit_s.opacity = opacity
    @backlit_s.bitmap = Bitmap.new(width, height)
    @backlit_s.bitmap.blt(0, 0, bitmap, src_rect)
    @backlit_s.color.set(255, 255, 200, 255)
    @backlit_s.color.set(255, 160, 160, 255) if @battler.enemy?
  end
  
  def remove_backlit  ## Removes above sprite.
    @backlit_s.dispose
    @backlit_s = nil
  end
end

class Spriteset_Battle
  alias cp_new_viewports create_viewports
  def create_viewports
    cp_new_viewports  ## Adds a new actor viewport.
    @viewport4 = Viewport.new
    @viewport4.z = 25
    @viewport4.visible = false if CP::BATTLERS.style4
  end
  
  alias cp_update_viewports_bv2 update_viewports
  def update_viewports  ## Updates the new viewport.
    cp_update_viewports_bv2
    @viewport4.tone.set($game_troop.screen.tone)
    @viewport4.ox = $game_troop.screen.shake if CP::BATTLERS.style3
    @viewport4.update
    update_info_viewport if @info_viewport
  end
  
  def update_info_viewport  ## Changes the actor viewport during mode 3.
    @viewport4.rect.width = @info_viewport.rect.width
    @viewport4.rect.height = @info_viewport.rect.y + @info_viewport.rect.height
    @viewport4.visible = @window_status.open?
  end
  
  alias cp_dispose_viewports_bv2 dispose_viewports
  def dispose_viewports  ## Disposes the viewport.
    cp_dispose_viewports_bv2
    @viewport4.dispose
  end
  
  def create_enemies  ## Tells enemy sprites where viewport 4 is.
    @enemy_sprites = $game_troop.members.reverse.collect do |enemy|
      Sprite_Battler.new(@viewport1, enemy)
    end
    @enemy_sprites.each {|sprite| sprite.viewport4 = @viewport4}
  end
  
  def create_actors  ## Creates the actor sprites.
    @extra_sprites = []
    @actor_sprites = $game_party.battle_members.collect do |actor|
      create_viewed_battler(actor)
    end
    @actor_sprites.each {|sprite| sprite.viewport4 = @viewport4}
  end
  
  def create_viewed_battler(actor)
    basic_sprite = Sprite_Battler.new(@viewport4, actor, !CP::BATTLERS.sideview)
    return basic_sprite unless CP::BATTLERS.sideview
    if $imported["CP_VIEWED"]  ## Bookmarked.
      side_sprite = cp_viewed_battler_create ## Used for the later sideview mod.
    else
      side_sprite = Sprite_Battler.new(@viewport1, actor)
    end
    @extra_sprites.push(basic_sprite) if @extra_sprites
    return side_sprite
  end
  
  alias cp_bv2_dispose_act dispose_actors
  def dispose_actors
    cp_bv2_dispose_act
    @extra_sprites.each {|sprite| sprite.dispose }
  end
  
  def info(viewport, status)  ## Gets the battle viewports.
    @info_viewport = viewport
    @window_status = status
  end
end

class RPG::BaseItem
  def battler_name
    set_b_name if @battler_name.nil?
    return @battler_name
  end
  
  def side_battler
    set_b_name if @side_battler.nil?
    return @side_battler
  end
  
  def hide_hp?
    set_b_name if @hide_hp.nil?
    return @hide_hp
  end
  
  def hide_mp?
    set_b_name if @hide_mp.nil?
    return @hide_mp
  end
  
  def hide_tp?
    set_b_name if @hide_tp.nil?
    return @hide_tp
  end
  
  def sattack_id
    set_b_name if @sattack_id.nil?
    return @sattack_id
  end
  
  def sdefend_id
    set_b_name if @sdefend_id.nil?
    return @sdefend_id
  end
  
  def commands
    create_comms if @commands.nil?
    return @commands
  end
  
  def motion_flying
    set_b_name if @motion_flying.nil?
    return @motion_flying
  end
  
  def motion_trans
    set_b_name if @motion_trans.nil?
    return @motion_trans
  end
  
  def motion_mirror
    set_b_name if @motion_mirror.nil?
    return @motion_mirror
  end
  
  def set_b_name
    @battler_name = "" unless @battler_name
    @side_battler = ""
    @hide_hp = false; @hide_mp = false; @hide_tp = false
    @sattack_id = 0
    @sdefend_id = 0
    @motion_flying = false; @motion_trans = false; @motion_mirror = false
    note.split(/[\r\n]+/).each do |line|
      case line
      when CP::BATTLERS::SIDE
        @side_battler = $1.to_s
      when CP::BATTLERS::NAME
        @battler_name = $1.to_s
      when CP::BATTLERS::HIDE_V
        case $1.to_sym.downcase
        when :hp
          @hide_hp = true
        when :mp
          @hide_mp = true
        when :tp
          @hide_tp = true
        end
      when CP::BATTLERS::ATK_ID
        @sattack_id = $1.to_i
      when CP::BATTLERS::DEF_ID
        @sdefend_id = $1.to_i
      when CP::BATTLERS::TRANS
        @motion_trans = true
      when CP::BATTLERS::FLY
        @motion_flying = true
      when CP::BATTLERS::MIRROR
        @motion_mirror = true
      end
    end
  end
  
  def create_comms
    @commands = []
    in_comm = false
    note.split(/[\r\n]+/).each do |line|
      case line
      when CP::BATTLERS::COPEN
        in_comm = true
      when CP::BATTLERS::CCLOSE
        in_comm = false
        break
      when CP::BATTLERS::SCOMM
        next unless in_comm
        @commands.push($1.to_sym)
      when CP::BATTLERS::NCOMM
        next unless in_comm
        @commands.push([$1.to_s, $2.to_i])
      end
    end
  end
end

class RPG::Enemy < RPG::BaseItem
  def nattack_id
    set_a_id if @nattack_id.nil?
    return @nattack_id
  end
  
  def sattack_id
    set_a_id if @sattack_id.nil?
    return @sattack_id
  end
  
  def sdefend_id
    set_a_id if @sdefend_id.nil?
    return @sdefend_id
  end
  
  def set_a_id
    @nattack_id = 0
    @sattack_id = 1
    @sdefend_id = 2
    note.split(/[\r\n]+/).each do |line|
      case line
      when CP::BATTLERS::ATTACK
        @nattack_id = $1.to_i
      when CP::BATTLERS::ATK_ID
        @sattack_id = $1.to_i
      when CP::BATTLERS::DEF_ID
        @sdefend_id = $1.to_i
      end
    end
  end
end

class RPG::UsableItem < RPG::BaseItem
  attr_accessor :swap_party
  
  def cast_anim
    set_cast_anim if @cast_anim.nil?
    return @cast_anim
  end
  
  def set_cast_anim
    @cast_anim = 0
    note.split(/[\r\n]+/).each do |line|
      case line
      when CP::BATTLERS::CAST
        @cast_anim = $1.to_i
      end
    end
  end
end

class RPG::Weapon < RPG::EquipItem
  def attack_skill
    set_weapon_attack_skill if @attack_skill.nil?
    return @attack_skill
  end
  
  def set_weapon_attack_skill
    @attack_skill = 0
    note.split(/[\r\n]+/).each do |line|
      case line
      when CP::BATTLERS::ATK_ID
        @attack_skill = $1.to_i
      end
    end
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###