class Window_Status
  attr_reader :actor

  def initialize(actor, options = {})
    if rect = options[:rect]
      x, y, w, h = *rect
    else
      x = options.fetch(:x, 0)
      y = options.fetch(:y, 0)
      w = options.fetch(:width, Graphics.width)
      h = options.fetch(:height, Graphics.height)
    end
    super(x, y, w, h)

    @actor = actor

    refresh
    activate
  end

  def standard_padding
    0
  end

  def update_bottom_padding
    self.bottom_padding = 0
  end

  remove_method :draw_block1
  remove_method :draw_block2
  remove_method :draw_block3
  remove_method :draw_block4
  remove_method :draw_horz_line
  remove_method :draw_basic_info
  remove_method :line_color
  remove_method :draw_parameters
  remove_method :draw_exp_info
  remove_method :draw_equipments
  remove_method :draw_description

  def refresh
    contents.clear
    lrect = contents.to_rect.to_layout
    _w, _h = contents.width, contents.height
    cols, rows = 30, 16
    cols /= 2
    _cw = lrect.cell_width(1, cols)     # cell-width
    _ch = lrect.cell_height(1, rows)    # cell-height
    xp = lrect.cell_width(0.125, cols)  # x-point size
    yp = lrect.cell_height(0.125, rows) # y-point size
    _x, _y = _cw, (_ch * 0.5).to_i

    # Actor Name
    x = _x
    y = _y
    draw_actor_name(actor, x, y, _w - x)

    # Parameters
    x = _cw * 8
    w = _cw * 4
    draw_text(x, y,       w, _ch, "STR:")
    draw_text(x, y + _ch * 1, w, _ch, "MGC:")
    draw_text(x, y + _ch * 2, w, _ch, "AGI:")
    draw_text(x, y + _ch * 3, w, _ch, "VIT:")
    x += w
    w = _cw * 2
    draw_text(x, y,       w, _ch, actor.atk)
    draw_text(x, y + _ch * 1, w, _ch, actor.mat)
    draw_text(x, y + _ch * 2, w, _ch, actor.agi)
    draw_text(x, y + _ch * 3, w, _ch, actor.def)

    # HP Gauge
    x = _cw
    y += _ch * 5
    w = _cw * 13
    draw_text(x, y, w, _ch, "MAXHP:")
    draw_text(x, y, w, _ch, actor.hp, Text::Align::RIGHT)
    h = (_ch * 0.5).to_i
    y += _ch * 1
    contents.fill_rect(x, y, w, h, Color.new(255, 255, 255, 255))
    contents.clear_rect(x+xp, y+yp, w-xp*2, h-yp*2)
    contents.fill_rect(x+xp, y+yp, (w-xp*2)*actor.hp_rate, h-yp*2, hp_gauge_color1)
    y += (_ch * 0.5 + (_ch * 0.125)).to_i
    draw_text(x, y, w, _ch, "#{(100 * actor.hp_rate).to_i}%", Text::Align::RIGHT)

    # Element Graph
    y = _y + _ch * 7
    draw_text(x, y, w, _ch, "RESIST:")
    w = _cw * 4
    h = _ch * 4
    y += _ch * 1
    contents.fill_rect(x, y, w, h, Color.new(255, 255, 255, 255))
    contents.fill_rect(x+xp, y+yp, w-xp*2, h-yp*2, Color.new(0, 0, 0, 255))
    contents.fill_rect(x+xp*2, y+h/2, w-xp*4, yp, Color.new(255, 255, 255, 255))
    gh = (h - (yp * 2)) / 2
    [0.5, 0.2, -0.2, 0.2, 0.75].each_with_index do |f, i|
      if f > 0
        gy, _gh = y+h/2, (gh * f).to_i
        gy -= _gh
      else
        gy, _gh = y+h/2, (gh * -f).to_i
      end
      contents.fill_rect(x+xp*(4+(5*i)), gy, xp*3, _gh, Color.new(255, 255, 255, 255))
    end
    x = (_cw * 1.250) + w
    draw_text(x, y, w, _ch, "DRK +++")

    # Mastery
    x = _cw
    y += _ch * 5
    draw_text(x, y, w, _ch, "MASTERY:")
    y += _ch * 1.5
    draw_text(x, y, w, _ch, "Lv3")
    x += _ch * 3
    draw_text(x, y, w, _ch, "Lv2")
    x += _ch * 4.5
    draw_text(x, y, w, _ch, "Lv1")
  end
end
