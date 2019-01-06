#--# Sleek Gauges v 1.0b
#
# Transform your various gauges in a variety of ways. Compatible with any
#  other script that uses the draw_gauge function... probably.
#
# Usage: Plug and play, customize as needed.
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
#--Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
module SPECIAL_GAUGES
  #Sets the default height of all bars
  DEFAULT_HEIGHT = 8
  #Set to true for static numbers (they don't count down)
  STATIC_NUMBERS = false
  #Set to true for a static bar (Slide style is ignored)
  STATIC_GAUGE = false
  #The style of the gauge. Options are :flat, :round, :slant
  GAUGE_STYLE = :slant
  #The style as the gauge changes. Options are :normal, :fancy, :fall
  GAUGE_SLIDE_STYLE = :fancy
end
 
class Window_Base < Window
  attr_accessor :gauges
  def draw_gauge(x, y, width, rate, color1, color2, height = SPECIAL_GAUGES::DEFAULT_HEIGHT)
    @gauges = {} unless @gauges
    if @gauges[[x,y]]
      @gauges[[x,y]].set_rate(rate)
    else
      @gauges[[x,y]] = Special_Gauge.new(x,y,width,rate,color1,color2,self,height)
    end
  end
  def draw_actor_hp(actor, x, y, width = 124, height = SPECIAL_GAUGES::DEFAULT_HEIGHT, notext = false)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2, height)
    @gauges[[x,y]].set_extra(Vocab::hp_a,actor.hp,actor.mhp) unless notext
  end
  def draw_actor_mp(actor, x, y, width = 124, height = SPECIAL_GAUGES::DEFAULT_HEIGHT, notext = false)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2, height)
    @gauges[[x,y]].set_extra(Vocab::mp_a,actor.mp,actor.mmp) unless notext
  end
  def draw_actor_tp(actor, x, y, width = 124, height = SPECIAL_GAUGES::DEFAULT_HEIGHT, notext = false)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2, height)
    @gauges[[x,y]].set_extra(Vocab::tp_a,actor.tp.to_i,100) unless notext
  end
  alias gauge_update update
  def update
    gauge_update
    if @gauges
      @gauges.each {|k,gauge| gauge.update}
    end
  end
end
 
