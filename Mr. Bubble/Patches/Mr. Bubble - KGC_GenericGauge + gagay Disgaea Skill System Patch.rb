#==============================================================================
# KGC_GenericGauge + gagay Disgaea Skill System Patch
# v1.0 (August 28, 2011)
# By Mr. Bubble
#-----------------------------------------------------------------------------
# Installation: The Disgaea Skill System script must be placed ABOVE
#               KGC Generic Gauge in your script editor's Materials
#               section. Then, insert this patch into its own page
#               anywhere below those two scripts in the Materials
#               section.
#-----------------------------------------------------------------------------
#   This patch makes KGC Generic Gauge and gagay's Disgaea Skill System
# compatible with each other. Unfortunately, the DSS script also defines
# a method with the same exact name (Window_Base#draw_gauge) which makes 
# this patch contain a method overwrite.
#   If gagay updates his script and it breaks this patch, let me know.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# ++ Generic Gauge Customization for Disgaea Skill System ++
#-----------------------------------------------------------------------------

module Bubs
module GG_For_DSS
  # > Gauge Settings
  GG_DSS_IMAGE  = "GaugeEXP" # > Gauge file Name in the "Graphics/System" folder
  GG_DSS_OFFSET = [-23, -2]  # > Gauge Position Adjustment [x, y]
  GG_DSS_LENGTH = -4         # > Gauge Length Adjustment
  GG_DSS_SLOPE  = 30         # > Degree of Gauge Slope between -89 ~ 89 degrees

end
end

#==============================================================================
#------------------------------------------------------------------------------
#------- Do not edit below this point unless you know what you're doing -------
#------------------------------------------------------------------------------
#==============================================================================

$imported = {} if $imported == nil

#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  include Bubs::GG_For_DSS
  def draw_skill(skill, x, y, enabled = true)
    if skill != nil
      unless skill.no_level
        if enabled; c1 = text_color(2); c2 = text_color(18); else; c1 = text_color(7); c2 = text_color(8); end
        current = skill.exp
        max = skill.exp_needed
        if $imported["GenericGauge"]
          # draw_gauge(file, x, y, width, value, limit, offset, 
          #            len_offset, slope, gauge_type)
          draw_gauge(GG_DSS_IMAGE, x, y, 170, current, max, GG_DSS_OFFSET, 
                     GG_DSS_LENGTH, GG_DSS_SLOPE, :normal)      
        else
          draw_gauge(current, max, x+2, y-7, 170, c1, c2)
        end
      end
      
      draw_icon(skill.icon_index, x+3, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.size = 15
      self.contents.font.color = text_color(6) 
      self.contents.font.color.alpha = enabled ? 255 : 128
      if skill.no_level
        self.contents.draw_text(x + 130, y+2, 40, WLH, "---", 2)
      else
        self.contents.draw_text(x + 130, y+2, 40, WLH, Vocab.level_a+skill.level.to_s, 2) unless skill.level == skill.max_level
      end
      
      if skill.level == skill.max_level
        case GBP::DISGAEA_SKILL::MASTERSKILL_DISPLAY_METHOD
        when 1 #normal
          self.contents.draw_text(x + 130, y+2, 40, WLH, Vocab.level_a+skill.level.to_s, 2)
        when 2 #icon display
          draw_icon(GBP::DISGAEA_SKILL::MASTERSKILL_ICON, x+150, y-1, enabled)
        when 3 #special text
          self.contents.draw_text(x + 130, y+2, 40, WLH, GBP::DISGAEA_SKILL::MASTERSKILL_TEXT, 2)
        end #case
      end
      
      self.contents.font.color = text_color(skill.skill_color)
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 27, y+2, 110, WLH, skill.name)
      self.contents.font.size = Font.default_size
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = 255
    end
  end
end