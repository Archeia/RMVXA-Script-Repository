class Artist::Files < Artist
  def draw_party_characters(x, y, index)
    header = DataManager.load_header(index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 33, y)
    end
  end

  def draw_playtime(x, y, width, align, index)
    header = DataManager.load_header(index)
    return unless header
    draw_text(x, y, width, 14, header[:playtime_s], align)
  end
end
