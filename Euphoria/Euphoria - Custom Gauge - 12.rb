#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                             *Custom Gauge*
#│                              Version: 1.1
#│                            Author: Euphoria
#│                            Date: 5/16/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script overwrites the methods: draw_actor_simple_status
#│                                                 draw_guage_area_without_tp
#│                                                 draw_skill_cost
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.1) Added more battle effects and ability to display gauge on map                          
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: Create you're own gauge! In the editable region you can name 
#│                the gauge, set it's max value, current value, colors, etc. To 
#│                add to the gauge outside of battle you can use the call:
#│
#│                $game_actors[x].add_gauge(y)
#│                                           x = actor number, y = amount to add
#│
#│                Alternately you can subtract with the script call:
#│
#│                $game_actors[x].sub_gauge(y)
#│                                           x = actor number, y = amount to sub
#│
#│                To use the values in conditional branches you may check the
#│                value by typing in these:
#│
#│                $game_actors[x].gauge == y  
#│                $game_actors[x].gauge <= y
#│                $game_actors[x].gauge >= y
#│                                            x = actor, y = amount to check for
#│
#│                If you wish to use the gauge in battle TP MUST BE DISABLED and
#│                you can set skills to use up your gauges value by note tagging 
#│                a skill with:
#│
#│                <Gauge Cost: x>               x = amount of gauge for skill
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaCustomGauge"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Custom_Gauge
    
    GAUGE_NAME      = "Name"     #Set The Gauges Name (5 Characters MAX)
    
    GAUGE_START     = 0          #Set The Amount The Gauge Starts At
    
    GAUGE_MAX       = 100        #Set The Gauges Max Value
    
    GAUGE_COLOR1    = 7          #Set The Gauges Left Side Color (1-32)
    
    GAUGE_COLOR2    = 7          #Set The Gauges Right Side Color (1-32)
   
    COST_COLOR      = 7          #Set The Battle Cost Number Color (1-32)
    
    GAUGE_ON_MAP    = true       #Show Gauge On Map? True of False
    
    GAUGE_MAP_X     = 0          #Set Gauges X Coordinate On Map
    
    GAUGE_MAP_Y     = 0          #Set Gauges Y Coordinate On Map
    
    GAUGE_SWITCH    = 1          #Switch To Turn Gauge Off/On In Map
    
    GAUGE_IN_BATTLE = true       #Show Gauge In Battle? True or False
    
    AT_LEVEL_UP     = 0          #Amount Gained/Lost On Level Up
    
    AT_DEATH        = 0          #Amount Gained/Lost When Death Occurs
    
    AT_REVIVAL      = 0          #Amount Gained/Lost When Revived From Death
    
    AT_STATE_ADD    = 0          #Amount Gained/Lost When State Added
    
    AT_STATE_TAKE   = 0          #Amount Gained/Lost When State Removed
    
    AT_DEAL_DAMAGE  = 0          #Amount Gained/Lost When Dealing Damage
    
    AT_TAKE_DAMAGE  = 0          #Amount Gained/Lost When Taking Damage
    
    AT_HEAL_TARGET  = 0          #Amount Gained/Lost When Healing Target
    
    AT_KILL         = 0          #Amount Gained/Lost When Killing Target
    
  end
  module REGEX
    
    REGEX = /<Gauge[-_ ]?Cost:[-_ ]?(\d+)>/i #DO NOT TOUCH
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ Load Notetags
#└──────────────────────────────────────────────────────────────────────────────
module DataManager
  class << self; alias euphoria_customgauge_datamanager_loaddatabase_12 load_database; end

  def self.load_database
    euphoria_customgauge_datamanager_loaddatabase_12
    load_gauge_notetags
  end
 
  def self.load_gauge_notetags
    groups = [$data_skills]
    for group in groups
      for obj in group
        next if obj.nil?
      obj.load_gauge_notetags
      end
    end
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Set Notetags
#└──────────────────────────────────────────────────────────────────────────────
class RPG::Skill < RPG::UsableItem
  attr_accessor :gauge_cost
  attr_accessor :gauge_cost_text
 
  def load_gauge_notetags
    @gauge_cost = 0
    self.note.scan(Euphoria::REGEX::REGEX)
    @gauge_cost = $1.to_i
    @gauge_cost_text = $1.to_s
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Find and Subtract Skill Cost
#└──────────────────────────────────────────────────────────────────────────────
class Game_BattlerBase
  attr_accessor :gauge
 
  alias euphoria_customgauge_gamebattlerbase_initialize_12 initialize
  def initialize
    @gauge = Euphoria::Custom_Gauge::GAUGE_START
    euphoria_customgauge_gamebattlerbase_initialize_12
  end

  alias euphoria_customgauge_gamebattlerbase_skillcostpayable_12 skill_cost_payable?
  def skill_cost_payable?(skill)
    return false if @gauge < custom_gauge_cost(skill) unless custom_gauge_cost(skill) <= 0
    euphoria_customgauge_gamebattlerbase_skillcostpayable_12(skill)
  end
 
  def custom_gauge_cost(skill)
    skill.gauge_cost
  end

  alias euphoria_customgauge_gamebattlerbase_payskillcost_12 pay_skill_cost
  def pay_skill_cost(skill)
    euphoria_customgauge_gamebattlerbase_payskillcost_12(skill)
    @gauge -= custom_gauge_cost(skill)
  end
 
  def gauge
    gauge = @gauge
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Draw Skill Costs
#└──────────────────────────────────────────────────────────────────────────────
class Window_SkillList < Window_Selectable
 
  def draw_skill_cost(rect, skill)
    draw_gauge_skill_cost(rect, skill)
    draw_mp_skill_cost(rect, skill)
  end  
 
  def draw_mp_skill_cost(rect, skill)
    return unless @actor.skill_mp_cost(skill) > 0
    change_color(mp_cost_color, enable?(skill))
    contents.font.size = 20
    cost = @actor.skill_mp_cost(skill)
    text = skill.mp_cost.to_s
    draw_text(rect, text, 2)
    cx = text_size(text).width + 4
    rect.width -= cx
    reset_font_settings
  end

  def draw_gauge_skill_cost(rect, skill)
    return unless @actor.custom_gauge_cost(skill) > 0
    change_color(text_color(Euphoria::Custom_Gauge::COST_COLOR), enable?(skill))
    contents.font.size = 20
    cost = @actor.custom_gauge_cost(skill)
    text = skill.gauge_cost_text
    draw_text(rect, text, 2)
    cx = text_size(text).width + 4
    rect.width -= cx
    reset_font_settings
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Draw Menu Gauge
#└──────────────────────────────────────────────────────────────────────────────
class Window_Base < Window
 
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_class(actor, x, y + line_height * 2)
    draw_actor_hp(actor, x + 120, y)
    draw_actor_mp(actor, x + 120, y + line_height * 1)
    draw_actor_gauge(actor, x + 120, y + line_height * 2)
  end
 
  def draw_actor_gauge(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.gauge / Euphoria::Custom_Gauge::GAUGE_MAX.to_f, text_color(Euphoria::Custom_Gauge::GAUGE_COLOR1), text_color(Euphoria::Custom_Gauge::GAUGE_COLOR2))
    change_color(system_color)
    draw_text(x, y, 30, line_height, Euphoria::Custom_Gauge::GAUGE_NAME)
    draw_current_and_max_values(x, y, width, actor.gauge, Euphoria::Custom_Gauge::GAUGE_MAX, text_color(0), text_color(0))
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Set Gauge Functions
#└──────────────────────────────────────────────────────────────────────────────  
class Game_Actor < Game_Battler
  
  def add_gauge(plus_value)
    self.gauge += plus_value unless self.gauge == Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  def sub_gauge(minus_value)
    self.gauge -= minus_value unless self.gauge == 0
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  alias euphoria_customgauge_gameactor_levelup_12 level_up
  def level_up
    euphoria_customgauge_gameactor_levelup_12
    self.gauge += Euphoria::Custom_Gauge::AT_LEVEL_UP
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Set Gauge To Move
#└──────────────────────────────────────────────────────────────────────────────
class Game_Battler < Game_BattlerBase
 
  alias euphoria_customgauge_gameactor_die_12 die
  def die
    euphoria_customgauge_gameactor_die_12
    self.gauge += Euphoria::Custom_Gauge::AT_DEATH if $game_party.in_battle
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  alias euphoria_customgauge_gamebattler_revive_12 revive
  def revive
    euphoria_customgauge_gamebattler_revive_12
    self.gauge += Euphoria::Custom_Gauge::AT_REVIVAL if $game_party.in_battle
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  alias euphoria_customgauge_gamebattler_ondamage_12 on_damage
  def on_damage(value)
    euphoria_customgauge_gamebattler_ondamage_12(value)
    self.gauge += Euphoria::Custom_Gauge::AT_TAKE_DAMAGE if $game_party.in_battle
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  alias euphoria_customgauge_gamebattler_addstate_12 add_state
  def add_state(state_id)
    euphoria_customgauge_gamebattler_addstate_12(state_id)
    self.gauge += Euphoria::Custom_Gauge::AT_STATE_ADD if $game_party.in_battle
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
  
  alias euphoria_customgauge_gamebattler_removestate_12 remove_state
  def remove_state(state_id)
    euphoria_customgauge_gamebattler_removestate_12(state_id)
    self.gauge += Euphoria::Custom_Gauge::AT_STATE_TAKE if $game_party.in_battle
    self.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if self.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    self.gauge = 0 if self.gauge < 0
  end
 
  alias euphoria_customgauge_gamebattler_executedamage_12 execute_damage
  def execute_damage(user)
    euphoria_customgauge_gamebattler_executedamage_12(user)
    return unless $game_party.in_battle
    if @result.hp_damage > 0
      user.gauge += Euphoria::Custom_Gauge::AT_DEAL_DAMAGE
      user.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if user.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
      user.gauge = 0 if user.gauge < 0
    elsif @result.hp_damage < 0
      user.gauge += Euphoria::Custom_Gauge::AT_HEAL_TARGET
      user.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if user.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
      user.gauge = 0 if user.gauge < 0
    end
    user.gauge += Euphoria::Custom_Gauge::AT_KILL if self.hp == 0
    user.gauge = Euphoria::Custom_Gauge::GAUGE_MAX if user.gauge > Euphoria::Custom_Gauge::GAUGE_MAX
    user.gauge = 0 if user.gauge < 0
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Draw Gauge In Battle
#└────────────────────────────────────────────────────────────────────────────── 
class Window_BattleStatus < Window_Selectable

  def draw_gauge_area_without_tp(rect, actor)
     if Euphoria::Custom_Gauge::GAUGE_IN_BATTLE == true
     draw_actor_hp(actor, rect.x + 0, rect.y, 72)
     draw_actor_mp(actor, rect.x + 82, rect.y, 64)
     draw_actor_gauge(actor, rect.x + 156, rect.y, 64)
     else
     draw_actor_hp(actor, rect.x + 0, rect.y, 134)
     draw_actor_mp(actor, rect.x + 144,  rect.y, 76)
     end
  end
 
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Create Gauge HUD
#└──────────────────────────────────────────────────────────────────────────────
class Window_EuphoriaHUD < Window_Base
  
  def initialize
    super(0, 0, 544, 414)
    refresh
  end
  
  def refresh
    self.contents.clear
    draw_actor_gauge($game_party.leader, Euphoria::Custom_Gauge::GAUGE_MAP_X, Euphoria::Custom_Gauge::GAUGE_MAP_Y, width = 120)
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Display Gauge HUD
#└──────────────────────────────────────────────────────────────────────────────
class Scene_Map < Scene_Base
  
  alias euphoria_customgauge_scenemap_start_12 start
  def start
    euphoria_customgauge_scenemap_start_12
    create_hud_window
  end
  
  def create_hud_window
    if Euphoria::Custom_Gauge::GAUGE_ON_MAP == true
    @hud = Window_EuphoriaHUD.new
    @hud.opacity = 0
    end
    if $game_switches[Euphoria::Custom_Gauge::GAUGE_SWITCH]
    @hud.visible = false
    else @hud.visible = true
    end
  end
  
  alias euphoria_staminagauge_scenemap_update_S2 update
  def update
    if $game_switches[Euphoria::Custom_Gauge::GAUGE_SWITCH]
    @hud.visible = false
    else @hud.visible = true
    end
    euphoria_staminagauge_scenemap_update_S2
    if Euphoria::Custom_Gauge::GAUGE_ON_MAP == true
    @hud.refresh
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────