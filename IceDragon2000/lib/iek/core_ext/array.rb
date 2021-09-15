class Array
  ##
  # @param [Array] array
  # @param [Symbol] method
  #   Big Thanks to havenwood on Freenode #ruby for this one
  def zip_map(array, method)
    zip(array).map { |pair| pair.inject method }
  end

  def presence
    empty? ? nil : self
  end

  def blank?
    empty? ? true : false
  end
end
