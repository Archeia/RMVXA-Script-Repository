#==============================================================================
#    Hover Alerts
#    Version: 1.0.3
#    Author: modern algebra (rmrk.net)
#    Date: 4 November 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script lets you display a graphic which hovers above any given event, 
#   player or follower. The primary virtue of the script is that it allows for
#   a feature like in Diablo, where characters that have something important to
#   say have an exclamation point or something above their heads. However, it 
#   is not limited to that: this script can show any picture, icon, text, or
#   combination of icon & text above any character. 
#
#    A secondary (and completely optional) feature is that you can set it up so
#   that whenever gold, items, weapons, or armours are received through their
#   respective event commands, a hover alert will float above the player's head
#   with the icon, name, and amount of the item received before fading out.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    I decided to try something new with this script, so this script operates
#   through event comment commands. When the comment is the very first comment
#   on an event's page, then the hover graphic set through that comment will 
#   automatically be generated as soon as that event page's conditions are met.
#   If it is not, then it will only be run when that event is active and the 
#   Interpreter reaches it. 
#
#    The basic format for setting a hover graphic above the event in which the
#   comment occurs is as follows, with any of the options between the curly
#   brackets omitted if you are satisfied with the default setting:
#
#      \hover_alert { name = ""; icon = 0; icon_hue = 0; time = -1;
#        fontname = "Default"; fontsize = 20; colour = 0; bold = false;
#        italic = false; effect = :none; effect_param = nil; se = nil;
#        proximity = 0 }
#
#   When setting any of the options, make sure it is concluded with either a 
#   semicolon or simply a new line. Each of the options is explained below, but
#   I reiterate that you can exclude almost any of them if you are satisfied 
#   with the default value listed above:
#
#      name - This is a string, and if there is a graphic in Pictures with the
#          filename set here, then that picture will be shown. Otherwise, the
#          text of name itself will be drawn in the hover graphic.
#      icon - The index of an icon to show to the left of any text in the hover
#          graphic. It will do nothing if name corresponds to a picture, but it
#          will show up if name is just text or if it is left empty.
#      icon_hue - If icon is not 0, then this will be the hue of the icon drawn
#      time - If this is set to something other than -1, then the hover graphic
#          will expire once the number of frames specified pass. There are 60
#          frames in a second, so if you set time to 180, for instance, the 
#          hover graphic will disappear after 3 seconds.
#      fontname - If drawing text, this is the font used. It can be either a 
#          string or an array of strings.
#      fontsize - If drawing text, this is the size of it.
#      colour - If drawing text, this is the colour of it. It can be either an 
#          integer ID for the colour palette on the windowskin, or it can be
#          an array of integers corresponding to [red, green, blue, alpha]
#      bold - If drawing text, this determines whether it is bolded. It must be
#          true or false.
#      italic - If drawing text, this determines whether it is italicized. It 
#          must be true or false.
#      effect - This is a symbol, and it can play some effects on the hover
#          graphic. There are three repeated effects that you can set, and 
#          these are:
#            :bounce - the hover graphic will move up and down slightly;
#            :fade_bounce - the hover graphic will fade in and out; and
#            :flash - the hover graphic will flash. You can set to which colour
#              by setting effect_param to a palette ID or an [r,g,b,a] array
#          there are also two closing effects which will dispose of the hover
#          graphic once they are completed. These are:
#            :fade - This will show up for about half a second before smoothly
#              fading out of existence;
#            :rise_and_fade - This will do the same as :fade, but it will also
#              rise up a little bit before fading;
#            :disintegrate - This shows up for about a half second before
#              clearing itself by disposing of random pixels each frame for
#              another half a second;
#            :rise_and_disintegrate - This will do the same as :disintegrate, 
#              but it will also rise up a little bit before disintegrating.
#           
#      effect_param - This is only pertinent if you are using the flash effect,
#          and you set the colour for that effect here with a a palette ID or 
#          an [r,g,b,a] array
#      se - If you wish, you can set an SE to play when the hover alert first
#          appears. It must be an array in the form ["filename", volume, pitch]
#      proximity - Set this to any integer, and the hover graphic will only 
#          be visible if the player is within that many squares of the 
#          character over which the hover graphic is intended to appear.
#
#   For any given hover alert, you only need to have either name or icon set
#   directly. If you don't set those, then it will simply remove any existing
#   hover graphic. If you exclude any other value, then I reiterate that it 
#   will just be set to the default value identified in the sample itself. 
#   You can set the default values for fontname, fontsize, colour, bold, italic
#   and effect in the editable region starting at line 158.
#
#    Now, the above code will only set a hover graphic on the event in which
#   the comment appears. For auto-hover alerts in comments at the top of the
#   page, you can only set it to that event, but for the interpreted comments
#   that appear anywhere else you can set the hover graphic above a different
#   event by adding the ID of the event in square brackets after \hover_alert, 
#   like so:
#
#      \hover_alert[0] { ... }
#
#   Now, if you set it to -1, then it will show above the player. If you set it
#   to 0, it will show above the event in which the comment is. If you set it 
#   to any integer > 0, it will show above the event with that ID. If you want 
#   to set it above a follower, then you need to put an f before the ID, like
#   so: 
#
#      \hover_alert[f1] { ... }
#
#   where 1 is the first follower after the player, 2 is the second, etc. You
#   can also set a hover alert above a vehicle by placing a v instead of an f:
#
#      \hover_alert[v0] { ... }
#
#   0 is the boat, 1 is the ship, and 2 is the airship.
#
#    Finally, I mention again that you can remove a hover alert graphic simply
#   by not setting the name or icon within the {}. In other words, the
#   following code would delete any hover graphic over Event 4:
#
#      \hover_alert[4] { }
#``````````````````````````````````````````````````````````````````````````````
#  Autogain Hover Alerts
#
#    The autogain feature allows you to make it so that when gold and items are
#   gained, a hover alert is created above the player showing what is received.
# 
#    If you want to use this feature, the value of AUTOGAIN_HOVERALERTS_SWITCH 
#   at line 182 must be set to a value greater than 0, and then the autogain 
#   alerts will only occur when the in-game switch with that ID is ON. You can
#   also set a number of other autogain features starting at line 185. I 
#   direct you there for instructions about what each does.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_HoverAlerts] = true

