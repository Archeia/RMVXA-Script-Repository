$simport.r 'iek/render_manager', '1.0.0', 'AKA. Window Manager'

class RenderManager
  include Enumerable

  def initialize
    @elements = []
    @state_cache = []
    @ticks = 0
    @disposed = false
  end

  def all
    @elements.to_a
  end

  def each(&block)
    @elements.each(&block)
  end

  def clear
    @elements.clear
  end

  def add(element)
    @elements.push(element)
  end

  def remove(element)
    @elements.delete(element)
  end

  def include?(element)
    @elements.include?(element)
  end

  def sort!(*args, &block)
    @elements.sort!(*args, &block)
  end

  def sort_by!(*args, &block)
    @elements.sort_by!(*args, &block)
  end

  #
  # @param [Symbol] attrs
  # @return [Array<[Object, Hash<Symbol, Object>]>]
  def save_list(*attrs)
    list = []
    @elements.each do |element|
      list.push([element, attrs.each_with_object({}) do |sym, state|
        state[sym] = element.send(sym)
      end])
    end
    list
  end

  #
  # @param [Symbol] attrs
  # @return [Array[self, Array<[Object, Hash<Symbol, Object>]>]]
  def save(*attrs)
    @state_cache << save_list(*attrs)
    if block_given?
      yield self
      restore
    end
    return self, list
  end

  def restore_list(list)
    list.each do |element, state|
      state.each do |key, value|
        element.send("#{key}=", value)
      end
    end
  end

  def restore
    list = @state_cache.pop
    restore_list(list) if list
    return self, list
  end

  def dispose
    @elements.each(&:dispose)
    @disposed = true
  end

  def disposed?
    !!@disposed
  end

  def update
    @elements.each(&:update)
    @ticks += 1
  end

  private :save_list
  private :restore_list
end
