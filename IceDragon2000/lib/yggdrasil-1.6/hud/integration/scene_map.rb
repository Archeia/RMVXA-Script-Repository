class Scene_Map < Scene_Base
  @@__temp = 0

  def create_ygg_hud
    @ygg_hud = ::YGG::Handlers::Hud.new(*$game_yggdrasil.hud.get_obj_xyz(:main))
    update_ygg_hud
  end

  alias :ygg1x6_hud_start :start
  def start(*args, &block)
    ygg1x6_hud_start(*args, &block)
    create_ygg_hud
  end

  alias :ygg1x6_hud_update :update
  def update(*args, &block)
    ygg1x6_hud_update(*args, &block)
    update_ygg_hud
  end

  def update_ygg_hud
    @@__temp = $game_yggdrasil.hud.visible?
    @ygg_hud.visible = @@__temp if @ygg_hud.visible != @@__temp
    @ygg_hud.update
  end

  alias :ygg1x6_hud_terminate :terminate
  def terminate(*args, &block)
    ygg1x6_hud_terminate(*args, &block)
    unless @ygg_hud.nil?
      @ygg_hud.dispose
      @ygg_hud = nil
    end
  end
end
