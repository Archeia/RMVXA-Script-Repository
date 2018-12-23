#==============================================================================
#    Icon Hues
#    Version: 1.0b
#    Author: modern algebra (rmrk.net)
#    Date: January 10, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to specify a hue for the icons of individual items, 
#   weapons, armors, skills, and states. This way you can use the same icon for
#   various items, only changing the hue. This script also permits you to show
#   icons with shifted hues in any message window.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
# 
#    Place this script above Main and below default scripts in the Script 
#   Editor. Put it above all other custom scripts.
#
#    To specify a hue for an icon, simply put the following in the note field
#   of an item, weapon, armor, skill, or state:
#      
#        \icon_hue[x]
#          x: the hue you want. It can be any integer between 0 and 359.
#
#    EXAMPLES:
#      \icon_hue[65]
#      \icon_hue[320]
#``````````````````````````````````````````````````````````````````````````````
#    Additionally, this script introduces six new message commands that you can
#   use to display a hue-altered icon in any message window.
#
#        \IH[n, x]
#          n: the index of the icon you want to show. The index of an icon must 
#            be an integer and is discernible by looking at the bottom left 
#            corner when selecting icons. 
#          x: the hue you want - it can be any integer between 0 and 359.
#
#    You can also use the following commands:
#        \II[n] - Draws hue-shifted icon of the item with ID n.
#        \IW[n] - Draws hue-shifted icon of the weapon with ID n.
#        \IA[n] - Draws hue-shifted icon of the armor with ID n.
#        \IS[n] - Draws hue-shifted icon of the skill with ID n.
#        \IT[n] - Draws hue-shifted icon of the state with ID n.
#
#    EXAMPLES:
#        \IH[14, 250] - Draws Icon 14 with a hue change of 250.
#        \IW[4] - Draws the hue-shifted icon of the weapon with ID 4.
#        \IT[64] - Draws the hue-shifted icon of the state with ID 64.
#``````````````````````````````````````````````````````````````````````````````
#  Compatibility with: YEA Command Window Icons
#
#    This script also works with Yanfly's YEA Command Window Icons script,
#   found at the following link:
#
#     http://yanflychannel.wordpress.com/rmvxa/menu-scripts/command-window-icons/
#
#    All you need to do is make sure that the Icon Hue script is below the
#   YEA Command Window Script in the Script List (but still above Main). Then, 
#   in the configuration for YEA Command Window Icons, you just need to set the 
#   command as an array in the following format:
#      "Command"      => [n, x],
#        n: the index of the icon you want to show.
#        x: the hue of the icon - it can be any integer between 0 and 359.
#    
#    EXAMPLES:
#      "New Game"      => [224, 65],
#
#    To reiterate, the configuration must be done in the YEA Command Window 
#   Icons Script, not this one. The configuration section of that script starts
#   at line 55. Also note that if you do not want to set the hue, then you do
#   not need to put it in an array; the default configuration will still work.
#==============================================================================

$imported = {} unless $imported
$imported[:MAIcon_Hue] = true

#==============================================================================
# ** RPG::BaseItem
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - icon_hue
#==============================================================================

class RPG::BaseItem
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Icon Hue
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def icon_hue
    if @icon_hue.nil? 
      @icon_hue = self.note[/\\ICON[ _]HUE\[(\d+)\]/i].nil? ? 0 : $1.to_i
    end
    @icon_hue
  end
end

#==============================================================================
# ** Window_Base
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - draw_item_name; draw_actor_icons; draw_icon;
#      convert_escape_character; process_escape_character
#    new method - draw_icon_with_hue
#==============================================================================

class Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item Name
  #     item    : Item (skill, weapon, armor are also possible)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modra_ichue_dritm_8ik2 draw_item_name
  def draw_item_name(item, *args)
    @maih_icon_hue = item.icon_hue if item != nil
    modra_ichue_dritm_8ik2(item, *args) # Run Original Method
    @maih_icon_hue = nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw State
  #    actor : Game_Actor object
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_icnhue_dstat_7uj3 draw_actor_icons
  def draw_actor_icons(actor, *args)
    @maih_icon_hue = []
    for state in actor.states 
      @maih_icon_hue.push (state.icon_hue) if state.icon_index != 0
    end
    # Don't need to do buffs since all the same anyway
    malg_icnhue_dstat_7uj3(actor, *args) # Run Original Method
    @maih_icon_hue = nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modrn_drwicn_hue_6yh1 draw_icon
  def draw_icon(icon_index, x, y, enabled = true, *args)
    hue = @maih_icon_hue.is_a?(Array) ? @maih_icon_hue.shift : @maih_icon_hue
    if !hue || hue == 0
      # Run Original Method
      modrn_drwicn_hue_6yh1(icon_index, x, y, enabled, *args)
    else
      draw_icon_with_hue(icon_index, hue, x, y, enabled)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon With Hue
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_icon_with_hue(icon_index, icon_hue, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    # Draw Icon onto small and independent bitmap
    icon_bmp = Bitmap.new(24, 24) 
    icon_bmp.blt(0, 0, bitmap, rect)
    icon_bmp.hue_change(icon_hue) # Change hue of icon
    rect.x, rect.y = 0, 0
    self.contents.blt(x, y, icon_bmp, rect, enabled ? 255 : translucent_alpha)
    icon_bmp.dispose # Dispose Icon Bitmap
  end
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #  Compatibility with ATS Special Message Codes
  #//////////////////////////////////////////////////////////////////////////
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Convert Escape Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  convesc = $imported[:ATS_SpecialMessageCodes] ? :ma_atssmc_convesc_4rc1 : :convert_escape_characters
  alias_method(:ma_icnhue_convertesc_8ib6, convesc)
  define_method(convesc) do |*args|
    result = ma_icnhue_convertesc_8ib6(*args) # Run Original Method
    result.gsub!(/\eIH\[/i, "\eHI\[") # Change \IH to \HI
    result.gsub!(/\eII\[(\d+)\]/i) { "\eHI\[#{$data_items[$1.to_i].icon_index},#{$data_items[$1.to_i].icon_hue}\]" rescue "" }
    result.gsub!(/\eIW\[(\d+)\]/i) { "\eHI\[#{$data_weapons[$1.to_i].icon_index},#{$data_weapons[$1.to_i].icon_hue}\]" rescue "" }
    result.gsub!(/\eIA\[(\d+)\]/i) { "\eHI\[#{$data_armors[$1.to_i].icon_index},#{$data_armors[$1.to_i].icon_hue}\]" rescue "" }
    result.gsub!(/\eIS\[(\d+)\]/i) { "\eHI\[#{$data_skills[$1.to_i].icon_index},#{$data_skills[$1.to_i].icon_hue}\]" rescue "" }
    result.gsub!(/\eIT\[(\d+)\]/i) { "\eHI\[#{$data_states[$1.to_i].icon_index},#{$data_states[$1.to_i].icon_hue}\]" rescue "" }
    result
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_icnhu_procescchar_5tc1 process_escape_character
  def process_escape_character(code, text, pos, *args, &block)
    if code.upcase == 'HI' # Icon with Hue
      text.slice!(/^\[\s*(\d+)\s*[,:;]?\s*(\d*)\s*\]/)
      @maih_icon_hue = $2.to_i
      process_draw_icon($1.to_i, pos)
      @maih_icon_hue = nil
    else
      malg_icnhu_procescchar_5tc1(code, text, pos, *args, &block) # Run Original Method
    end
  end
end

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#  Compatibility with YEA - Command Window Icons
#//////////////////////////////////////////////////////////////////////////////

if $imported["YEA-CommandWindowIcons"]
  #============================================================================
  # ** Window_Command
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased methods - command_icon; draw_icon_with_text
  #    new method - use_icon_hue?
  #============================================================================

  class Window_Command
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Command Icon
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if self.method_defined?(:command_icon)
      alias ma_ih_cmndicn_6uj7 command_icon
      def command_icon(*args, &block)
        result = ma_ih_cmndicn_6uj7(*args, &block) # Run Original Method
        return result[0] if result.is_a?(Array)
        result
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Draw Icon Text
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if self.method_defined?(:draw_icon_text)
      alias ma_icnh_drwicntext_4rk9 draw_icon_text
      def draw_icon_text(rect, text, *args, &block)
        icn_a = ma_ih_cmndicn_6uj7(text)
        if icn_a.is_a?(Array)
          @maih_icon_hue = icn_a.size > 1 ? icn_a[1] : 0
        end
        result = ma_icnh_drwicntext_4rk9(rect, text, *args, &block) # Run Original Method
        @maih_icon_hue = nil
        result
      end
    end
  end
end

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#  Compatibility with Yanfly's Ace Item Menu 1.02 & Ace Shop Options 1.01
#//////////////////////////////////////////////////////////////////////////////

comp_classes = []
comp_classes.push(Window_ItemStatus) if $imported["YEA-ItemMenu"]
comp_classes.push(Window_ShopData) if  $imported["YEA-ShopOptions"]

unless comp_classes.empty?
#==============================================================================
# *** MAIH_AIMASO_CompPatch
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module changes several methods as they would apply in two of Yanfly's
# scripts.
#==============================================================================

module MAIH_AIMASO_CompPatch
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item Image
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item_image
    colour = Color.new(0, 0, 0, translucent_alpha/2)
    rect = Rect.new(1, 1, 94, 94)
    contents.fill_rect(rect, colour)
    if @item.image.nil?
      icon_index = @item.icon_index
      bitmap = Cache.system("Iconset")
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      icon_bmp = Bitmap.new(24, 24)
      icon_bmp.blt(0, 0, bitmap, rect)
      icon_bmp.hue_change(@item.icon_hue)
      target = Rect.new(0, 0, 96, 96)
      contents.stretch_blt(target, icon_bmp, icon_bmp.rect)
    else
      bitmap = Cache.picture(@item.image)
      contents.blt(0, 0, bitmap, bitmap.rect, 255)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Applies
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_applies(*args, &block)
    @maih_icon_hue = []
    for effect in @item.effects
      if effect.code == Game_Battler::ADD_STATE
        next unless effect.value1 > 0
        next if $data_states[effect.value1].nil?
        @maih_icon_hue << $data_states[effect.data_id].icon_hue
      end
    end
    super(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Removes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_removes(*args, &block)
    @maih_icon_hue = []
    for effect in @item.effects
      if effect.code == Game_Battler::EFFECT_REMOVE_STATE
        next unless effect.value1 > 0
        next if $data_states[effect.value1].nil?
        @maih_icon_hue << $data_states[effect.data_id].icon_hue
      end
    end
    super(*args, &block) # Call Original Method
  end
end 
# include module in selected classes
comp_classes.each { |class_obj| class_obj.send(:include, MAIH_AIMASO_CompPatch) }
end