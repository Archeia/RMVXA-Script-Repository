#
# EDOS/lib/drawext/border.rb
#   by IceDragon
#   dc 07/06/2013
#   dm 07/06/2013
# vr 1.0.0
module DrawExt
  BorderSettings = Struct.new(:anchor, :expand_size)

  def self.border_settings
    @border_settings ||= BorderSettings.new(MACL::Surface::ANCHOR_NW, 4)
  end

  def self.border_state_stack
    (@border_state_stack ||= [])
  end

  def self.restore_border
    @border_state = !!border_state_stack.pop
  end

  def self.snap_border
    border_state_stack.push(@border_state)
    if block_given?
      yield self
      restore_border
    end
  end

  def self.toggle_border(state)
    if block_given?
      snap_border do |*args|
        @border_state = state
        yield *args
      end
    else
      snap_border
      @border_state = state
    end
  end

  def self.enable_border(&block)
    toggle_border(true, &block)
  end

  def self.disable_border
    toggle_border(false, &block)
  end

  def self.calc_border_rect(rect)
    #return Rect.cast(rect) # disabled
    stt = border_settings
    return Convert.Rect(rect).expand(amount: stt.expand_size, anchor: stt.anchor)
  end

  def self.default_border_func(bmp, rect)
    nrect = calc_border_rect(rect)
    #bmp.blend_fill_rect(nrect, Merio.main_palette[:dark_ui_enb])
    return nrect
  end

  ##
  # ::border_func -> Proc
  def self.border_func
    @border_func || method(:default_border_func)
  end

  ##
  # ::border_func_set(Proc func)
  # ::border_func_set { |Bitmap bmp, Rect rect| return_new_rect }
  def self.border_func_set(func=nil, &blck)
    @border_func = func || blck
  end

  def self.draw_border(bmp, rect)
    rect = Convert.Rect(rect)
    (func = border_func) ? func.(bmp, rect) : rect
  end
end
