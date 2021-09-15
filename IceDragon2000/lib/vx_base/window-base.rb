#encoding:UTF-8
# Window_Base
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a superclass of all windows in the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  WLH = 24                  # Window Line Height
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    self.windowskin = Cache.system("Window")
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    self.back_opacity = 200
    self.openness = 255
    create_contents
    @opening = false
    @closing = false
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    self.contents.dispose
    super
  end
  #--------------------------------------------------------------------------
  # * Create Window Contents
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @opening
      self.openness += 48
      @opening = false if self.openness == 255
    elsif @closing
      self.openness -= 48
      @closing = false if self.openness == 0
    end
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    @opening = true if self.openness < 255
    @closing = false
  end
  #--------------------------------------------------------------------------
  # * Close Window
  #--------------------------------------------------------------------------
  def close
    @closing = true if self.openness > 0
    @opening = false
  end
  #--------------------------------------------------------------------------
  # * Get Text Color
  #     n : Text color number  (0-31)
  #--------------------------------------------------------------------------
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    return windowskin.get_pixel(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Normal Text Color
  #--------------------------------------------------------------------------
  def normal_color
    return text_color(0)
  end
  #--------------------------------------------------------------------------
  # * Get System Text Color
  #--------------------------------------------------------------------------
  def system_color
    return text_color(16)
  end
  #--------------------------------------------------------------------------
  # * Get Crisis Text Color
  #--------------------------------------------------------------------------
  def crisis_color
    return text_color(17)
  end
  #--------------------------------------------------------------------------
  # * Get Knockout Text Color
  #--------------------------------------------------------------------------
  def knockout_color
    return text_color(18)
  end
  #--------------------------------------------------------------------------
  # * Get Gauge Background Color
  #--------------------------------------------------------------------------
  def gauge_back_color
    return text_color(19)
  end
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 1
  #--------------------------------------------------------------------------
  def hp_gauge_color1
    return text_color(20)
  end
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 2
  #--------------------------------------------------------------------------
  def hp_gauge_color2
    return text_color(21)
  end
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 1
  #--------------------------------------------------------------------------
  def mp_gauge_color1
    return text_color(22)
  end
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 2
  #--------------------------------------------------------------------------
  def mp_gauge_color2
    return text_color(23)
  end
  #--------------------------------------------------------------------------
  # * Get Equip Screen Power Up Color
  #--------------------------------------------------------------------------
  def power_up_color
    return text_color(24)
  end
  #--------------------------------------------------------------------------
  # * Get Equip Screen Power Down Color
  #--------------------------------------------------------------------------
  def power_down_color
    return text_color(25)
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #     icon_index : Icon number
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     enabled    : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end
  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #     face_name  : Face graphic filename
  #     face_index : Face graphic index
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     size       : Display size
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, size = 96)
    bitmap = Cache.face(face_name)
    rect = Rect.new(0, 0, 0, 0)
    rect.x = face_index % 4 * 96 + (96 - size) / 2
    rect.y = face_index / 4 * 96 + (96 - size) / 2
    rect.width = size
    rect.height = size
    self.contents.blt(x, y, bitmap, rect)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * Draw Character Graphic
  #     character_name  : Character graphic filename
  #     character_index : Character graphic index
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return if character_name == nil
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign != nil and sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # * Get HP Text Color
  #     actor : actor
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.maxhp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Get MP Text Color
  #     actor : actor
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.maxmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Walking Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Face Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     size  : Display size
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, size = 96)
    draw_face(actor.face_name, actor.face_index, x, y, size)
  end
  #--------------------------------------------------------------------------
  # * Draw Name
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = hp_color(actor)
    self.contents.draw_text(x, y, 108, WLH, actor.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Class
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 108, WLH, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Level
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, WLH, Vocab::level_a)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, WLH, actor.level, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw State
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 96)
    count = 0
    for state in actor.states
      draw_icon(state.icon_index, x + 24 * count, y)
      count += 1
      break if (24 * count > width - 24)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 120)
    draw_actor_hp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::hp_a)
    self.contents.font.color = hp_color(actor)
    last_font_size = self.contents.font.size
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.hp, 2)
    else
      self.contents.draw_text(xr - 99, y, 44, WLH, actor.hp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.maxhp, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    gw = width * actor.hp / actor.maxhp
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 120)
    draw_actor_mp_gauge(actor, x, y, width)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 30, WLH, Vocab::mp_a)
    self.contents.font.color = mp_color(actor)
    last_font_size = self.contents.font.size
    xr = x + width
    if width < 120
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.mp, 2)
    else
      self.contents.draw_text(xr - 99, y, 44, WLH, actor.mp, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
      self.contents.draw_text(xr - 44, y, 44, WLH, actor.maxmp, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw MP Gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    gw = width * actor.mp / [actor.maxmp, 1].max
    gc1 = mp_gauge_color1
    gc2 = mp_gauge_color2
    self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
    self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     type  : Type of parameters (0-3)
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = Vocab::atk
      parameter_value = actor.atk
    when 1
      parameter_name = Vocab::def
      parameter_value = actor.def
    when 2
      parameter_name = Vocab::spi
      parameter_value = actor.spi
    when 3
      parameter_name = Vocab::agi
      parameter_value = actor.agi
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, WLH, parameter_value, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     item    : Item (skill, weapon, armor are also possible)
  #     x       : draw spot x-coordinate
  #     y       : draw spot y-coordinate
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true)
    if item != nil
      draw_icon(item.icon_index, x, y, enabled)
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x + 24, y, 172, WLH, item.name)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw number with currency unit
  #     value : Number (gold, etc)
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_currency_value(value, x, y, width)
    cx = contents.text_size(Vocab::gold).width
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width-cx-2, WLH, value, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, width, WLH, Vocab::gold, 2)
  end
end
