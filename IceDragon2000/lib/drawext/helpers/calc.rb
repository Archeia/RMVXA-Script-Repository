module DrawExt
  ##
  # calc_rescale_divs_by_rate(Hash divs, float div_rate, length_rate)
  #
  def self.calc_rescale_rule_div_by_rate(divs, div_rate, length_rate)
    new_divs = Hash[divs.map do |(k, v)|
      nv = v.dup
      nv[:l] *= length_rate
      [(k * div_rate).to_i, nv]
    end]
    return new_divs
  end

  ##
  # calc_rescale_divs(int target_length, int orig_length, Hash divs)
  #
  def self.calc_rescale_rule_div(divs, org_box, trg_box)
    dr = trg_box.width.to_f / org_box.width.to_f
    lr = trg_box.height.to_f / org_box.height.to_f
    return calc_rescale_rule_div_by_rate(divs, dr, lr)
  end

  ##
  # calc_normalize_colors(Color[] colors)
  #
  def self.calc_normalize_colors(*colors)
    result = colors.inject([0, 0, 0, 0]) do |r, col|
      r[0] += col.red
      r[1] += col.green
      r[2] += col.blue
      r[3] += col.alpha

      r
    end

    sz = colors.size
    result.map! do |i| i / sz end

    return Color.new(*result)
  end

  def self.calc_color_diff(color1, color2, rate=0.0)
    return color1.lerp(color2, rate)
  end

  def self.calc_hash_color_diff( set1, set2, rate=0.0 )
    result = {}
    (set1.keys | set2.keys).each { |key|
      color1 = set1[key]
      color2 = set2[key]

      # flip-flop
      color1 ||= color2 || Color.new(0, 0, 0, 255)
      color2 ||= color1 || Color.new(0, 0, 0, 255)

      result[key] = calc_color_diff(color1, color2, rate)
    }
    return result
  end
end
