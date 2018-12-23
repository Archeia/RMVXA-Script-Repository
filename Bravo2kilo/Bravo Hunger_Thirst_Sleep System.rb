#==============================================================================
# Bravo Hunger/Thirst/Sleep System
#------------------------------------------------------------------------------
# Author: Bravo2Kilo
# Version: 1.1
#
# Version History:
#   v1.0 = Initial Release
#   v1.1 = New Features and Bug Fixes
#==============================================================================
# Notes
#   All of the stat decreases stack.
#   For the 3 script calls if actor is 0 it will aplly to all members in the party.
#==============================================================================
# To add or remove hunger from an actor use this script call
#   change_hunger(actor, amount)
#
# To add or remove thirst from an actor use this script call
#   change_thirst(actor, amount)
#
#To add or remove sleep from an actor use this script call
#   change_sleep(actor, amount)
#
# To set a hunger max for each character use this notetag in the actor notebox.
#   <hungermax: x>
#
# To set a thirst max for each character use this notetag in the actor notebox.
#   <thirstmax: x>
#
# To set a sleep max for each character use this notetag in the actor notebox.
#   <sleepmax: x>
#
# To increase or decrease the hunger stat on item or skill usage use this notetag
# in the item or skill notebox.
#   <hunger: x>
#
# To increase or decrease the thirst stat on item or skill usage use this notetag
# in the item or skill notebox.
#   <thirst: x>
#
# To increase or decrease the sleep stat on item or skill usage use this notetag
# in the item or skill notebox.
#   <sleep: x>
#
# To increase or decrease the hunger stat on the user of an item or skill use
# this notetag in the item or skill notebox.
#   <user-hunger: x>
#
# To increase or decrease the thirst stat on the user of an item or skill use
# this notetag in the item or skill notebox.
#   <user-thirst: x>
#
# To increase or decrease the sleep stat on the user of an item or skill use
# this notetag in the item or skill notebox.
#   <user-sleep: x>
#==============================================================================
module BRAVO_HTS
  # The names for the hunger, thirst, and sleep stats
  # Hunger, Thirst, Sleep
  HTS_NAMES = ["Hunger", "Thirst", "Sleep"]
  # If you want to use the hunger, thirst, or sleep system.
  # Hunger, Thirst, Sleep
  HTS_USE = [true, true, true]
  # If the hunger, thirst, or sleep stat reaches max the actor will die.
  # Hunger, Thirst, Sleep
  HTS_DIE_MAX = [true, true, true]
  # Max amount of the hunger, thirst, and sleep stat.
  # Hunger, Thirst, Sleep
  HTS_MAX = [100, 100, 100]
  # Amount to increase the hunger, thirst, and sleep stat per step.
  # Hunger, Thirst, Sleep
  HTS_INCREASE = [1, 1, 1]
  # If hunger, thirst, or sleep stat reaches this, dashing will be disabled.
  # Hunger, Thirst, Sleep
  DISABLE_DASH = [50, 50, 50]
  # Should dash be disabled only if the party leader's hunger/thirst/sleep stats
  # reach a certain point or if anyone in the party hunger/thirst/sleep stat
  # reaches a certain point. values are ":leader" or ":party"
  DIASBLE_DASH_METHOD = :leader
  # Stat decrease for when hunger reaches a certain point.
  HUNGER_STAT_DECREASE = {
  # Percent to Decrease, Amount of hunger to reach to lower stat
    :attack => [20, 50],
    :defense => [20, 50],
    :mattack => [20, 50],
    :mdefense => [20, 50],
    :agility => [20, 50],
  }# Don't Touch This
  # Stat decrease for when thirst reaches a certain point.
  THIRST_STAT_DECREASE = {
  # Percent to Decrease, Amount of thirst to reach to lower stat
    :attack => [20, 50],
    :defense => [20, 50],
    :mattack => [20, 50],
    :mdefense => [20, 50],
    :agility => [20, 50],
  }# Don't Touch This
  # Stat decrease for when sleep deprivation reaches a certain point.
  SLEEP_STAT_DECREASE = {
  # Percent to Decrease, Amount of sleep to reach to lower stat
    :attack => [20, 50],
    :defense => [20, 50],
    :mattack => [20, 50],
    :mdefense => [20, 50],
    :agility => [20, 50],
  }# Don't Touch This
  # If this switch is on the HUD will show.
  HTS_HUD_SWITCH = 1
  # The X position of the HUD that will appear on the map.
  HTS_HUD_X = 0
  # The Y position of the HUD that will appear on the map.
  HTS_HUD_Y = 0
  # The name of the image for the HUD, if you don't want to use an image leave empty.
  HTS_HUD_BACK = ""
  # The opacity of the HUD window.
  HTS_HUD_OPACITY = 255
