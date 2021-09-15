module Mixin
  class OrphanClient < RuntimeError
  end

  module WindowClient
    attr_accessor :window_manager

    def automove_time
      Metric::Time.sec_to_frame(0.25)
    end

    def automove_easer
      MACL::Easer::Back::Out
    end

    def automove_argv(*args)
      case args.size
      when 1 # preset
        case args.first
        when :left  then x, y = -width, 0
        when :right then x, y = width, 0
        when :up    then x, y = 0, -height
        when :down  then x, y = 0, height
        else             raise ArgumentError, "invalid preset #{args.first}"
        end
      when 2 # x, y
        x, y = args
      when 3 # x, y, time
        x, y, t = args
      when 4 # x, y, time, easer
        x, y, t, e = args
      end
      t ||= automove_time
      e ||= automove_easer
      return x, y, t, e
    end

    def automove(*args)
      ax, ay, t, e = *automove_argv(*args)
      add_automation(Automation::Move.new(pos, pos + [ax, ay], t, e))
    end

    def automoveto(*args)
      ax, ay, t, e = *automove_argv(*args)
      add_automation(Automation::Moveto.new(pos, Vector2.new([ax, ay]), t, e))
    end

    def check_window_manager
      unless @window_manager
        raise OrphanClient, "#{self} is orphaned. Cannot access window_manager"
      end
    end

    def bring_forward
      check_window_manager
      @window_manager.bring_forward(self)
    end

    def send_backward
      check_window_manager
      @window_manager.send_backward(self)
    end

    def bring_to_front
      check_window_manager
      @window_manager.bring_to_front(self)
    end

    def send_to_back
      check_window_manager
      @window_manager.send_to_back(self)
    end

    private :automove_argv
  end
end
