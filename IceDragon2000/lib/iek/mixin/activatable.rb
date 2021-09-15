$simport.r 'iek/activatable', '1.0.0', 'Interface for custom activatable objects'

module Activatable
  attr_accessor :active

  def activate
    self.active = true
    self
  end

  def deactivate
    self.active = false
    self
  end

  def toggle(new_state = !active)
    old_state = active
    self.active = new_state
    if block_given?
      yield self
      self.active = old_state
    end
    self
  end

  def active?
    @active
  end
end
