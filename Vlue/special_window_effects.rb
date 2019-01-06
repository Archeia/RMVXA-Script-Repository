#Special Window Effects v1.0
#----------#
#Features: Special Window Effects for when a scene (usually a menu) opens and
#            closes
#
#Usage:    Plug and play, customize as needed
#       
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!

#Style options are: :none, :fade, :slide, :book, :book_oat
#Style to be used when scene opens:
WEFF_OPEN_STYLE = :book_oat
#Style to be used when scene closes:
WEFF_CLOSE_STYLE = :book_oat
#Speed of fade and slide styles in frames:
WEFF_SPEED = 15

class Scene_Base
  alias menustyle_post_start post_start
  def post_start
    prepare_open_style
    menustyle_post_start
    start_open_style
  end
  def pre_terminate
    prepare_close_style
    start_close_style
  end
  def prepare_open_style
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        ivar.prepare_open if WEFF_OPEN_STYLE == :book
        ivar.prepare_open if WEFF_OPEN_STYLE == :book_oat
        ivar.contents_opacity = 0 if WEFF_OPEN_STYLE == :fade
        ivar.prepare_slide_in if WEFF_OPEN_STYLE == :slide
      end
    end
  end
  def start_open_style
    return open_fade_style if WEFF_OPEN_STYLE == :fade
    return open_slide_style if WEFF_OPEN_STYLE == :slide
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        ivar.set_open if WEFF_OPEN_STYLE == :book
        if WEFF_OPEN_STYLE == :book_oat
          if ivar.set_open
            6.times do |i|
              ivar.update_open
              Graphics.update
            end
          end
        end
      end
    end
  end
  def open_fade_style
    timer = 255/WEFF_SPEED
    windows = instance_variables.select {|varname| instance_variable_get(varname).is_a?(Window) }
    windows = windows.collect {|symbol| instance_variable_get(symbol)}
    timer.times do |i|
      windows.each do |window|
        window.contents_opacity += WEFF_SPEED 
      end
      Graphics.update
    end
  end
  def open_slide_style
    windows = instance_variables.select {|varname| instance_variable_get(varname).is_a?(Window) }
    windows = windows.collect {|symbol| instance_variable_get(symbol)}
    (WEFF_SPEED+1).times do |i|
      windows.each do |window|
        window.update_slide
      end
      Graphics.update
    end
    windows.each {|window| window.finish_slide }
  end
  def start_close_style
    return close_fade_style if WEFF_CLOSE_STYLE == :fade
    return open_slide_style if WEFF_CLOSE_STYLE == :slide
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        ivar.close if WEFF_CLOSE_STYLE == :book
        if WEFF_CLOSE_STYLE == :book_oat
          if ivar.set_open
            ivar.close
            6.times do |i|
              ivar.update_close
              Graphics.update
            end
          end
        end
      end
    end
  end
  def prepare_close_style
    if WEFF_OPEN_STYLE == :slide
      instance_variables.each do |varname|
        ivar = instance_variable_get(varname)
        if ivar.is_a?(Window)
          ivar.prepare_slide_out if WEFF_OPEN_STYLE == :slide
        end
      end
    end
  end
  def close_fade_style
    timer = 255/WEFF_SPEED
    windows = instance_variables.select {|varname| instance_variable_get(varname).is_a?(Window) }
    windows = windows.collect {|symbol| instance_variable_get(symbol)}
    timer.times do |i|
      windows.each do |window|
        window.contents_opacity -= WEFF_SPEED
      end
      Graphics.update
    end
  end
end

class Window_Base
  def prepare_open
    if self.openness > 0 && self.visible
      self.openness = 0
      @set_to_open = true
    end
  end
  def set_open
    open if @set_to_open
    @set_to_open
  end
  def prepare_slide_in
    @target_x = @target_y = nil
    if self.height > self.width
      @target_x = self.x
      if self.x < Graphics.width / 2
        self.x = 0 - self.width
        @slide_speed = (@target_x - self.x) / WEFF_SPEED 
      else
        self.x = Graphics.width
        @slide_speed = (self.x - @target_x) / WEFF_SPEED
      end
    else
      @target_y = self.y
      if self.y < Graphics.height / 2
        self.y = 0 - self.height
        @slide_speed = (@target_y - self.y) / WEFF_SPEED
      else
        self.y = Graphics.height
        @slide_speed = (self.y - @target_y) / WEFF_SPEED
      end
    end
  end
  def prepare_slide_out
    @target_x = @target_y = nil
    if self.height > self.width
      if self.x < Graphics.width / 2
        @target_x = 0 - self.width
        @slide_speed = (self.x - @target_x) / WEFF_SPEED
      else
        @target_x = Graphics.width
        @slide_speed = (@target_x - self.x)  / WEFF_SPEED 
      end
    else
      if self.y < Graphics.height / 2
        @target_y = 0 - self.height
        @slide_speed = (self.y - @target_y) / WEFF_SPEED 
      else
        @target_y = Graphics.height
        @slide_speed = (@target_y - self.x) / WEFF_SPEED
      end
    end
  end
  def update_slide
    if @target_x 
      self.x += @slide_speed if self.x < @target_x
      self.x -= @slide_speed if self.x > @target_x
    elsif @target_y
      self.y += @slide_speed if self.y < @target_y
      self.y -= @slide_speed if self.y > @target_y
    end
  end
  def finish_slide
    self.x = @target_x if @target_x
    self.y = @target_y if @target_y
  end
end