class Object
  ##
  # Uses Marshal to create a perfect copy of the object
  # This does mean that, unmarshallable object will fail.
  # @return [Object]
  def marshal_clone
    Marshal.load(Marshal.dump(self))
  end unless method_defined? :marshal_clone

  def presence
    self || nil
  end

  def blank?
    presence ? true : false
  end

  def try(method = nil, *args, &block)
    if !method && block_given?
      yield self if self
    elsif method
      self.send(method, *args, &block)
    else
      presence
    end
  end
end
