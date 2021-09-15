class Scene_Skill
  alias :terminate_wo_viewport :terminate
  def terminate
    terminate_wo_viewport
    @viewport.dispose
  end
end
