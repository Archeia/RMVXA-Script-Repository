#
# EDOS/core/cedar/Cedar.rb
#   by IceDragon
#   dc 11/05/2013
#   dm 11/05/2013
# vr 0.0.1
# Cedar is a coding/debugging module built-atop StarRuby's Input system
module Cedar
  VERSION = '0.0.1'.freeze

  class KeyboardHandle

    def initialize
      @retrigger = 12
    end

    def get_key_mod_states
      StarRuby::Input.key_mod_states
    end

    def get_caps_state
      return get_key_mod_states[:capslock]
    end

    def get_shift_state
      return get_key_mod_states[:shiftkey]
    end

    def keys(dur, del, int)
      StarRuby::Input.keys(:keyboard,
                           duration: dur, delay: del, interval: int)
    end

    def get_typing
      keys(1, @retrigger, @retrigger)
    end

    def get_typing_as_str(buffer)
      data   = get_typing.dup
      caps   = get_caps_state
      shift  = get_shift_state

      cappify = caps
      cappify = !cappify if shift
      if data.size > 0
        while(k = data.shift) do
          case k
          when :a..:z
            s = k.to_s
            s = (cappify ? s.upcase : s)
            buffer.concat(s)
          when :d0..:d9
            s = case k
            when :d0 then (cappify ? ')' : '0')
            when :d1 then (cappify ? '!' : '1')
            when :d2 then (cappify ? '@' : '2')
            when :d3 then (cappify ? '#' : '3')
            when :d4 then (cappify ? '$' : '4')
            when :d5 then (cappify ? '%' : '5')
            when :d6 then (cappify ? '^' : '6')
            when :d7 then (cappify ? '&' : '7')
            when :d8 then (cappify ? '*' : '8')
            when :d9 then (cappify ? '(' : '9')
            end
            buffer.concat(s)
          when :backspace
            buffer.pop!
          when :enter
            buffer.concat("\n")
          when :space
            buffer.concat("\s")
          else
            buffer.concat(k.to_s)
          end
        end
        return true
      else
        return false
      end
    end

  end

  class Notepad

    attr_accessor :buffer
    attr_reader :cols, :rows
    attr_reader :x, :y, :z
    attr_reader :width, :height
    attr_reader :viewport
    attr_accessor :keyboard

    def initialize(viewport, x, y, cols, rows, z=0)
      @viewport = viewport
      @cols = cols
      @rows = rows
      @x, @y, @z = x, y, z
      @width, @height = 0, 0
      @buffer = ""
      @keyboard = nil

      init_bitmaps
      create_sprites
      setup
    end

    def char_width
      4
    end

    def line_height
      16
    end

    def init_bitmaps
      @title_bmp  = nil
      @tail_bmp   = nil
      @buffer_bmp = nil
    end

    def create_bitmaps
      @title_bmp = Bitmap.new(@width, Metric.ui_element_sml)
      @tail_bmp  = @title_bmp.dup
      @buffer_bmp = Bitmap.new(@width, @height - @title_bmp.height -
                                                 @tail_bmp.height)
    end

    def create_sprites
      @title_sp   = Sprite.new(@viewport)
      @tail_sp    = Sprite.new(@viewport)
      @buffer_sp  = Sprite.new(@viewport)
    end

    def moveto(x, y, z)
      self.x, self.y, self.z = x, y, z
    end

    def resize(width, height)
      @width, @height = width, height
      create_bitmaps
    end

    def setup
      dispose_bitmaps
      resize(@cols * char_width, @rows * line_height)
      refresh
      update_bitmaps
      update_position
    end

    def refresh_title
      bmp = @title_bmp
      bmp.fill(Palette['merio_red'])
      bmp.font.set_style("sys_h4_light_enb")
      bmp.font.outline = false
      bmp.draw_text(@title_bmp.rect.contract(anchor: 5, amount: Metric.contract),
                    "Cedar V %s" % Cedar::VERSION, 0)
    end

    def refresh_tail
      bmp = @tail_bmp
      bmp.fill(Palette['merio_red'])
      bmp.font.set_style("sys_h4_light_enb")
      bmp.font.outline = false
      bmp.draw_text(@tail_bmp.rect.contract(anchor: 5, amount: Metric.contract),
                    "Chars[%d x %d] Dimensions[%d x %d]" % [@cols, @rows, @width, @height], 0)
    end

    def refresh_buffer
      bmp = @buffer_bmp
      bmp.clear
      bmp.font.set_style("cedar_text")
      bmp.font.outline = false
      bmp.fill(Palette['droid_dark_ui_enb'])
      x = Metric.contract
      w = bmp.width - Metric.contract * 2
      @buffer.each_line.each_with_index do |l, i|
        bmp.draw_text(x, line_height * i, w, line_height, l.gsub("\n", ""), 0)
      end
    end

    def refresh
      refresh_buffer
      refresh_title
      refresh_tail
    end

    def x=(new_x)
      @x = new_x.to_i
      [@title_sp, @tail_sp, @buffer_sp].each { |s| s.x = @x }
    end

    def y=(new_y)
      @y = new_y.to_i
      [@title_sp, @tail_sp, @buffer_sp].each { |s| s.y = @y }
    end

    def z=(new_z)
      @z = new_z.to_i
      [@title_sp, @tail_sp, @buffer_sp].each { |s| s.z = @z }
    end

    def viewport=(new_viewport)
      @viewport = new_viewport
      [@title_sp, @tail_sp, @buffer_sp].each { |s| s.viewport = @viewport }
    end

    def dispose_sprites
      @title_sp.dispose
      @tail_sp.dispose
      @buffer_sp.dispose
      @title_sp  = nil
      @tail_sp   = nil
      @buffer_sp = nil
    end

    def dispose_bitmaps
      [@title_bmp, @tail_bmp, @buffer_bmp].each do |bmp|
        bmp.dispose if bmp && !bmp.disposed?
      end
      @title_bmp  = nil
      @tail_bmp   = nil
      @buffer_bmp = nil
    end

    def dispose
      dispose_sprites
      dispose_bitmaps
      @disposed = true
    end

    def update_position
      @buffer_sp.oy = -@title_sp.height
      @tail_sp.oy = @buffer_sp.oy - @buffer_sp.height
      move(x, y, z)
    end

    def update_bitmaps
      @title_sp.bitmap  = @title_bmp
      @tail_sp.bitmap   = @tail_bmp
      @buffer_sp.bitmap = @buffer_bmp
    end

    def update
      refresh_buffer if @keyboard.get_typing_as_str(@buffer) if @keyboard
    end

  end

  def self.run_test
    notepad = Notepad.new(nil, 0, 0, 80, 16)
    notepad.keyboard = KeyboardHandle.new

    loop do
      Main.update
      notepad.update
    end
  end
end
