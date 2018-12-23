#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                            *Skill Mood Cost*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                             Date: 5/3/2014
#│                        Euphoria337.wordpress.com
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script overwrites the method: draw_skill_cost
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: None
#├──────────────────────────────────────────────────────────────────────────────                      
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                           
#│■ Instructions: You MUST disable TP and you MUST have the Mood Gauge script  
#│                for this to work. To set a skills mood cost insert this tag 
#│                into the skill's notebox:
#│
#│                <mood cost: x>            x = The Amount of Mood to Be Taken
#└──────────────────────────────────────────────────────────────────────────────



#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW 
#└──────────────────────────────────────────────────────────────────────────────
if $imported["EuphoriaMoodGauge"] != true
msgbox_p("Euporia - Mood Gauge REQUIRED")
exit
else
$imported ||= {}
$imported["EuphoriaMoodCost"] = true
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Regular Expression 
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Mood_Cost
    module Regex
      
      MOOD_COST_TAG = /<Mood[-_ ]?Cost:[-_ ]?(\d+)>/i
      
    end
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Load Notetags
#└──────────────────────────────────────────────────────────────────────────────
module DataManager
  class << self; alias euphoria_moodcost_datamanager_loaddatabase_10 load_database; end
  
  def self.load_database
    euphoria_moodcost_datamanager_loaddatabase_10
    load_moodcost_notetags
  end
  
  def self.load_moodcost_notetags
    groups = [$data_skills]
    for group in groups
      for obj in group
        next if obj.nil?
      obj.load_moodcost_notetags
      end
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Get Notetags Value 
#└──────────────────────────────────────────────────────────────────────────────
class RPG::Skill < RPG::UsableItem
  attr_accessor :mood_cost
  attr_accessor :mood_cost_text
  
  def load_moodcost_notetags
    @mood_cost = 0
    self.note.scan(Euphoria::Mood_Cost::Regex::MOOD_COST_TAG)
    @mood_cost = $1.to_i
    @mood_cost_text = $1.to_s
  end
    
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Determine Skill Mood Cost
#└──────────────────────────────────────────────────────────────────────────────    
class Game_BattlerBase
  attr_accessor :mood

  alias euphoria_moodcost_gamebattlerbase_initialize_10 initialize
  def initialize
    @mood = 50
    euphoria_moodcost_gamebattlerbase_initialize_10
  end
  
  alias euphoria_moodcost_gamebattlerbase_skillcostpayable_10 skill_cost_payable?
  def skill_cost_payable?(skill)
    return false if @mood < skill_mood_cost(skill)
    return euphoria_moodcost_gamebattlerbase_skillcostpayable_10(skill)
  end
  
  def skill_mood_cost(skill)
    skill.mood_cost
  end
  
  alias euphoria_moodcost_gamebattlerbase_payskillcost_10 pay_skill_cost
  def pay_skill_cost(skill)
    euphoria_moodcost_gamebattlerbase_payskillcost_10(skill)
    @mood -= skill_mood_cost(skill)
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Change Mood Cost Text Color 
#└──────────────────────────────────────────────────────────────────────────────
class Window_Base < Window
  
  def mood_cost_color
    text_color(28)
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Draw MP and Mood Costs 
#└──────────────────────────────────────────────────────────────────────────────
class Window_SkillList < Window_Selectable
  
  def draw_skill_cost(rect, skill)
    draw_mood_skill_cost(rect, skill)
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

  def draw_mood_skill_cost(rect, skill)
    return unless @actor.skill_mood_cost(skill) > 0
    change_color(mood_cost_color, enable?(skill))
    contents.font.size = 20
    cost = @actor.skill_mood_cost(skill)
    text = skill.mood_cost_text
    draw_text(rect, text, 2)
    cx = text_size(text).width + 4
    rect.width -= cx
    reset_font_settings
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script 
#└──────────────────────────────────────────────────────────────────────────────