class Special_Gauge
  attr_accessor :cur_val
  def initialize(x,y,w,r,c1,c2,window,height = SPECIAL_GAUGES::DEFAULT_HEIGHT)
    @x = x
    @y = y
    @width = w
    @cur_rate = r
    @max_rate = r
    @color1 = c1
    @color2 = c2
    @window = window
    @speed = 0
    @speed_rate = 0
    @height = height
    @fall_sprites = []
    refresh
  end
  def update
    update_fall_sprites
    return if @cur_rate == @max_rate && @cur_val == @set_val
    @cur_rate -= @speed_rate if @cur_rate > @max_rate
    @cur_rate += @speed_rate if @cur_rate < @max_rate
    @cur_rate = @max_rate if (@cur_rate - @max_rate).abs < @speed_rate
    @cur_rate = @max_rate if SPECIAL_GAUGES::STATIC_GAUGE
    return unless @vocab
    @cur_val -= @speed if @cur_val > @set_val
    @cur_val += @speed if @cur_val < @set_val
    @cur_val = @set_val if (@cur_val-@set_val).abs < @speed
    @cur_val = @set_val if SPECIAL_GAUGES::STATIC_NUMBERS
    refresh
  end
  def update_fall_sprites
    @fall_sprites.each do |sprite|
      if sprite.opacity < 175
        sprite.y += 1
      else
        sprite.y -= 1
      end
      if !@window.viewport.nil?
        xx = @window.x + @window.padding + @window.viewport.rect.x - @window.viewport.ox
      else
        xx = @window.x + @window.padding;yy = @window.y + @window.padding
      end
      sprite.x = xx + @x + @width * @max_rate
      sprite.opacity -= 5
      sprite.dispose if sprite.opacity == 0
    end
    @fall_sprites = @fall_sprites.select {|sprite| !sprite.disposed? }
  end
  def refresh
    if @vocab
      @window.contents.clear_rect(Rect.new(@x,@y,@width,@window.line_height))
    else
      gauge_y = @y + @window.line_height - @height - 1
      @window.contents.clear_rect(Rect.new(@x,gauge_y,@width,@height))
    end
    draw_gauge(@x,@y,@width,@cur_rate,@color1,@color2)
    draw_text(@x,@y,@width)
  end
  def set_rate(rate)
    reset_speed = rate != @max_rate
    @max_rate = rate
    @speed_rate = (@cur_rate-@max_rate).abs / 60 if reset_speed
    if SPECIAL_GAUGES::GAUGE_SLIDE_STYLE == :fall && reset_speed && !SPECIAL_GAUGES::STATIC_GAUGE
      if @cur_rate > @max_rate
        sprite = Sprite.new()
        if !@window.viewport.nil?
          xx = @window.x + @window.padding + @window.viewport.rect.x - @window.viewport.ox
          yy = @window.y + @window.padding + @window.viewport.rect.y - @window.viewport.oy
        else
          xx = @window.x + @window.padding;yy = @window.y + @window.padding
        end
        sprite.x = xx + @x + @width * @max_rate
        sprite.y = yy + @y + @window.line_height - @height
        sprite.z = @window.z + 1
        width = (@width * @cur_rate).to_i - (@width * @max_rate).to_i
        if width > 1
          sprite.bitmap = Bitmap.new(width,@height-2)
          sprite.bitmap.gradient_fill_rect(sprite.bitmap.rect,@color1,@color2)
          @fall_sprites.push(sprite)
        else
          sprite.dispose
        end
      end
    end
    refresh
  end
  def set_extra(vocab,set_val,max_val)
    @vocab = vocab
    @max_val = max_val
    reset_speed = set_val != @set_val
    if @cur_val
      @set_val = set_val
    else
      @cur_val = set_val
      @set_val = set_val
    end
    @speed = (@cur_val-@set_val).abs / 60 if reset_speed
    @speed = 1 if @speed == 0
    refresh
  end
  def draw_gauge(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    fill_ww = (width * @max_rate).to_i
    gauge_y = y + @window.line_height - @height - 1
    @window.contents.fill_rect(x, gauge_y, width, @height, @window.gauge_back_color)
    if SPECIAL_GAUGES::GAUGE_SLIDE_STYLE == :fancy
      color1.alpha -= 150;color2.alpha -= 150
      if rate > @max_rate
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_w, @height-2, color1, color2)
        color1.alpha += 150;color2.alpha += 150
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_ww, @height-2, color1, color2)
      else rate < @max_rate
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_ww, @height-2, color1, color2)
        color1.alpha += 150;color2.alpha += 150
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_w, @height-2, color1, color2)
      end
    elsif SPECIAL_GAUGES::GAUGE_SLIDE_STYLE == :normal
      @window.contents.gradient_fill_rect(x, gauge_y+1, fill_w, @height-2, color1, color2)
    elsif SPECIAL_GAUGES::GAUGE_SLIDE_STYLE == :fall
      if rate > @max_rate
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_ww, @height-2, color1, color2)
      else
        @window.contents.gradient_fill_rect(x, gauge_y+1, fill_w, @height-2, color1, color2)
      end
    end
    color3 = Color.new(0,0,0,0);color4 = @window.gauge_back_color
     xx = x;yy = gauge_y;inc = 0
    case SPECIAL_GAUGES::GAUGE_STYLE
    when :flat
    when :slant
      inc = @height-1
      @height.times do
        inc.times do
          @window.contents.set_pixel(xx,yy,color3)
          xx += 1
        end
        @window.contents.set_pixel(xx,yy,color4)
        xx = x;yy += 1;inc -= 1
      end
      xx = x + width;yy = gauge_y;inc = 0
      @height.times do
        inc.times do
          @window.contents.set_pixel(xx,yy,color3)
          xx -= 1
        end
        @window.contents.set_pixel(xx,yy,color4)
        xx = x + width;yy += 1;inc += 1
      end
    when :round
      inc = 3
      @height.times do |i|
        inc = 0 if inc < 0
        inc.times do
          @window.contents.set_pixel(xx,yy,color3)
          xx += 1
        end
        @window.contents.set_pixel(xx,yy,color4)
        xx = x;yy += 1;inc -= 1
        if i >= @height - 4
          inc += 2
        end
      end
      xx = x + width;yy = gauge_y;inc = 3
      @height.times do |i|
        inc = 0 if inc < 0
        inc.times do
          @window.contents.set_pixel(xx,yy,color3)
          xx -= 1
        end
        @window.contents.set_pixel(xx,yy,color4)
        xx = x + width;yy += 1;inc -= 1
        if i >= @height - 4
          inc += 2
        end
      end
    end
  end
  def draw_text(x,y,w)
    return unless @cur_val
    @window.change_color(@window.system_color)
    @window.draw_text(x, y, 30, @window.line_height, @vocab)
    @window.change_color(@window.normal_color)
    @window.change_color(@window.crisis_color) if @cur_val < @max_val / 4
    xr = x + w
    if w < 96
      @window.draw_text(xr - 40, y, 42, @window.line_height, @cur_val.to_i, 2)
    else
      @window.draw_text(xr - 92, y, 42, @window.line_height, @cur_val.to_i, 2)
      @window.change_color(@window.normal_color)
      @window.draw_text(xr - 52, y, 12, @window.line_height, "/", 2)
      @window.draw_text(xr - 42, y, 42, @window.line_height, @max_val, 2)
    end
  end
end