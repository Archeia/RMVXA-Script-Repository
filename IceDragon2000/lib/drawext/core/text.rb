#
# EDOS/lib/drawext/core/text.rb
#
module DrawExt
  class Text
    attr_accessor :string
    attr_accessor :font

    def initialize(string)
      @string = string
      @font = Font.new
      yield self if block_given?
    end

    def text_size
      Size2.new(*@font.text_size(@string))
    end

    def to_s
      @string.to_s
    end
  end

  def self.draw_text(bitmap, rect, text, align=0)
    bitmap.font.snapshot do |font|
      font.set(text.font)
      bitmap.draw_text(rect, text.string, align)
    end
  end
end
