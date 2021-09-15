#
# EDOS/lib/module/color_tool/colorf.rb
#   by IceDragon
#   dc ??/03/2013
#   dm 27/03/2013
# vr 1.1.0
module ColorTool
  class ColorF
    ### instance_attributes
    attr_reader :red, :green, :blue, :alpha

    ##
    # to_a -> Array<Float>[red, green, blue, alpha]
    def to_a
      return red, green, blue, alpha
    end

    ##
    # to_h -> Hash<Symbol[red, green, blue, alpha], Float>
    def to_h
      return { red: red, green: green, blue: blue, alpha: alpha }
    end

    ##
    # red=(Float new_red)
    def red=(new_red)
      @red = [[new_red, 0.0].max, 1.0].min.to_f
    end

    ##
    # green=(Float new_green)
    def green=(new_green)
      @green = [[new_green, 0.0].max, 1.0].min.to_f
    end

    ##
    # blue=(Float new_blue)
    def blue=(new_blue)
      @blue = [[new_blue, 0.0].max, 1.0].min.to_f
    end

    ##
    # alpha=(Float new_alpha)
    def alpha=(new_alpha)
      @alpha = [[new_alpha, 0.0].max, 1.0].min.to_f
    end

    ##
    # set(*args)
    def set(*args)
      case args.size
      when 0
        r, g, b, a = 0.0, 0.0, 0.0, 0.0
      when 1
        arg, = args
        case arg
        when Array
          r, g, b, a = *arg
          a ||= 1.0
        when Color
          r, g, b, a = *arg.to_a
          r /= 255.0
          g /= 255.0
          b /= 255.0
          a /= 255.0
        when ColorF
          r, g, b, a = *arg.to_a
        end
      when 3, 4
        r, g, b, a = *args
        a ||= 1.0
      end
      self.red   = r
      self.green = g
      self.blue  = b
      self.alpha = a
    end

    ### aliases
    alias :initialize :set
    ### visibility
    private :initialize
  end
end
