$simport.r 'iek/render_manager/vxa/scene-base', '1.0.0', 'RenderManager VXA SceneBase Integration' do |d|
  d.depend 'iek/render_manager', '~> 1.0'
end

class Scene_Base
  def main
    start
    post_start
    update until scene_changing?
    pre_terminate
    terminate
  end

  def start
    @window_manager = RenderManager.new
    create_main_viewport
  end

  def post_start
    window_manager_compatability_post_start
    perform_transition
    Input.update
  end

  def window_manager_compatability_post_start
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window) && !@window_manager.include?(ivar)
        @window_manager.add(ivar)
      end
    end
  end

  def windows
    @window_manager.all
  end

  def update_all_windows
    @window_manager.update
  end

  def dispose_all_windows
    @window_manager.dispose
  end
end
