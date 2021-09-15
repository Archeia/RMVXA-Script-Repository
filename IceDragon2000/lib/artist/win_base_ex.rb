# Artist (Window::Base(Ex))
# // 03/05/2012
# // 03/05/2012
class Artist

  def draw_text(*args)
    contents.draw_text(*args)
  end

# // Window::Base (Ex)
  def kcolor(n)
    case n
    when 0 then Palette['brown1']
    when 1 then Palette['sys_red1'].add(0.3)
    when 2 then Palette['sys_green1'].add(0.3)
    when 3 then Palette['sys_blue1'].add(0.3)
    when 4 then Palette['sys_orange1'].add(0.3)
    #when 5  ; Palette['sys_orange']
    end
  end

  def draw_item_durability(item,rect)
    return unless ExDatabase.ex_equip_item?(item)
    rect, rate = rect, item.durability_rate
    colors = DrawExt.quick_bar_colors(Palette['sys1_orange'])

    draw_gauge_ext(rect, rate, colors)

    return self;
  end

  def draw_item_element_res(item, x, y, w = 96, h = 6)
    return unless ExDatabase.ex_equip_item?(item)
    for i in 1..6 # // . x . Only the 6 main elements
      rect = Rect.new(x, y + (h * (i - 1)), w, h)
      rate = item.element_residue_rate(i)
      colors = DrawExt.quick_bar_colors(element_color(i))
      draw_gauge_ext(rect, rate, colors)
    end
  end

  def draw_item_exp(item,x,y,w=128,h=16)
    return unless ExDatabase.ex_equip_item?(item)
    draw_entity_exp(item, Rect.new(x, y, w, h))
  end

  def draw_item_name(item,x,y,w=128,h=12)
    contents.font.save do
      contents.font.set_style('simple_black')
      #contents.font.name = ["Microsoft YaHei"]
      contents.font.size += 4
      draw_text( x, y, w, h, item ? item.name : "" )
    end
  end

  def draw_item_description(item, x, y, w=contents.width, h=14)
    contents.font.save do
      contents.font.set_style('text_help')
      draw_text( x, y, w, h, item ? item.description : "" )
    end
  end

  def draw_item_parameters(item,x,y,col=4)
    return if item.nil?
    return unless ExDatabase.equip_item?(item)
    params = item.params.dup
    if @battler
      params = @battler.mk_temp_self.mk_params_for(item)
    end
    for i in 0...8
      draw_parameter_i(params[i], x + ((i % col) * 64), y + ((i / col) * 12), i)
    end
  end

end
