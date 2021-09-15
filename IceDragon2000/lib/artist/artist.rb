class Artist
  # // Parent, commonly a window . x .
  attr_accessor :parent
  attr_writer :merio

  def initialize(parent)
    @parent = parent
    @merio = nil
  end

  # // . x. Canvas, the artist needs his bitmap
  def bitmap
    case(parent)
    when Bitmap        then parent
    when Window        then parent.contents
    when Hazel::Shell  then parent.contents
    else                    parent.bitmap
    end
  end

  ##
  # merio -> DrawExt::Merio::Context
  def merio
    if !@merio || !@merio.bitmap.equal?(bitmap)
      @merio = DrawExt::Merio::DrawContext.new(bitmap)
    end
    yield @merio if block_given?
    return @merio
  end

  ##
  # cairo -> Cairo::Context
  def cairo
    bitmap.texture.cr_context
  end

  def drawext
    DrawExt
  end

  # // . x . Just in case something needs all this
  def method_missing(sym, *args, &block)
    if parent.respond_to?(sym)
      parent.send(sym, *args, &block)
    else
      super(sym, *args, &block)
    end
  end

  def font
    return bitmap.font
  end

  def translucent_alpha
    128
  end

  def change_color(color, enabled = true)
    bitmap.font.color.set(color)
    bitmap.font.color.alpha = translucent_alpha unless enabled
    self
  end

  alias :contents :bitmap
end

require 'artist/win_base'
require 'artist/win_base_ex'
require 'artist/rogue-core'
require 'artist/overwrites'
require 'artist/draw_multiline_text'
