module DrawExt
  def self.adjust_size4bar3(size, divs, spacing, padding)
    (((size / divs.to_f()).ceil * divs) + (divs * spacing) + (padding * 2)).to_i
  end

  def self.adjust_size4bar4(size, padding)
    adjust_size4bar3(size, 4, 0, padding)
  end
end
