class Artist::RogueStatus < Artist

  # // 02/27/2012
  def draw_actor_parameters_ex(actor, x, y, w=64, h=14, col=1, params=0...8)
    ps = params.to_a
    for i in 0...ps.size
      draw_parameter(actor,x+((i%col)*w),y+((i/col)*h),ps[i])
    end
  end

  # //
  # // 03/04/2012
  def draw_tiny_actor(actor,x,y,h=nil)
    draw_tiny_character(
      character_name: actor.character_name,
      character_index: actor.character_index,
      character_hue: actor.character_hue,
      x: x + 16,
      y: y + 32,
      height: h
    )
  end

=begin
  # // c*   = cell*
  # // data = {rate:Float(0.0..1.0),color:Color}
  def draw_table(data, x, y, cwidth, cheight, spacing=0, orn=0)
    dx, dy = nil,nil
    data.each_with_index do |hsh,i|
      rate, color = hsh.get_values(:rate, :color)
      case(orn)
      when 0 # // Horz
        dx = x
        dy = y + ((cheight+spacing)*i)
      when 1 # // Vert
        dx = x + ((cwidth+spacing)*i)
        dy = y
      end

      draw_gauge_ext_sp2(
        Rect.new(dx, dy, cwidth, cheight), rate.clamp(0.0, 1.0),
        DrawExt.quick_bar_colors(color), orn == 1, orn == 1
      )

      yield dx, dy, cwidth, cheight, i, hsh if(block_given?())
    end
  end

  def draw_actor_element_rate(actor,element_id,x,y,width=128,enabled=true)
    draw_element_rate(
      element_id, actor.element_rate(element_id),
      x, y, width, enabled)
  end

  def draw_element_rate(element_id,rate,x,y,width=128,enabled=true)
    r = draw_element_icon(element_id,x,y,enabled)
    r.offset!(anchor: 6, rate: 1.0)
    r.width = width - r.width
    r2 = r.squeeze(anchor: 28, amount: (r.height * 0.50).to_i)
    r3 = r2.dup

    mrate = (rate / 2.0)
    c = element_color(element_id).add((mrate - 1.0).clamp(0.0, 1.0))
    divs = 20
    spacing = 1
    bpadding = 1 # // Bar Padding . x .
    #r3.height *= 0.3 # // 4 :get_bar4_bar 4win XD
    r3.height *= 0.70
    bw = DrawExt.adjust_size4bar3(r3.width,divs,spacing,bpadding)
    bh = DrawExt.adjust_size4bar4(r3.height,bpadding)
    r3.y -= bh - r3.height
    ext_draw_bar2(
      {
      x: r3.x,
      y: r3.y,
      width: bw,
      height: bh,
      rate: mrate.clamp(0.0, 1.0),
      divisions: divs,
      spacing: spacing,
      padding: bpadding,
      #barseg_method: DrawExt.method(:get_bar1_bar)
      }.merge(DrawExt.quick_bar_colors(c))
    )
    draw_ruler(r3.x, r3.y, bw, bh*0.8, divs, 5)
    #contents.fill_rect(r4,element_rate_color(element_id,rate.ceil)) if mrate > 0
    text = format("Weakness: %.2fx",(rate.round(2))) # R: 1.00
    r4 = r2.offset(anchor: 8, rate: 1.0)
    r4.width = bw

    drawing_sandbox do
      contents.font.set_style('simple_black')
      contents.draw_text(r4,Vocab.element(element_id),0) #rescue nil
      contents.draw_text(r4,text,2) #rescue nil
    end
    return r
  end



  def draw_ruler(x,y,w,h,divs,sca=2,orn=0,c=Palette['black'].hset(alpha:198))
    case(orn)
    when 0 ; sp = w / divs
    when 1 ; sp = h / divs
    end
    dw, dx, dh, dy = [nil]*4
    for i in 0..divs
      long = (i % sca == 0)
      case(orn)
      when 0
        dh = long ? h : h * 0.6
        dy = long ? y : y + (h-dh)
        contents.fill_rect(x+(i*sp),dy,1,dh,c)
      when 1
        dw = long ? w : w * 0.6
        dx = long ? x : x + (w-dw)
        contents.fill_rect(dx,y+(i*sp),dw,1,c)
      end
    end
  end
=end

end