#==============================================================================
# End of Configuration
#==============================================================================
end
$imported ||= {}
$imported[:Bravo_HTS] = true

#==============================================================================
# ** RPG Actor
#==============================================================================

class RPG::Actor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Hunger Max
  #--------------------------------------------------------------------------
  def hunger_max
    if @note =~ /<hungermax: (.*)>/i
      return $1.to_i
    else
      return BRAVO_HTS::HTS_MAX[0]
    end
  end
  #--------------------------------------------------------------------------
  # * Thirst Max
  #--------------------------------------------------------------------------
  def thirst_max
    if @note =~ /<thirstmax: (.*)>/i
      return $1.to_i
    else
      return BRAVO_HTS::HTS_MAX[1]
    end
  end
  #--------------------------------------------------------------------------
  # * Sleep Max
  #--------------------------------------------------------------------------
  def sleep_max
    if @note =~ /<sleepmax: (.*)>/i
      return $1.to_i
    else
      return BRAVO_HTS::HTS_MAX[2]
    end
  end
end

#==============================================================================
# ** RPG UsableItem
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * User Hunger
  #--------------------------------------------------------------------------
  def user_hunger
    if @note =~ /<user-hunger: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * User Thirst
  #--------------------------------------------------------------------------
  def user_thirst
    if @note =~ /<user-thirst: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * User Sleep
  #--------------------------------------------------------------------------
  def user_sleep
    if @note =~ /<user-sleep: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Hunger
  #--------------------------------------------------------------------------
  def hunger
    if @note =~ /<hunger: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Thirst
  #--------------------------------------------------------------------------
  def thirst
    if @note =~ /<thirst: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Sleep
  #--------------------------------------------------------------------------
  def sleep
    if @note =~ /<sleep: (.*)>/i
      return $1.to_i
    else
      return 0
    end
  end
end

