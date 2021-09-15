class Integer
  def flagged?(flag)
    if flag == 0
      self == 0
    else
      (self & flag) == flag
    end
  end
end
