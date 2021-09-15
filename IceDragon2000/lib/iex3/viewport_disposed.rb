class Viewport
  alias :dispose_wo_flag :dispose
  def dispose
    dispose_wo_flag
    @disposed = true
  end

  def disposed?
    !!@disposed
  end
end
