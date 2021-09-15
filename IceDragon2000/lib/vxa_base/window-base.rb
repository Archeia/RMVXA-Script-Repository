#encoding:UTF-8
# Window_Base
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.windowskin = Cache.system("Window")
    update_padding
    update_tone
    create_contents
    @opening = @closing = false
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    contents.dispose unless disposed?
    super
  end
  #--------------------------------------------------------------------------
  # * Get Line Height
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size
  #--------------------------------------------------------------------------
  def standard_padding
    return 12
  end
  #--------------------------------------------------------------------------
  # * Update Padding
  #--------------------------------------------------------------------------
  def update_padding
    self.padding = standard_padding
  end
  #--------------------------------------------------------------------------
  # * Calculate Width of Window Contents
  #--------------------------------------------------------------------------
  def contents_width
    width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    height - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Suited to Specified Number of Lines
  #--------------------------------------------------------------------------
  def fitting_height(line_number)
    line_number * line_height + standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Update Tone
  #--------------------------------------------------------------------------
  def update_tone
    self.tone.set($game_system.window_tone)
  end
  #--------------------------------------------------------------------------
  # * Create Window Contents
  #--------------------------------------------------------------------------
  def create_contents
    contents.dispose
    if contents_width > 0 && contents_height > 0
      self.contents = Bitmap.new(contents_width, contents_height)
    else
      self.contents = Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_tone
    update_open if @opening
    update_close if @closing
  end
  #--------------------------------------------------------------------------
  # * Update Open Processing
  #--------------------------------------------------------------------------
  def update_open
    self.openness += 48
    @opening = false if open?
  end
  #--------------------------------------------------------------------------
  # * Update Close Processing
  #--------------------------------------------------------------------------
  def update_close
    self.openness -= 48
    @closing = false if close?
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    @opening = true unless open?
    @closing = false
    self
  end
  #--------------------------------------------------------------------------
  # * Close Window
  #--------------------------------------------------------------------------
  def close
    @closing = true unless close?
    @opening = false
    self
  end
  #--------------------------------------------------------------------------
  # * Show Window
  #--------------------------------------------------------------------------
  def show
    self.visible = true
    self
  end
  #--------------------------------------------------------------------------
  # * Hide Window
  #--------------------------------------------------------------------------
  def hide
    self.visible = false
    self
  end
  #--------------------------------------------------------------------------
  # * Activate Window
  #--------------------------------------------------------------------------
  def activate
    self.active = true
    self
  end
  #--------------------------------------------------------------------------
  # * Deactivate Window
  #--------------------------------------------------------------------------
  def deactivate
    self.active = false
    self
  end
  #--------------------------------------------------------------------------
  # * Get Text Color
  #     n : Text color number (0..31)
  #--------------------------------------------------------------------------
  def text_color(n)
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  #--------------------------------------------------------------------------
  # * Get Text Colors
  #--------------------------------------------------------------------------
  def normal_color;      text_color(0);   end;    # Normal
  def system_color;      text_color(16);  end;    # System
  def crisis_color;      text_color(17);  end;    # Crisis
  def knockout_color;    text_color(18);  end;    # Knock out
  def gauge_back_color;  text_color(19);  end;    # Gauge background
  def hp_gauge_color1;   text_color(20);  end;    # HP gauge 1
  def hp_gauge_color2;   text_color(21);  end;    # HP gauge 2
  def mp_gauge_color1;   text_color(22);  end;    # MP gauge 1
  def mp_gauge_color2;   text_color(23);  end;    # MP gauge 2
  def mp_cost_color;     text_color(23);  end;    # TP cost
  def power_up_color;    text_color(24);  end;    # Equipment power up
  def power_down_color;  text_color(25);  end;    # Equipment power down
  def tp_gauge_color1;   text_color(28);  end;    # TP gauge 1
  def tp_gauge_color2;   text_color(29);  end;    # TP gauge 2
  def tp_cost_color;     text_color(29);  end;    # TP cost
  #--------------------------------------------------------------------------
  # * Get Background Color of Pending Item
  #--------------------------------------------------------------------------
  def pending_color
    windowskin.get_pixel(80, 80)
  end
  #--------------------------------------------------------------------------
  # * Get Alpha Value of Translucent Drawing
  #--------------------------------------------------------------------------
  def translucent_alpha
    return 160
  end
  #--------------------------------------------------------------------------
  # * Change Text Drawing Color
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def change_color(color, enabled = true)
    contents.font.color.set(color)
    contents.font.color.alpha = translucent_alpha unless enabled
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #     args : Same as Bitmap#draw_text.
  #--------------------------------------------------------------------------
  def draw_text(*args)
    contents.draw_text(*args)
  end
  #--------------------------------------------------------------------------
  # * Get Text Size
  #--------------------------------------------------------------------------
  def text_size(str)
    contents.text_size(str)
  end
  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # * Reset Font Settings
  #--------------------------------------------------------------------------
  def reset_font_settings
    change_color(normal_color)
    contents.font.size = Font.default_size
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
  end
  #--------------------------------------------------------------------------
  # * Preconvert Control Characters
  #    As a rule, replace only what will be changed into text strings before
  #    starting actual drawing. The character "\" is replaced with the escape
  #    character (\e).
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result
  end
  #--------------------------------------------------------------------------
  # * Get Name of Actor Number n
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end
  #--------------------------------------------------------------------------
  # * Get Name of Party Member n
  #--------------------------------------------------------------------------
  def party_member_name(n)
    actor = n >= 1 ? $game_party.members[n - 1] : nil
    actor ? actor.name : ""
  end
  #--------------------------------------------------------------------------
  # * Character Processing
  #     c    : Characters
  #     text : A character string buffer in drawing processing (destructive)
  #     pos  : Draw position {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\n"   # New line
      process_new_line(text, pos)
    when "\f"   # New page
      process_new_page(text, pos)
    when "\e"   # Control character
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Normal character
      process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * Normal Character Processing
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end
  #--------------------------------------------------------------------------
  # * New Line Character Processing
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    pos[:x] = pos[:new_x]
    pos[:y] += pos[:height]
    pos[:height] = calc_line_height(text)
  end
  #--------------------------------------------------------------------------
  # * New Page Character Processing
  #--------------------------------------------------------------------------
  def process_new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # * Destructively Get Control Code
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(/^[\$\.\|\^!><\{\}\\]|^[A-Z]+/i)
  end
  #--------------------------------------------------------------------------
  # * Destructively Get Control Code Argument
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0
  end
  #--------------------------------------------------------------------------
  # * Control Character Processing
  #     code : the core of the control character
  #            e.g. "C" in the case of the control character \C[1].
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(text_color(obtain_escape_param(text)))
    when 'I'
      process_draw_icon(obtain_escape_param(text), pos)
    when '{'
      make_font_bigger
    when '}'
      make_font_smaller
    end
  end
  #--------------------------------------------------------------------------
  # * Icon Drawing Process by Control Characters
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    draw_icon(icon_index, pos[:x], pos[:y])
    pos[:x] += 24
  end
  #--------------------------------------------------------------------------
  # * Increase Font Size
  #--------------------------------------------------------------------------
  def make_font_bigger
    contents.font.size += 8 if contents.font.size <= 64
  end
  #--------------------------------------------------------------------------
  # * Decrease Font Size
  #--------------------------------------------------------------------------
  def make_font_smaller
    contents.font.size -= 8 if contents.font.size >= 16
  end
  #--------------------------------------------------------------------------
  # * Calculate Line Height
  #     restore_font_size : Return to original font size after calculating
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    result = [line_height, contents.font.size].max
    last_font_size = contents.font.size
    text.slice(/^.*$/).scan(/\e[\{\}]/).each do |esc|
      make_font_bigger  if esc == "\e{"
      make_font_smaller if esc == "\e}"
      result = [result, contents.font.size].max
    end
    contents.font.size = last_font_size if restore_font_size
    result
  end
  #--------------------------------------------------------------------------
  # * Draw Gauge
  #     rate   : Rate (full at 1.0)
  #     color1 : Left side gradation
  #     color2 : Right side gradation
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Draw Character Graphic
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # * Get HP Text Color
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.mhp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Get MP Text Color
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.mmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Get TP Text Color
  #--------------------------------------------------------------------------
  def tp_color(actor)
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Walking Graphic
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Face Graphic
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face(actor.face_name, actor.face_index, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # * Draw Name
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112)
    change_color(hp_color(actor))
    draw_text(x, y, width, line_height, actor.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Class
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Nickname
  #--------------------------------------------------------------------------
  def draw_actor_nickname(actor, x, y, width = 180)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.nickname)
  end
  #--------------------------------------------------------------------------
  # * Draw Level
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    change_color(system_color)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    draw_text(x + 32, y, 24, line_height, actor.level, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw State and Buff/Debuff Icons
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end
  #--------------------------------------------------------------------------
  # * Draw Current Value/Maximum Value in Fractional Format
  #     current : Current value
  #     max     : Maximum value
  #     color1  : Color of current value
  #     color2  : Color of maximum value
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width < 96
      draw_text(xr - 40, y, 42, line_height, current, 2)
    else
      draw_text(xr - 92, y, 42, line_height, current, 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, max, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw TP
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    draw_text(x + width - 42, y, 42, line_height, actor.tp.to_i, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Simple Status
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x + 120, y)
    draw_actor_hp(actor, x + 120, y + line_height * 1)
    draw_actor_mp(actor, x + 120, y + line_height * 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 120, y, 36, line_height, actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Number (Gold Etc.) with Currency Unit
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    draw_text(x, y, width, line_height, unit, 2)
  end
  #--------------------------------------------------------------------------
  # * Get Parameter Change Color
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_up_color   if change > 0
    return power_down_color if change < 0
    return normal_color
  end
end
