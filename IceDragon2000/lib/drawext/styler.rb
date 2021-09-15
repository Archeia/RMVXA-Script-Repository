#
# EDOS/lib/artist/drawext/styler.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 27/03/2013
#   dm 27/03/2013
# vr 1.0.1
module DrawExt
  class Styler
    @@stylers = {}

    attr_reader :id, :stack

    def initialize(id, *stack, &style_func)
      @id = id
      @stack = stack
      @style_func = style_func
    end

    def apply(color, *args)
      if @style_func
        apply_style_func(color, *args)
      else
        apply_style_stack(color, *args)
      end
    end

    def apply_style_func(color, *args)
      colors = @style_func.call(color, *args).compact
      if !colors or colors.empty?
        raise(ArgumentError, "Style func failed to return required colors")
      end
      return colors
    end

    def apply_style_stack(color, *args)
      @stack.map do |(func_sym, params)|
        case func_sym
        when Symbol, String
          color.send(func_sym, *params)
        when Proc
          func_sym.(color, params, args)
        else
          color.dup
        end
      end
    end

    class << self
      alias :org_new :new
    end

    def self.new(*args, &block)
      object = org_new(*args, &block)
      @@stylers[object.id] = object
      return object
    end

    def self.styler(style_id)
      @@stylers[style_id]
    end
  end
end
