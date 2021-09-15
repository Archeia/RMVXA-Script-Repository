##
# WindowManager is employed by the Scene classes which require Window objects.
# This class aims to provide the collection and management of mulitple windows,
# or window like objects
class WindowManager
  include Enumerable

  attr_reader :windows
  attr_reader :viewport

  def initialize(viewport)
    @windows  = []
    @viewport = viewport
    @disposed = false
    @tasks = []
  end

  def each(&block)
    @windows.each(&block)
  end

  def new_task(func = nil, &block)
    @tasks << (func || block)
  end

  def disposed?
    @disposed
  end

  def dispose
    for window in @windows
      window.dispose
    end
    @windows = nil
    @disposed = true
  end

  def update_windows
    for window in @windows
      window.update
    end
  end

  ##
  # Calls each task in the @tasks Array
  # A task is removed if its call evaluates to false
  def update_tasks
    if @tasks.size > 0
      dead_tasks = []
      for task in @tasks
        dead_tasks << task unless task.call
      end
      @tasks -= dead_tasks unless dead_tasks.empty?
    end
  end

  def update
    update_windows
    update_tasks
  end

  def setup
    yield self
    reorder_windows
  end

  def handle_event(event)
    @windows.each_with_object(event, &:handle_event)
  end

  def add(window)
    window.window_manager = self
    window.viewport = @viewport
    @windows << window unless @windows.include?(window)
  end

  def delete(window)
    @windows.delete(window)
    window.window_manager = nil
    window.viewport = nil
  end

  def reorder_windows
    @windows.sort_by!(&:z)
  end

  def swap_windows(i1, i2)
    w1, w2 = @windows[i1], @windows[i2]
    @windows[i1], @windows[i2] = w2, w1
    ###
    w1.z, w2.z = w2.z, w1.z if w2 && w1
    @windows.compact!
  end

  def tile(canvas = @viewport.rect)
    MACL::Surface::Tool.tile_surfaces(@windows, canvas)
  end

  def bring_forward(window)
    i = @windows.index(window)
    swap_windows(i, i.next)
  end

  def send_backward(window)
    i = @windows.index(window)
    swap_windows(i, i.pred)
  end

  def bring_to_front(window)
    i = @windows.index(window)
    i.upto(@windows.size) { |n| swap_windows(n, n.next) }
  end

  def send_to_back(window)
    i = @windows.index(window)
    i.downto(0) { |n| swap_windows(n, n.pred) }
  end

  def delay_dispose(window)
    new_task do
      !window.automating? ? (delete(window); window.dispose; false) : true
    end
  end

  def viewport=(v)
    @viewport = v
    @windows.each_with_object(@viewport, :viewport=)
  end

  private :update_windows
  private :update_tasks
end