#==============================================================================
# *** MA_HoverAlert
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module holds configuration and data for the Hover Alerts script
#==============================================================================

module MA_HoverAlert
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  # * BEGIN  Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  Text Option Defaults
  #``````````````````````````````````````````````````````````````````````````
  #    These options mostly just change the way text is drawn by default, and
  #   are all subject to be overridden in any hover alert.
  FONTNAME = Font.default_name #  The font used when drawing text
  FONTSIZE = Font.default_size #  The size of text when drawing text
  COLOUR = [255, 255, 255]     #  The default colour of text when drawing text.
                               # It can be either an [r, g, b, a] array or it
                               # can be an integer for the windowskin palette.
  BOLD = Font.default_bold     #  Whether text is bolded. It can be set to
                               # either true or false
  ITALIC = Font.default_italic #  Whether text is italicized. It can be set to
                               # either true or false
  EFFECT = :none               #  Default effect for regular hover alerts. It
                               # can be set to either :none, :bounce, :flash,
                               # :fade_bounce, or :rise_and_fade.
  ANIMATE_FRAMES = 12          #  If using an animated picture named with a
                               # %[x], then the number of frames to wait on 
                               # each frame. There are 60 frames in 1 second.
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  Autogain Options
  #``````````````````````````````````````````````````````````````````````````
  #    These options affect the autogain feature, and none affect any other
  #   hover alert except those created when gaining items.
  AUTOGAIN_HOVERALERTS_SWITCH = 5 #  The ID of the switch used to turn the
                                  # autogain feature on and off. If you never
                                  # want to use it, set this to 0.
  AUTOGAIN_GOLD_ICON = 262        #  The icon for gold when autogaining
  AUTOGAIN_NAME_FORMAT = "%s"     #  The format for the name of the item. The
                                  # %s will be replaced with the item's name
                                  # when autogaining.
  AUTOGAIN_NUM_FORMAT = " %+d"    #  The format for the amount gained. The %+d
                                  # is replaced by the number of items or gold
                                  # gained.
  AUTOGAIN_GAIN_SE = ["Chime2"]   #  The SE played when gaining items.
  AUTOGAIN_LOSE_SE = ["Chime1"]   #  The SE played when losing items.
  AUTOGAIN_EFFECT = :rise_and_fade# Effect when autogaining. It can be
                                  # either :fade, :rise_and_fade, :disintegrate,
                                  # or :rise_and_disintegrate. 
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  # * END    Editable Region
  #//////////////////////////////////////////////////////////////////////////
  AUTOGAIN_GAIN_SE = RPG::SE.new(*AUTOGAIN_GAIN_SE) if AUTOGAIN_GAIN_SE.is_a?(Array)
  AUTOGAIN_LOSE_SE = RPG::SE.new(*AUTOGAIN_LOSE_SE) if AUTOGAIN_LOSE_SE.is_a?(Array)
  
  #==========================================================================
  # ** HoverAlert
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This class holds hoveralert data
  #==========================================================================

  class HoverAlert < Struct.new(:name, :icon_index, :icon_hue, :effect, 
    :effect_param, :se, :proximity, :fontname, :fontsize, :colour, :bold, 
    :italic, :time)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Object Initialization
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def initialize(*args)
      defaults = MA_HoverAlert.maha_default_values
      defaults[0, args.size] = args unless args.empty?
      super(*defaults)
    end
  end
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Default Values
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.maha_default_values
    ["", 0, 0, MA_HoverAlert::EFFECT, 0, nil, 0, MA_HoverAlert::FONTNAME, 
      MA_HoverAlert::FONTSIZE, MA_HoverAlert::COLOUR, MA_HoverAlert::BOLD, 
      MA_HoverAlert::ITALIC, -1]
  end
