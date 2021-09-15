$simport.r "iek/scene_loading", "1.0.0", "Loading scene stub"

class Scene_Loading < Scene_Base
  ##
  # @return [Void]
  def start
    super
    @ticks = 0
    create_elements

    @done_loading = false

    @prep_thread = Thread.new { do_loading }
    @prep_thread.abort_on_exception = true
  end

  ###
  # @return [Boolean]
  def return_scene?
    @done_loading
  end

  ##
  # @return [Void]
  def create_elements
    # Put any sprite/window and other graphic creation here
  end

  ##
  # @return [Void]
  def terminate
    dispose_elements
    super
  end

  ##
  # @return [Void]
  def dispose_elements
    # dispose your created elements here
  end

  ##
  # @return [Void]
  def finish_loading
    @done_loading = true
  end

  ##
  # this is the method you will write all your code in, always call finish_loading
  # at the end, else the loading will continue without stopping.
  def do_loading
    #
    finish_loading
  end

  ##
  # @return [Void]
  def update
    return return_scene if return_scene?
    super
    update_elements
    @ticks += 1
  end

  ##
  # @return [Void]
  def update_elements
    # update your created elements here
  end
end
