module MapEditor3
  class Cursor
    attr_accessor :x
    attr_accessor :y
    attr_accessor :order_to_move_dir
    attr_accessor :order_to_interact
    # callbacks
    attr_accessor :on_act
    attr_accessor :on_move

    def initialize
      @x = 0
      @y = 0
      @order_to_move_dir = 0
      @order_to_interact = false
      # timers
      @timer = FrameTimer.new(7)
      # callbacks
      @on_act = nil
      @on_move = nil
    end

    # alias for x
    def real_x
      @x
    end

    # alias for y
    def real_y
      @y
    end

    def screen_x
      @x * 32
    end

    def screen_y
      @y * 32
    end

    def screen_z
      400
    end

    def movable?
      @timer.done?
    end

    def clamp_x(x)
      x
    end

    def clamp_y(y)
      y
    end

    def moveto(x, y)
      @x = clamp_x(x)
      @y = clamp_y(y)
      @on_move.call if @on_move
    end

    def move(x, y)
      moveto(@x + x, @y + y)
    end

    def move_straight(dir)
      case dir
      when 2
        move(0, 1)
      when 4
        move(-1, 0)
      when 6
        move(1, 0)
      when 8
        move(0, -1)
      end
      @timer.reset
    end

    def interact
      @on_act.call if @on_act
    end

    def reset_temp_variables
      @order_to_move_dir = 0
      @order_to_interact = false
    end

    def update
      if movable?
        move_straight(@order_to_move_dir) if @order_to_move_dir > 0
      end
      interact if @order_to_interact
      reset_temp_variables
      @timer.update
    end
  end

  class RectCursor < Cursor
    attr_accessor :rect

    def initialize
      super
      @rect = Rect.new(0, 0, 1, 1)
    end

    def clamp_x(x)
      [[x, @rect.width - 1].min, 0].max
    end

    def clamp_y(y)
      [[y, @rect.height - 1].min, 0].max
    end
  end

  class MapCursor < Cursor
    attr_accessor :map

    def screen_x
      @map.adjust_x(@x) * 32 #+ 16
    end

    def screen_y
      @map.adjust_y(@y) * 32 #+ 32
    end

    def clamp_x(x)
      [[x, @map.width - 1].min, 0].max
    end

    def clamp_y(y)
      [[y, @map.height - 1].min, 0].max
    end
  end
end
