#-// 10/07/2012
#-// 10/07/2012
$simport.r 'iei/spritix', '1.0.0', 'IEI Spritix'
#-inject gen_module_header 'IEI::Spritix'
module IEI
  module Spritix
    @@spx_funcs = {}
    def self.add_spx sym,&func
      @@spx_funcs[sym] = func
    end
    add_spx :flip_horz do |sp,*params|
      tween_struct, = params
      tweener = tween_struct.to_tween(1.0,0.0)
      tweener.update_until_done do |t|
        sp.zoom_x = t.value
        Fiber.yield
      end
      sp.mirror = !sp.mirror
      tweener = tween_struct.to_tween(0.0,1.0)
      tweener.update_until_done do |t|
        sp.zoom_x = t.value
        Fiber.yield
      end
      Fiber.yield
    end
    add_spx :fade_out do |sp,*params|
      time, = params
      until sp.opacity <= 0
        sp.opacity -= 255.0 / time
        Fiber.yield
      end
    end
    add_spx :fade_in do |sp,*params|
      time, = params
      until sp.opacity >= 255
        sp.opacity += 255.0 / time
        Fiber.yield
      end
    end
    add_spx :shake do |sp,*params|
      sp.ox
    end
    def init_spritix
      @spritix = []
    end
    def update_spritix
      @spritix.select! do |(fiber,params)|
        begin
          fiber.resume self,params
          true
        rescue
          false
        end
      end
    end
    def add_spritix sym,*params
      @spritix << [Fiber.new(&@@spx_funcs[sym]),*params]
    end
    def dispose_spritix
      @spritix.clear
    end
  end
#-inject gen_module_header 'IEI::Shell::Spritix'
  module Shell ; end
  class Shell::Spritix
    include Spritix
    attr_accessor :x, :y, :z
    attr_accessor :ox, :oy
    attr_accessor :opacity
    attr_accessor :bush_opacity
    attr_accessor :bush_depth
    attr_accessor :zoom_x, :zoom_y
    attr_accessor :src_rect
    def width
      return src_rect.width
    end
    def height
      return src_rect.height
    end
    def bitmap
    end
    def flash
    end
    def initialize
      @x, @y, @z = 0,0,0
      @ox, @oy   = 0,0
      @opacity   = 0
      @bush_opacity = 0
      @bush_depth   = 0
      @zoom_x, @zoom_y = 0,0
      @src_rect = Rect.new 0,0,0,0
      init_spritix
    end
    def update
      update_spritix
    end
    def dispose
      dispose_spritix
    end
  end
end
#-inject gen_script_footer
