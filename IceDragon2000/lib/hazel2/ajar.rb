#
# EDOS/lib/mixin/ajar.rb
#   by IceDragon
#
# vr 1.0.0
module Mixin
  module Ajar
    def open?
      self.openness >= 255
    end

    def close?
      self.openness <= 0
    end

    def ajar?
      return automating?(:ajar)
    end

    def autoajar(*args)
      case args.size
      when 1
        arg, = args
        s, d =  case arg
                when :open        then [self.openness, 255]
                when :close       then [self.openness, 0]
                when :force_open  then [0, 255]
                when :force_close then [255, 0]
                when :hard_open   then [255, 255]
                when :hard_close  then [0, 0]
                end
      when 2, 3, 4
        s, d, t, e = *args
      else
        raise ArgumentError,
              "expected 1, 2, 3, or 4 arguments but recieved #{args.size}"
      end
      t ||= Metric::Time.sec_to_frame(0.18)
      e ||= MACL::Easer::Expo::In
      add_automation(Automation::Ajar.new(s, d, t, e))
      self
    end

    def open
      Sound.play_window_open # //
      autoajar(:open)
      self
    end

    def close
      Sound.play_window_close # //
      autoajar(:close)
      self
    end

    def openness_rate
      self.openness / 255.0
    end

    def open_height
      openness_rate * height
    end

    def open_y1
      y + open_y1_abs
    end

    def open_y2
      y + open_y2_abs
    end

    def open_y1_abs # // Bare
      (height / 2.0) - (open_height / 2.0)
    end

    def open_y2_abs # // Bare
      height - open_y1_abs
    end

    def open_y
      open_y1
    end
  end
end