#==============================================================================
# ** Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :hunger
  attr_accessor :hunger_max
  attr_accessor :thirst
  attr_accessor :thirst_max
  attr_accessor :sleep
  attr_accessor :sleep_max
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  alias bravo_hts_setup setup
  def setup(actor_id)
    bravo_hts_setup(actor_id)
    @hunger = 0
    @hunger_max = actor.hunger_max
    @thirst = 0
    @thirst_max = actor.thirst_max
    @sleep = 0
    @sleep_max = actor.sleep_max
  end
  #--------------------------------------------------------------------------
  # * Check Death
  #--------------------------------------------------------------------------
  def check_death
    if @hunger > @hunger_max
      @hunger = @hunger_max
    elsif @hunger < 0
      @hunger = 0
    end
    if @thirst > @thirst_max
      @thirst = @thirst_max
    elsif @thirst < 0
      @thirst = 0
    end
    if @sleep > @sleep_max
      @sleep = @sleep_max
    elsif @sleep < 0
      @sleep = 0
    end
    if @hunger >= @hunger_max && BRAVO_HTS::HTS_DIE_MAX[0] == true
      self.hp = 0
    elsif @thirst >= @thirst_max && BRAVO_HTS::HTS_DIE_MAX[1] == true
      self.hp = 0
    elsif @sleep >= @sleep_max && BRAVO_HTS::HTS_DIE_MAX[2] == true
      self.hp = 0
    end
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
  #--------------------------------------------------------------------------
  # * Use Skill/Item
  #    Called for the acting side and applies the effect to other than the user.
  #--------------------------------------------------------------------------
  def use_item(item)
    super(item)
    @hunger += item.user_hunger if BRAVO_HTS::HTS_USE[0] == true
    @thirst += item.user_thirst if BRAVO_HTS::HTS_USE[1] == true
    @sleep += item.user_sleep if BRAVO_HTS::HTS_USE[2] == true
  end
  #--------------------------------------------------------------------------
  # * Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    super(user, item)
    @hunger += item.hunger if BRAVO_HTS::HTS_USE[0] == true
    @thirst += item.thirst if BRAVO_HTS::HTS_USE[1] == true
    @sleep += item.sleep if BRAVO_HTS::HTS_USE[2] == true
  end
  #--------------------------------------------------------------------------
  # * Get Parameter
  #--------------------------------------------------------------------------
  def param(param_id)
    value = param_base(param_id) + param_plus(param_id)
    value *= param_rate(param_id) * param_buff_rate(param_id)
    case param_id
    when 2 # Attack Parameter
      if @hunger >= BRAVO_HTS::HUNGER_STAT_DECREASE[:attack][1] && BRAVO_HTS::HTS_USE[0] == true
        hunger = value * (BRAVO_HTS::HUNGER_STAT_DECREASE[:attack][0] * 0.01)
        value = value - hunger
      end
      if @thirst >= BRAVO_HTS::THIRST_STAT_DECREASE[:attack][1] && BRAVO_HTS::HTS_USE[1] == true
        thirst = value * (BRAVO_HTS::THIRST_STAT_DECREASE[:attack][0] * 0.01)
        value = value - thirst
      end
      if @sleep >= BRAVO_HTS::SLEEP_STAT_DECREASE[:attack][1] && BRAVO_HTS::HTS_USE[2] == true
        sleep = value * (BRAVO_HTS::SLEEP_STAT_DECREASE[:attack][0] * 0.01)
        value = value - sleep
      end
    when 3 # Defense Parameter
      if @hunger >= BRAVO_HTS::HUNGER_STAT_DECREASE[:defense][1] && BRAVO_HTS::HTS_USE[0] == true
        hunger = value * (BRAVO_HTS::HUNGER_STAT_DECREASE[:defense][0] * 0.01)
        value = value - hunger
      end
      if @thirst >= BRAVO_HTS::THIRST_STAT_DECREASE[:defense][1] && BRAVO_HTS::HTS_USE[1] == true
        thirst = value * (BRAVO_HTS::THIRST_STAT_DECREASE[:defense][0] * 0.01)
        value = value - thirst
      end
      if @sleep >= BRAVO_HTS::SLEEP_STAT_DECREASE[:defense][1] && BRAVO_HTS::HTS_USE[2] == true
        sleep = value * (BRAVO_HTS::SLEEP_STAT_DECREASE[:defense][0] * 0.01)
        value = value - sleep
      end
    when 4 # Magic Attack Parameter
      if @hunger >= BRAVO_HTS::HUNGER_STAT_DECREASE[:mattack][1] && BRAVO_HTS::HTS_USE[0] == true
        hunger = value * (BRAVO_HTS::HUNGER_STAT_DECREASE[:mattack][0] * 0.01)
        value = value - hunger
      end
      if @thirst >= BRAVO_HTS::THIRST_STAT_DECREASE[:mattack][1] && BRAVO_HTS::HTS_USE[1] == true
        thirst = value * (BRAVO_HTS::THIRST_STAT_DECREASE[:mattack][0] * 0.01)
        value = value - thirst
      end
      if @sleep >= BRAVO_HTS::SLEEP_STAT_DECREASE[:mattack][1] && BRAVO_HTS::HTS_USE[2] == true
        sleep = value * (BRAVO_HTS::SLEEP_STAT_DECREASE[:mattack][0] * 0.01)
        value = value - sleep
      end
    when 5 # Magic Defense Parameter
      if @hunger >= BRAVO_HTS::HUNGER_STAT_DECREASE[:mdefense][1] && BRAVO_HTS::HTS_USE[0] == true
        hunger = value * (BRAVO_HTS::HUNGER_STAT_DECREASE[:mdefense][0] * 0.01)
        value = value - hunger
      end
      if @thirst >= BRAVO_HTS::THIRST_STAT_DECREASE[:mdefense][1] && BRAVO_HTS::HTS_USE[1] == true
        thirst = value * (BRAVO_HTS::THIRST_STAT_DECREASE[:mdefense][0] * 0.01)
        value = value - thirst
      end
      if @sleep >= BRAVO_HTS::SLEEP_STAT_DECREASE[:mdefense][1] && BRAVO_HTS::HTS_USE[2] == true
        sleep = value * (BRAVO_HTS::SLEEP_STAT_DECREASE[:mdefense][0] * 0.01)
        value = value - sleep
      end
    when 6 # Agility Parameter
      if @hunger >= BRAVO_HTS::HUNGER_STAT_DECREASE[:agility][1] && BRAVO_HTS::HTS_USE[0] == true
        hunger = value * (BRAVO_HTS::HUNGER_STAT_DECREASE[:agility][0] * 0.01)
        value = value - hunger
      end
      if @thirst >= BRAVO_HTS::THIRST_STAT_DECREASE[:agility][1] && BRAVO_HTS::HTS_USE[1] == true
        thirst = value * (BRAVO_HTS::THIRST_STAT_DECREASE[:agility][0] * 0.01)
        value = value - thirst
      end
      if @sleep >= BRAVO_HTS::SLEEP_STAT_DECREASE[:agility][1] && BRAVO_HTS::HTS_USE[2] == true
        sleep = value * (BRAVO_HTS::SLEEP_STAT_DECREASE[:agility][0] * 0.01)
        value = value - sleep
      end
    end
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  #--------------------------------------------------------------------------
  # * Hunger Rate
  #--------------------------------------------------------------------------
  def hunger_rate
    @hunger.to_f / @hunger_max
  end
  #--------------------------------------------------------------------------
  # * Thirst Rate
  #--------------------------------------------------------------------------
  def thirst_rate
    @thirst.to_f / @thirst_max
  end
  #--------------------------------------------------------------------------
  # * Sleep Rate
  #--------------------------------------------------------------------------
  def sleep_rate
    @sleep.to_f / @sleep_max
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Increase Steps
  #--------------------------------------------------------------------------
  alias bravo_hts_increase_steps increase_steps
  def increase_steps
    bravo_hts_increase_steps
    members.each do |actor|
      actor.hunger += BRAVO_HTS::HTS_INCREASE[0] if BRAVO_HTS::HTS_USE[0] == true
      actor.thirst += BRAVO_HTS::HTS_INCREASE[1] if BRAVO_HTS::HTS_USE[1] == true
      actor.sleep += BRAVO_HTS::HTS_INCREASE[2] if BRAVO_HTS::HTS_USE[2] == true
      actor.check_death
    end
  end
