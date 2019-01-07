class Window_BattleLog < Window_Selectable
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    b_name = contents.font.name
    b_size = contents.font.size
    contents.font.name = item.fontname
    contents.font.size = item.fontsize
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
    contents.font.name = b_name
    contents.font.size = b_size
  end
end