end

#==============================================================================
# ** Game_CharacterBase
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods
#    new method - show_hover_alert  
#==============================================================================

class Game_CharacterBase
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :hover_alert
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Private Members
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maha_initprivmem_1cr0 init_private_members
  def init_private_members(*args)
    maha_initprivmem_1cr0(*args) # Call original method
    clear_hover_alert
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear Hover Alert
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def clear_hover_alert
    @hover_alert_queue = []
    @hover_alert = nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show Hover Alert
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def show_hover_alert(name = "", icon = 0, *args)
    if (name.nil? || name.empty?) && (icon.nil? || icon == 0)
      @hover_alert = @hover_alert_queue.empty? ? nil : @hover_alert_queue.shift
    else
      alert = MA_HoverAlert::HoverAlert.new(name, icon, *args) 
      @hover_alert ? @hover_alert_queue.push(alert) : @hover_alert = alert
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Replace Hover Alert
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def replace_hover_alert(*args)
    clear_hover_alert
    show_hover_alert(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Hover Alert by Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def interpret_hover_alert_comment(text)
    if text[/\\HOVER_ALERT\[?.*?\]?\s*\{(.*?)\}/im]
      name, icon, icon_hue, effect, effect_param, se, proximity, fontname,   
        fontsize, colour, bold, italic, time = *MA_HoverAlert.maha_default_values
      color = nil # Initialize alternate spelling of color
      eval($1)
      colour = color if color
      se = RPG::SE.new(*se) if se.is_a?(Array)
      replace_hover_alert(name, icon, icon_hue, effect, effect_param, se, 
        proximity, fontname, fontsize, colour, bold, italic, time)
    end
  end
end

#==============================================================================
# ** Game_Event
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - setup_page_settings; clear_page_settings
#    new method - ma_collect_first_comment  
#==============================================================================

class Game_Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_stuppgsets_7sj5 setup_page_settings
  def setup_page_settings(*args)
    ma_stuppgsets_7sj5(*args) # Call original method
    clear_hover_alert
    interpret_hover_alert_comment(ma_collect_init_comment)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_clrpgsettings_5na5 clear_page_settings
  def clear_page_settings(*args)
    ma_clrpgsettings_5na5(*args) # Call original method
    clear_hover_alert
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Collect First Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def ma_collect_init_comment
    comment, i = "", 0
    while !@list[i].nil? && (@list[i].code == 108 || @list[i].code == 408)
      comment += @list[i].parameters[0] + "\n"
      i += 1
    end
    comment
  end unless self.method_defined?(:ma_collect_init_comment)
end

#==============================================================================
# ** Game_Party
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - maha_item_number_plus_equips
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Number and Equips
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_item_number_plus_equips(item)
    equip_num = 0
    members.each { |actor| equip_num += actor.equips.count(item) }
    item_number(item) + equip_num
  end
end

#==============================================================================
# ** Game_Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - command_108
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Command 108
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maha_cmmndcomment_6cz9 command_108
  def command_108(*args)
    initial = (@index == 0)
    maha_cmmndcomment_6cz9(*args) # Call original method
    maha_interpret_hover_comment(@comments.join("\n")) unless initial
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Hover Alert Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_interpret_hover_comment(text)
    text2 = text.dup
    loop do # Get evert hover alert code in the comment
      match = text2.slice!(/\\HOVER[ _]ALERT\[?\s*([VF]?)(-?\d*)\s*\]?\s*\{.*?\}/im)
      break if match.nil?
      case $1.upcase
      when ''  # Empty
        character = get_character($2.to_i)
      when 'F' # Follower
        character = $2.to_i == 0 ? $game_player : $game_player.followers[$2.to_i - 1]
        return if !character || !character.visible?
      when 'V' # Vehicle
        character = $game_map.vehicles[$2.to_i]
        return if !character || !character.transparent
      end
      character.interpret_hover_alert_comment(match) if character.is_a?(Game_CharacterBase)
    end
  end
  if MA_HoverAlert::AUTOGAIN_HOVERALERTS_SWITCH >= 0
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Gain Gold
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maha_command125_5fx9 command_125
    def command_125(*args, &block)
      old_value = $game_party.gold
      maha_command125_5fx9(*args, &block) # Call Original Method
      # Add to receipt if the possessed amount of gold has changed
      if $game_party.gold != old_value && (MA_HoverAlert::AUTOGAIN_HOVERALERTS_SWITCH == 0 || 
        $game_switches[MA_HoverAlert::AUTOGAIN_HOVERALERTS_SWITCH])
        text = sprintf(MA_HoverAlert::AUTOGAIN_NUM_FORMAT, $game_party.gold - old_value)
        se = $game_party.gold > old_value ? MA_HoverAlert::AUTOGAIN_GAIN_SE : MA_HoverAlert::AUTOGAIN_LOSE_SE
        $game_player.show_hover_alert(text, MA_HoverAlert::AUTOGAIN_GOLD_ICON, 
          0, MA_HoverAlert::AUTOGAIN_EFFECT, 0, se)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Gain Item
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maha_comnd126_2vv9 command_126
    def command_126(*args)
      item = $data_items[@params[0]]
      old_val = $game_party.maha_item_number_plus_equips(item)
      maha_comnd126_2vv9(*args) # Call original method
      autogain_item_hover_alert(item, $game_party.maha_item_number_plus_equips(item) - old_val)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Gain Weapon
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maha_commn127_3ar4 command_127
    def command_127(*args)
      item = $data_weapons[@params[0]]
      old_val = $game_party.maha_item_number_plus_equips(item)
      maha_commn127_3ar4(*args) # Call original method
      autogain_item_hover_alert(item, $game_party.maha_item_number_plus_equips(item) - old_val)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Gain Armor
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias maha_cnd128_1sp6 command_128
    def command_128(*args)
      item = $data_armors[@params[0]]
      old_val = $game_party.maha_item_number_plus_equips(item)
      maha_cnd128_1sp6(*args) # Call original method
      autogain_item_hover_alert(item, $game_party.maha_item_number_plus_equips(item) - old_val)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Autogain Hover Alert
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def autogain_item_hover_alert(item, n)
      return if n == 0 || !(MA_HoverAlert::AUTOGAIN_HOVERALERTS_SWITCH == 0 || 
        $game_switches[MA_HoverAlert::AUTOGAIN_HOVERALERTS_SWITCH])
      text = sprintf(MA_HoverAlert::AUTOGAIN_NAME_FORMAT, item.name) +
        sprintf(MA_HoverAlert::AUTOGAIN_NUM_FORMAT, n)
      se = n > 0 ? MA_HoverAlert::AUTOGAIN_GAIN_SE : MA_HoverAlert::AUTOGAIN_LOSE_SE
      icon_hue = $imported[:MAIcon_Hue] ? item.icon_hue : 0
      $game_player.show_hover_alert(text, item.icon_index, icon_hue, 
        MA_HoverAlert::AUTOGAIN_EFFECT, 0, se)
    end
  end
end

#==============================================================================
# ** Sprite_HoverAlert
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This class handles showing the hover sprite.
#==============================================================================

class Sprite_HoverAlert < Sprite_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(viewport, character)
    # Initialize variables
    @char_x, @char_y = 0, 0
    @effect_x, @effect_y = 0, 0
    @effect, @effect_param, @effect_time = :none, 0, -1
    @ap_time, @ap_max_time, @ap_width, @ap_frame_index, @ap_frame_num = -1, 0, 0, 0, 0
    @time = 0
    @disintegrate_array = []
    super(viewport)
    self.z = 200
    @character = character
    refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Free
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose(*args)
    bitmap.dispose if bitmap && !bitmap.disposed?
    super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    refresh if @hover_alert != @character.hover_alert # if hover alert changed
    if bitmap
      if @hover_alert.proximity > 0
        x = @character.distance_x_from($game_player.x).abs
        y = @character.distance_y_from($game_player.y).abs
        self.visible = Math.hypot(x, y) <= @hover_alert.proximity
      end
      if self.visible
        maha_update_se              # Update Sound Effect
        maha_update_frame_animation # Update animation
        maha_update_effect          # Update the effect being played
        # Adust position
        self.x = @char_x + @effect_x
        self.y = @char_y + @effect_y
      end
      if @hover_alert && @hover_alert.time > 0
        if @time == @hover_alert.time
          @character.show_hover_alert("", 0) # End Hover Alert
          refresh
        end
        @time += 1
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update SE
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_update_se
    if @hover_alert.se && !@se_played
      @hover_alert.se.play
      @se_played = true
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Frame Animation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_update_frame_animation
    if @ap_time == 0 # If timer finished
      # Switch frames
      @ap_frame_index = (@ap_frame_index + 1) % @ap_frame_num
      @ap_time = @ap_max_time
      self.src_rect.x = @ap_frame_index*@ap_width
    end
    @ap_time -= 1 if @ap_time > 0 # Decrease timer until finished
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Adjust Character Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def adjust_character_position(x, y); @char_x, @char_y = x, y; end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    @se_played = false
    @hover_alert = @character.hover_alert
    bitmap.dispose if bitmap && !bitmap.disposed?
    return unless @hover_alert
    (!@hover_alert.name.empty? ? maha_draw_picture : maha_draw_text) rescue maha_draw_text
    self.ox = @ap_width / 2
    self.oy = bitmap.height
    self.visible = true
    maha_start_effect
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Reset Font Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_reset_font_settings
    bitmap.font = Font.new(@hover_alert.fontname, @hover_alert.fontsize)
    bitmap.font.bold = @hover_alert.bold
    bitmap.font.italic = @hover_alert.italic
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Text Colour
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def text_color(n)
    colour = case n
    when Integer
      # Extended Colour Palette compatibility
      if $imported[:MA_ExtendedColourPalette] && n >= 32
        n -= 32
        Cache.system("Palette").get_pixel((n % 8) * 8, (n / 8) * 8)
      else
        Cache.system("Window").get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
      end
    when Array then Color.new(*n)
    else Color.new(255, 255, 255)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_draw_picture
    # Use picture if it exists
    self.bitmap = Cache.picture(@hover_alert.name).dup
    @ap_width = bitmap.width
    if @hover_alert.name[/%\[(\d+)[\s,;]*(\d*?)\]/] # If animated graphic
      # Setup animated picture variables
      @ap_frame_num = $1.to_i
      @ap_width /= @ap_frame_num
      @ap_max_time = $2.empty? ? MA_HoverAlert::ANIMATE_FRAMES : $2.to_i
      @ap_frame_index = 0
      @ap_time = @ap_max_time
      self.src_rect = Rect.new(0, 0, @ap_width, bitmap.height)
    else
      @ap_time = -1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Text
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_draw_text
    # Else draw the word
    x = 0
    self.bitmap = Bitmap.new(24, 24)
    if @hover_alert.name && !@hover_alert.name.empty?
      maha_reset_font_settings
      # Retrieve actual string
      ts = bitmap.text_size(@hover_alert.name)
      if @hover_alert.icon_index > 0
        x = 28
        ts.width += 28 
        ts.height = 24 if ts.height < 24
      end
      # Resize
      bitmap.dispose
      self.bitmap = Bitmap.new(ts.width + 4, ts.height + 4)
      maha_reset_font_settings
      bitmap.font.color = text_color(@hover_alert.colour)
      # Draw text
      bitmap.draw_text(x, 0, bitmap.width - x, bitmap.height, @hover_alert.name, 1)
    end
    # Draw Icon
    @hover_alert.icon_hue == 0 ? maha_draw_icon(@hover_alert.icon_index, 0, (height - 24) / 2) :
      maha_draw_icon_with_hue(@hover_alert.icon_index, @hover_alert.icon_hue, 0, (height - 24) / 2)
    @ap_time = -1
    @ap_width = bitmap.width
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_draw_icon(icon_index, x, y)
    bmp = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(x, y, bmp, rect, 255)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Icon With Hue
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_draw_icon_with_hue(icon_index, icon_hue, x, y)
    bmp = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    # Draw Icon onto small and independent bitmap
    icon_bmp = Bitmap.new(24, 24) 
    icon_bmp.blt(0, 0, bmp, rect)
    icon_bmp.hue_change(icon_hue) # Change hue of icon
    rect.x, rect.y = 0, 0
    bitmap.blt(x, y, icon_bmp, rect, 255)
    icon_bmp.dispose # Dispose Icon Bitmap
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Start HoverAlert Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_start_effect
    @effect = @hover_alert.effect
    @effect_param = @hover_alert.effect_param
    @effect_x, @effect_y = 0, 0
    @disintegrate_array.clear
    self.opacity = 255
    case @effect
    when :bounce, :fade_bounce then @effect_time = 32
    when :flash
      @effect_time = 32
      flash(text_color(@effect_param), @effect_time)
    when :rise_and_fade
      @effect_time = 48
      @effect_y = 18
    when :fade then @effect_time = 48
    when :disintegrate, :rise_and_disintegrate
      @effect_y = 24 if @effect == :rise_and_disintegrate
      @effect_time = 64
      for i in 0...bitmap.width
        for j in 0...bitmap.height
          @disintegrate_array.push(i, j)
        end
      end
    else
      @effect_time = -1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update HoverAlert Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_update_effect
    if @effect_time == 0
      case @effect
      when :bounce, :flash, :fade_bounce then maha_start_effect # Repeat
      else maha_finish_effect # Close
      end
    elsif @effect_time > 0
      case @effect
      when :bounce then @effect_y += (@effect_time > 16 ? -0.5 : 0.5)
      when :fade_bounce then self.opacity += (@effect_time > 16 ? -8 : 8)
      # Temporary Effects
      when :fade then self.opacity = 16*@effect_time if @effect_time < 16
      when :rise_and_fade
        @effect_y -= 0.5
        self.opacity = 16*@effect_time if @effect_time < 16
      when :disintegrate then maha_update_disintegrate_effect if @effect_time < 32
      when :rise_and_disintegrate
        @effect_y -= 0.5 if @effect_time > 32
        maha_update_disintegrate_effect if @effect_time < 32
      end
      @effect_time -= 1
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Disintegrate Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_update_disintegrate_effect
    col = Color.new(0, 0, 0, 0)
    (bitmap.width*bitmap.height / 32).times do
      i = (rand(@disintegrate_array.size / 2)*2)
      x, y = *@disintegrate_array[i, 2]
      bitmap.set_pixel(x, y, col)
      @disintegrate_array.delete_at(i)
      @disintegrate_array.delete_at(i + 1)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Finish HoverAlert Effect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maha_finish_effect
    @effect_x, @effect_y = 0, 0
    @effect_time = -1
    self.opacity = 255
    @disintegrate_array.clear
    # Set to next hover alert, if any
    @character.show_hover_alert("", 0)
    refresh
  end
end

#==============================================================================
# ** Sprite_Character
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - update; dispose
#    new methods - update_maha_sprite; dispose_maha_sprite
#==============================================================================

class Sprite_Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maha_update_2hz0 update
  def update(*args)
    maha_update_2hz0(*args) # Call original method
    update_maha_sprite
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Hover Alert
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_maha_sprite
    if !@maha_sprite && @character.hover_alert # Create the HoverAlert sprite
      @maha_sprite = Sprite_HoverAlert.new(viewport, @character)
    end
    if @maha_sprite
      if @character.hover_alert.nil?
        dispose_maha_sprite
      else
        # Pass position of sprite to the hover alert's sprite
        @maha_sprite.adjust_character_position(self.x, self.y - self.oy)
        @maha_sprite.update
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maha_dispose_4cm6 dispose
  def dispose(*args)
    dispose_maha_sprite
    maha_dispose_4cm6(*args) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose Hover Alert Sprite
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose_maha_sprite
    @maha_sprite.dispose if @maha_sprite && !@maha_sprite.disposed?
    @maha_sprite = nil
  end
end