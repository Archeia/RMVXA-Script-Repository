#encoding:UTF-8
# ISS004 - Particle Engine
# // 05/08/2011
# // 05/08/2011
$imported = {} if $imported == nil
$imported["ISS-ParticleEngine"] = true

module ISS

  module PTE ; end # // PTE - Particle Engine

  module PTE
    UPDATE_SPRITE_OFFSCREEN = false
    UPDATE_HANDLE_OFFSCREEN = true
    UPDATE_TIME = 0 # // Frames Between updating
  end

  class PTE::Handler_Particle < ::ISS::Pop_Handler

    include BitmapXtended

    def drawing_bitmap ; return self.bitmap            end
    def pallete_bitmap ; return Cache.system("Window") end

    def pt_reset(op=:normal, parameters=[])
      case op
      when :rand
        @cap_duration = parameters[0] + rand(parameters[0] - parameters[1])
      end
      reset()
    end

    def phase_color()
      color = normal_color
      r1 = (@cap_duration * 75 / 100)..@cap_duration
      r2 = (@cap_duration * 50 / 100)..@cap_duration
      r3 = (@cap_duration * 25 / 100)..@cap_duration
      r4 = (@cap_duration * 10 / 100)..@cap_duration
      case @pop_duration
      when r1 ; color = IEO::Colors::Blue #IEO::Colors::White
      when r2 ; color = IEO::Colors::LightBlue #IEO::Colors::Yellow
      when r3 ; color = IEO::Colors::Red
      when r4 ; color = IEO::Colors::DarkBlue #IEO::Colors::Black
      end
      return color
    end

    def phase_opacity
      pp = (@pop_duration.to_f / @cap_duration.to_f) * 100
      return ((255*2) * pp / 100)
    end

  end

  class PTE::Sprite_Particle < ::Sprite_Base

    def initialize(parent, pt_count)
      @update_off_screen_handle = ::ISS::PTE::UPDATE_HANDLE_OFFSCREEN
      @update_off_screen_sprite = ::ISS::PTE::UPDATE_SPRITE_OFFSCREEN
      @max_wait_count = ::ISS::PTE::UPDATE_TIME
      @wait_count     = 0
      super(parent.viewport)
      @parent         = parent
      @particle_count = pt_count
      @particles      = []
      @px_width       = 32
      @px_height      = 32
      self.bitmap = Bitmap.new(@px_width, @px_height)
      self.blend_type = 1
      @particle_count.times { |i|
        @particles[i] = ::ISS::PTE::Handler_Particle.new(@px_width/2, @px_height)
        #next
        @particles[i].x_velocity = 0.4
        @particles[i].y_velocity = 1.2
        @particles[i].x_boost    = 2
        @particles[i].y_boost    = 6
        @particles[i].x_add      = 0
        @particles[i].y_add      = 2
        @particles[i].gravity    = 0.58
        @particles[i].floor_val  = 0
        @particles[i].pt_reset()
      }
    end

    def dispose
      super()
      self.bitmap.dispose() unless self.bitmap.nil?()
      @particles.clear()
    end

    def update()
      super
      self.x = @parent.x - ((@px_width).abs / 2)
      self.y = @parent.y - (@parent.src_rect.height + @px_height) + 10
      self.z = @parent.z + 10
      @wait_count -= 1 unless @wait_count == 0
      return if @wait_count > 0
      @wait_count = @max_wait_count
      self.bitmap.clear()
      @particles.each { |pt|
        next if (off_screen?() && !@update_off_screen_handle)
        pt.update()
        unless (off_screen?() && !@update_off_screen_sprite)
          s = 1+rand(2)
          rect = Rect.new(pt.x + pt.ox, pt.y + pt.oy, s, s)
          cc = pt.phase_color()
          cc.alpha = pt.phase_opacity()
          self.bitmap.fill_rect(rect , cc)
        end
        if pt.finished
          pt.pt_reset(:rand, [40, 80])
        end
      }
    end

    def off_screen?()
      return false
    end

  end

end

class Sprite_Character < Sprite_Base

  def setup_pt()
    return unless @pt_engine.nil?
    @pt_engine = ::ISS::PTE::Sprite_Particle.new(self, 16)
    @pt_active = true
  end

  alias iss004_spc_dispose dispose unless $@
  def dispose()
    iss004_spc_dispose()
    dispose_pt_engine
  end

  def dispose_pt_engine
    @pt_engine.dipose() unless @pt_engine.nil?()
    @pt_engine = nil
    @pt_active = false
  end

  alias iss004_spc_update update unless $@
  def update()
    iss004_spc_update()
    update_pt_engine
  end

  def update_pt_engine
    if @character.pt_engine && !@pt_active
      setup_pt()
    elsif !@character.pt_engine && @pt_active
      dispose_pt_engine
      return
    end
    @pt_engine.update() unless @pt_engine.nil?()
  end

end

class Game_Character

  attr_accessor :pt_engine

end
