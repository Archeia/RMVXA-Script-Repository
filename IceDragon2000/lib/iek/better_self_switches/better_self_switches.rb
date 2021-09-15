$simport.r 'iek/better_self_switches', '1.0.0', 'Improves the functionality of default Game_SelfSwitches'

class Game_SelfSwitches
  include Enumerable

  ##
  # initialize
  def initialize
    @data = {}
  end

  ##
  # @yieldparam [Array]
  # @yieldparam [Boolean]
  def each
    return to_enum(__method__) unless block_given?
    @data.each do |key, value|
      yield key, value
    end
  end

  ##
  # on_change
  # @param [Array] id
  def on_change(id, org, now)
    # switch set callback
    $game_map.need_refresh = true # default action
  end

  ##
  # [](Array id)
  # @return [Boolean]
  def [](id)
    !!@data[id]
  end

  ##
  # []=(Array id, Boolean n)
  def []=(id, n)
    o = @data[id]
    @data[id] = !!n
    on_change id, o, @data[id]
  end

  ##
  # is switch (id) currently on?
  # @param [Array] id
  # @return [Boolean]
  def on?(id)
    self[id] == true
  end

  ##
  # is switch (id) currently off?
  # @param [Array] id
  # @return [Boolean]
  def off?(id)
    self[id] == false
  end

  ##
  # toggle(Array id)
  #   toggle the switch state
  def toggle(id)
    self[id] = !self[id]
  end

  private :on_change
end