end

#==============================================================================
# ** Game_Player
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  alias bravo_hts_dash? dash?
  def dash?
    if BRAVO_HTS::DIASBLE_DASH_METHOD == :leader
      return false if $game_party.leader.hunger >= BRAVO_HTS::DISABLE_DASH[0]
      return false if $game_party.leader.thirst >= BRAVO_HTS::DISABLE_DASH[1]
      return false if $game_party.leader.sleep >= BRAVO_HTS::DISABLE_DASH[2]
    elsif BRAVO_HTS::DIASBLE_DASH_METHOD == :party
      $game_party.members.each do |actor|
        return false if actor.hunger >= BRAVO_HTS::DISABLE_DASH[0]
        return false if actor.thirst >= BRAVO_HTS::DISABLE_DASH[1]
        return false if actor.sleep >= BRAVO_HTS::DISABLE_DASH[2]
      end
    end
    bravo_hts_dash?
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Change Hunger
  #--------------------------------------------------------------------------
  def change_hunger(actor, amount)
    if actor == 0
      $game_party.members.each do |actor|
        actor.hunger += amount
        actor.check_death
      end
    else
      $game_actors[actor].hunger += amount
      $game_actors[actor].check_death
    end
  end
  #--------------------------------------------------------------------------
  # * Change Thirst
  #--------------------------------------------------------------------------
  def change_thirst(actor, amount)
    if actor == 0
      $game_party.members.each do |actor|
        actor.thirst += amount
        actor.check_death
      end
    else
      $game_actors[actor].thirst += amount
      $game_actors[actor].check_death
    end
  end
  #--------------------------------------------------------------------------
  # * Change Sleep
  #--------------------------------------------------------------------------
  def change_sleep(actor, amount)
    if actor == 0
      $game_party.members.each do |actor|
        actor.sleep += amount
        actor.check_death
      end
    else
      $game_actors[actor].sleep += amount
      $game_actors[actor].check_death
    end
  end
