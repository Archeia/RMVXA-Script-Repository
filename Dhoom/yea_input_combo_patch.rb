#===============================================================================
# Windows Position and Visibility Patch for :
# - Yanfly Engine Ace - Input Combo Skills v1.01
# 
# by DrDhoom
#===============================================================================

#Comment out this part if you didn't want to change the windows position
class Window_ComboSkillList < Window_Base
  alias dhoom_yeaics_wndcmskl_init initialize
  def initialize
    dhoom_yeaics_wndcmskl_init
    self.x = Graphics.width-self.width+standard_padding
  end
end

class Window_ComboInfo < Window_Base
  def initialize
    dw = [Graphics.width/2, 320].max
    super(0, 0, dw, fitting_height(1))
    self.y = Graphics.height - fitting_height(4) - fitting_height(1)
    self.x = Graphics.width-self.width+standard_padding
    self.opacity = 0
    self.z = 200
    @combos = []
    @special = nil
    hide
  end 
end
#===============================================================================

#Comment out this part if you didn't want to hide the windows after combo maxed out
class Scene_Battle < Scene_Base
  alias dhoom_yeaics_scbat_update_basic update_basic
  def update_basic
    dhoom_yeaics_scbat_update_basic
    update_input_combo_windows_visibility
  end
  
  def update_input_combo_windows_visibility
    return unless @input_combo_skill_window.visible
    return unless @total_combo_skills == @current_combo_skill.combo_max
    @input_combo_skill_window.openness = 0
    @input_combo_info_window.openness = 0
  end
  
  alias dhoom_yeaics_scbat_combo_skill_list_appear combo_skill_list_appear
  def combo_skill_list_appear(visible, skill)
    if visible
      @input_combo_skill_window.openness = 255
      @input_combo_info_window.openness = 255
    end
    dhoom_yeaics_scbat_combo_skill_list_appear(visible, skill)
  end
end
#===============================================================================