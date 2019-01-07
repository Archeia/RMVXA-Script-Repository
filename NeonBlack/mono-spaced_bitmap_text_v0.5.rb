Font.default_name = "Typeset"
 
class Color ## Do not edit this module.
  def s_ary; [self.red, self.green, self.blue]; end
  def l_ary; [self.red, self.green, self.blue, self.alpha]; end
  
  def same?(color)
    return false unless color.is_a?(Color)
    self.s_ary == color.s_ary
  end
  
  def match?(color)
    return false unless color.is_a?(Color)
    self.l_ary == color.l_ary
  end
  
  def trans?
    return self.alpha <= 0
  end
end
 
 
module Typeset
  ## Names of the bitmap fonts.  A font name must be set to one of these for it
  ## to display as a bitmap.
  Names = ["Typeset", "Typebat"]
  
  ## All the letters in the bitmap file.
  Letters = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
  
  ## The colours to replace with the new colour.  Alpha is not included.
  ## Inner replaces font.color while Outer replaces font.out_color.
  Inner = Color.new(255, 255, 255)
  Outer = Color.new(0, 0, 0)
  
  ## Rows in the bitmap images stacked top to bottom.
  Rows = 8
  
  ## Choose to preload graphics.  If set to true all 32 normal window colours
  ## will pre-load before the title screen.  In this case you can use a loading
  ## screen image from the Graphics/System folder.  If you do not want to use
  ## a loading screen, set LoadingScreen = nil.
  Preload = false
  LoadingScreen = "LoadingScreen"
  
##-----------------------------------------------------------------------------
 
  @@colors = {}
 
  def self.get_default_colors
    show_loading_screen if LoadingScreen
    for name in Names
      32.times do |i|
        color = windowskin.get_pixel(64 + (i % 8) * 8, 96 + (i / 8) * 8)
        add_color(name, color, Font.default_out_color,
                  Font.default_outline ? 255 : 0)
      end
    end
    fade_loading_screen if @loading_sprite
  end
  
  def self.show_loading_screen
    @loading_sprite = Sprite.new
    Graphics.fadeout(0)
    @loading_sprite.bitmap = Cache.system(LoadingScreen)
    Graphics.fadein(30)
  end
  
  def self.fade_loading_screen
    Graphics.fadeout(30)
    @loading_sprite.dispose
  end
 
  def self.first_color
    key = @@colors.key(@@colors.values[0])
    if @@colors[key].disposed?
      get_default_colors
    end
    return @@colors.values[0]
  end
 
  def self.check_color(name, color, out = Color.new(0,0,0), outline = 255)
    c1 = color.is_a?(Color) ? color.s_ary : color
    c2 = out.is_a?(Color)   ? out.s_ary   : out
    key = [name, c1, c2, outline]
    @@colors.include?(key) && !@@colors[key].disposed?
  end
 
  def self.add_color(name, color, out = Color.new(0,0,0), outline = 255)
    return if check_color(name, color, out, outline)
    c1 = color.is_a?(Color) ? color.s_ary : color
    c2 = out.is_a?(Color)   ? out.s_ary   : out
    source = Cache.system(name) rescue return
    bitmap = Bitmap.new(source.width, source.height)
    bitmap.blt(0, 0, source, source.rect)
    bitmap.height.times do |y|
      sc = sw = nil
      bitmap.width.times do |x|
        pixel = bitmap.get_pixel(x, y)
        if sc
          if sc.match?(pixel)
            sw += 1
            next
          else
            if sc.same?(Inner)
              bitmap.fill_rect(x-sw, y, sw, 1, Color.new(*c1, sc.alpha))
            elsif sc.same?(Outer)
              al = sc.alpha * outline / 255
              bitmap.fill_rect(x-sw, y, sw, 1, Color.new(*c2, al))
            end
            sc = nil
          end
        elsif pixel.trans?
          next
        end
        if pixel.same?(Inner) || pixel.same?(Outer)
          sw = 1
          sc = pixel
        end
      end
      x = bitmap.width
      if sc && sc.same?(Inner)
        bitmap.fill_rect(x-sw, y, sw, 1, Color.new(*c1, sc.alpha))
      elsif sc && sc.same?(Outer)
        al = sc.alpha * outline / 255 if sc
        bitmap.fill_rect(x-sw, y, sw, 1, Color.new(*c2, al))
      end
    end
    @@colors[[name, c1, c2, outline]] = bitmap
  end
  
  def self.windowskin
    Cache.system("Window")
  end
 
  def self.get_typeset(name, color, out = Color.new(0,0,0), outline = 255)
    add_color(name, color, out, outline)
    color_by_key(name, color.s_ary, out.s_ary, outline)
  end
 
  def self.default_size(key = nil)
    if key
      color_by_key(key[0], key[1].s_ary, key[2].s_ary, key[3]).height / Rows
    else
      @default_size ||= first_color.height / Rows
      @default_size
    end
  end
  
  def self.default_width(key = nil)
    if key
      color_by_key(key[0], key[1].s_ary, key[2].s_ary, key[3]).width / 12
    else
      first_color.width / 12
    end
  end
 
  def self.get_letterbox(size, key = nil)
    fs = default_size(key)
    fw = (default_width(key) * (size.to_f / fs)).round
    fh = (fs * (size.to_f / fs)).round
    [fw, fh]
  end
 
  def self.get_pos(c)
    Letters.index(c) || 0
  end
  
  def self.color_by_key(name, c1, c2, out)
    c1 = c1.is_a?(Color) ? c1.s_ary : c1
    c2 = c2.is_a?(Color) ? c2.s_ary : c2
    add_color(name, c1, c2, out) unless check_color(name, c1, c2, out)
    @@colors[[name, c1, c2, out]]
  end
  
  get_default_colors if Preload
