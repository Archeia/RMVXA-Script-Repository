class String
  def presence
    empty? ? nil : self
  end

  def blank?
    empty? ? true : false
  end

  def demodulize
    path = self.to_s
    if i = path.rindex('::')
      path[(i+2)..-1]
    else
      path
    end
  end

  def indent(n)
    result = ""
    self.each_line do |line|
      result << (" " * n) +  line
    end
    result
  end
end
