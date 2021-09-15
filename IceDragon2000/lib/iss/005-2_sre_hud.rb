#encoding:UTF-8
# ISS005 - SRE (Hud)
module ISS

  module SRE ; end

  class SRE::Window_ResourceHud < ::Window_Base

    def initialize(varset)
      super(0, 0, 192, 56)
      self.opacity = 0
      @last_value  = -1
      @last_max    = -1
      @varset = varset
    end

    def update
      super
      val = $game_variables[@varset[0]]
      max = $game_variables[@varset[1]]
      unless (@last_max == max && @last_value == val)
        self.contents.clear
        rect = Rect.new(32, 4, 128, 10)
        draw_horizontal_grad_bar(rect, val, max, hp_gauge_color1, hp_gauge_color2) if max > 0
        self.contents.draw_text(4, 0, self.contents.width-32, 24, val, 2)
        @last_max   = max
        @last_value = val
      end
    end

  end

end

class Scene_Map < Scene_Base

  alias iss005_scmp_start start unless $@
  def start
    iss005_scmp_start()
    @resource_hud = ::ISS::SRE::Window_ResourceHud.new([20, 19])
    @resource_hud2 = ::ISS::SRE::Window_ResourceHud.new([15, 16])
    @resource_hud2.y += 56
  end

  alias iss005_scmp_terminate terminate unless $@
  def terminate
    iss005_scmp_terminate()
    @resource_hud.dispose unless @resource_hud.nil?
    @resource_hud2.dispose unless @resource_hud2.nil?
  end

  alias iss005_scmp_update update unless $@
  def update
    iss005_scmp_update()
    @resource_hud.update unless @resource_hud.nil?
    @resource_hud2.update unless @resource_hud2.nil?
  end

end