#~   #--------------------------------------------------------------------------
#~   # * Change Sleep
#~   #--------------------------------------------------------------------------
#~   def change_sleep(param1, param2, param3, param4, param5)
#~     value = operate_value(param3, param4, param5)
#~     iterate_actor_var(param1, param2) do |actor|
#~       actor.sleep += value
#~       actor.check_death
#~     end
#~   end
end

#==============================================================================
# ** Window_Base
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw Hunger
  #--------------------------------------------------------------------------
  def draw_actor_hunger(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hunger_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x-17, y, 124, line_height, BRAVO_HTS::HTS_NAMES[0])
    draw_current_and_max_values(x, y, width, actor.hunger, actor.hunger_max,
    normal_color, normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Thirst
  #--------------------------------------------------------------------------
  def draw_actor_thirst(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.thirst_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x-17, y, 124, line_height, BRAVO_HTS::HTS_NAMES[1])
    draw_current_and_max_values(x, y, width, actor.thirst, actor.thirst_max,
    normal_color, normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Sleep
  #--------------------------------------------------------------------------
  def draw_actor_sleep(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.sleep_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x-17, y, 124, line_height, BRAVO_HTS::HTS_NAMES[2])
    draw_current_and_max_values(x, y, width, actor.sleep, actor.sleep_max,
    normal_color, normal_color)
  end
end

#==============================================================================
# ** Window_Status
#==============================================================================

class Window_Status < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :info
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias bravo_hts_initialize initialize
  def initialize(actor)
    bravo_hts_initialize(actor)
    @info = 0
  end
  #--------------------------------------------------------------------------
  # * Draw Block 2
  #--------------------------------------------------------------------------
  def draw_block2(y)
    draw_actor_face(@actor, 8, y)
    draw_basic_info(136, y)
    if @info == 1
      draw_hts_info(304, y)
    else
      draw_exp_info(304, y)
    end
    draw_press_shift(0, y - line_height)
  end
  #--------------------------------------------------------------------------
  # * Draw HTS Information
  #--------------------------------------------------------------------------
  def draw_hts_info(x, y)
    draw_actor_hunger(@actor, x+17, y) if BRAVO_HTS::HTS_USE[0] == true
    if BRAVO_HTS::HTS_USE[0] == false
      draw_actor_thirst(@actor, x+17, y) if BRAVO_HTS::HTS_USE[1] == true
    else
      draw_actor_thirst(@actor, x+17, y+line_height) if BRAVO_HTS::HTS_USE[1] == true
    end
    if BRAVO_HTS::HTS_USE[0] == false || BRAVO_HTS::HTS_USE[1] == false
      draw_actor_sleep(@actor, x+17, y+line_height) if BRAVO_HTS::HTS_USE[2] == true
    else
      draw_actor_sleep(@actor, x+17, y+line_height*2) if BRAVO_HTS::HTS_USE[2] == true
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Press Shift
  #--------------------------------------------------------------------------
  def draw_press_shift(x, y)
    text = "Press SHIFT to view more information."
    draw_text(x, y, 520, line_height, text, 2)
  end
end

#==============================================================================
# ** Window_HTS
#==============================================================================

class Window_HTS < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 165, window_height)
    self.opacity = BRAVO_HTS::HTS_HUD_OPACITY
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_height
    n = 0
    if BRAVO_HTS::HTS_USE[0] == true
      n += 1
    end
    if BRAVO_HTS::HTS_USE[1] == true
      n += 1
    end
    if BRAVO_HTS::HTS_USE[2] == true
      n += 1
    end
    return fitting_height(n)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    actor = $game_party.leader
    draw_actor_hunger(actor, 17, 0) if BRAVO_HTS::HTS_USE[0] == true
    if BRAVO_HTS::HTS_USE[0] == false
      draw_actor_thirst(actor, 17, 0) if BRAVO_HTS::HTS_USE[1] == true
    else
      draw_actor_thirst(actor, 17, line_height) if BRAVO_HTS::HTS_USE[1] == true
    end
    if BRAVO_HTS::HTS_USE[0] == false || BRAVO_HTS::HTS_USE[1] == false
      draw_actor_sleep(actor, 17, line_height) if BRAVO_HTS::HTS_USE[2] == true
    else
      draw_actor_sleep(actor, 17, line_height*2) if BRAVO_HTS::HTS_USE[2] == true
    end
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  alias bravo_hts_terminate terminate
  def terminate
    if BRAVO_HTS::HTS_HUD_BACK != ""
      @hts_view.dispose
    end
    bravo_hts_terminate
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias bravo_hts_update update
  def update
    bravo_hts_update
    if $game_switches[BRAVO_HTS::HTS_HUD_SWITCH] == true
      @hts_window.show
      if BRAVO_HTS::HTS_HUD_BACK != ""
        @hts_hud.visible = true
      end
      @hts_window.refresh
    else
      @hts_window.hide
      if BRAVO_HTS::HTS_HUD_BACK != ""
        @hts_hud.visible = false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Create All Windows
  #--------------------------------------------------------------------------
  alias bravo_hts_create_all_windows create_all_windows
  def create_all_windows
    bravo_hts_create_all_windows
    @hts_window = Window_HTS.new(BRAVO_HTS::HTS_HUD_X, BRAVO_HTS::HTS_HUD_Y)
    @hts_window.hide
    if BRAVO_HTS::HTS_HUD_BACK != ""
      @hts_hud = Sprite.new
      @hts_hud.bitmap = Cache.system(BRAVO_HTS::HTS_HUD_BACK)
      @hts_hud.x = BRAVO_HTS::HTS_HUD_X
      @hts_hud.y = BRAVO_HTS::HTS_HUD_Y
      @hts_hud.visible = false
    end
  end
end

#==============================================================================
# ** Scene_Status
#==============================================================================

class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(:SHIFT)
      if @status_window.info == 0
        @status_window.info = 1
      elsif @status_window.info == 1
        @status_window.info = 0
      end
      @status_window.refresh
    end
  end
end

#==============================================================================
# ** Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Processing at End of Action
  #--------------------------------------------------------------------------
  alias bravo_hts_process_action_end process_action_end
  def process_action_end
    if @subject.is_a?(Game_Actor)
      @subject.check_death
    end
    bravo_hts_process_action_end
  end
end