end
 
 
class Bitmap
  alias :cp_typeset_draw_text :draw_text
  def draw_text(*args)
    name = self.font.name
    name = name.first if name.is_a?(Array)
    return cp_typeset_draw_text(*args) unless Typeset::Names.include?(name)
    case args.size
    when 2, 3
      rect = args[0].clone
      text = args[1].to_s
      algn = args[2] || 0
    when 5, 6
      rect = Rect.new(*args[0..3])
      text = args[4].to_s
      algn = args[5] || 0
    else
      return cp_typeset_draw_text(*args)
    end
    key = [name, self.font.color, self.font.out_color, self.font.outline ? 255 : 0]
    typeset = Typeset.get_typeset(*key)
    letterbox = Typeset.get_letterbox(self.font.size, key)
    basicbox =  Typeset.get_letterbox(Typeset.default_size(key), key)
    bitmap = Bitmap.new([letterbox[0] * text.size, 1].max, [letterbox[1], 1].max)
    text.split(//).each_with_index do |c,i|
      n = Typeset.get_pos(c)
      rect2 = Rect.new((n % 12) * basicbox[0], (n / 12) * basicbox[1], *basicbox)
      rect3 = Rect.new(i * letterbox[0], 0, *letterbox)
      bitmap.stretch_blt(rect3, typeset, rect2)
    end
    ypos = rect.y + (rect.height - bitmap.height) / 2
    if rect.width < bitmap.width
      rect4 = Rect.new(rect.x, ypos, rect.width, bitmap.height)
      self.stretch_blt(rect4, bitmap, bitmap.rect, self.font.color.alpha)
    else
      xpos = rect.x + (rect.width - bitmap.width) / 2 * algn
      self.blt(xpos, ypos, bitmap, bitmap.rect, self.font.color.alpha)
    end
  end
 
  alias :cp_typeset_text_size :text_size
  def text_size(string)
    string = string.to_s
    name = self.font.name
    name = name.first if name.is_a?(Array)
    return cp_typeset_text_size(string) unless Typeset::Names.include?(name)
    key = [name, self.font.color, self.font.out_color, self.font.outline ? 255 : 0]
    letterbox = Typeset.get_letterbox(self.font.size, key)
    Rect.new(0, 0, letterbox[0] * string.size, letterbox[1])
  end
end