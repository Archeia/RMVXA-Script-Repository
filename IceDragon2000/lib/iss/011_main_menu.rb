#encoding:UTF-8
# ISS011 - MainMenu
# // Date Modified 06/09/2011
#==============================================================================#
# * Sprite_MenuMap
#==============================================================================#
class Sprite_MenuMap < ::Sprite

  attr_accessor :map_id

  def initialize(viewport, x, y, width, height, tilesize)
    super(viewport)
    @mwidth, @mheight = width, height
    self.x = x
    self.y = y
    @map_id = $game_map.map_id
    @sprites = []
    @last_map_id = -1
    @tilesize = tilesize
  end

  def dispose
    @sprites.each { |sp| sp.bitmap.dispose() ; sp.dispose() }
    self.bitmap.dispose() unless self.bitmap.nil?()
    super()
  end

  def refresh()
    @sprites.each { |sp| sp.dispose() }
    @sprites.clear()
    self.bitmap.dispose unless self.bitmap.nil?()
    self.bitmap = Bitmap.new(@mwidth*@tilesize, @mheight*@tilesize)
    rect = Rect.new(0, 0, @mwidth*@tilesize, @mheight*@tilesize)
    self.bitmap.fill_rect(rect, Color.new( 0, 0, 0 ))
    map = $game_map.get_map(@map_id)
    xo, yo = (@mwidth-map.data.xsize)/2 , (@mheight-map.data.ysize)/2
    c1 = system_color
    sub = 40
    c2 = c1.clone ; c2.red -= sub ; c2.green -= sub ; c2.blue -= sub
    c3 = normal_color
    for mx in 0...map.data.xsize
      for my in 0...map.data.ysize
        rect = Rect.new((mx+xo)*@tilesize, (my+yo)*@tilesize, @tilesize, @tilesize)
        if $game_map.passable?(mx, my)
          self.bitmap.fill_rect(rect, c1)
        else
          self.bitmap.fill_rect(rect, c2)
        end
      end
    end
    for ev in $game_map.events.values + [$game_player]
      sp = ::Sprite.new
      sp.bitmap = Bitmap.new(@tilesize, @tilesize)
      rect = Rect.new(0, 0, @tilesize, @tilesize)
      sp.bitmap.fill_rect(rect, c3)
      sp.x = self.x + ((xo+ev.x) * @tilesize)
      sp.y = self.y + ((yo+ev.y) * @tilesize)
      sp.z = self.z + 2
      @sprites << sp
    end
    @last_map_id = @map_id
  end

  def update()
    super()
    @map_id = $game_map.map_id
    refresh if @map_id != @last_map_id
    @sprites.each { |sp| sp.update() ; sp.flash(Color.new(112,56,198),60) if Graphics.frame_count % Graphics.frame_rate == 0 }
  end

end

#==============================================================================#
# ** Window_Skill
#==============================================================================#
class Window_Skill < Window_Selectable

  attr_accessor :actor

  def initialize(x, y, width, height, actor)
    @spacing = 2
    super(x, y, width, height)
    @actor = actor
    @column_max = 1
    self.index = 0
    @spacing = 2
    refresh
  end

end

#==============================================================================#
# ** ISS011_Window_Status
#==============================================================================#
class ISS011_Window_Status < Window_Base

  WLH = 20

  attr_accessor :actor

  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    @actor = actor
    refresh()
  end

  def refresh()
    self.contents.clear()
    return if @actor.nil?()
    #draw_actor_name(@actor, 4, 0)
    draw_actor_class(@actor, 128, 4)
    draw_actor_face(@actor, 4, 4)
    #draw_basic_info(128, 32)
    draw_parameters(12, 128-24)
    draw_exp_info(self.contents.width/2, 32)
    draw_equipments(self.contents.width/2, 128-24)
  end

  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + WLH * 0)
    draw_actor_state(@actor, x, y + WLH * 1)
    draw_actor_hp(@actor, x, y + WLH * 2)
    draw_actor_mp(@actor, x, y + WLH * 3)
  end

  def draw_parameters(x, y)
    self.contents.font.size = Font.default_size + 2
    self.contents.font.bold = true
    self.contents.draw_text(x, y, 120, WLH, "Stats")
    self.contents.font.size = Font.default_size
    self.contents.font.bold = Font.default_bold
    for i in 0..8
      draw_actor_parameter(@actor, x+8, y + WLH * (i+1), i)
    end
  end

  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = Vocab::atk
      parameter_value = actor.atk
    when 1
      parameter_name = Vocab::def
      parameter_value = actor.def
    when 2
      parameter_name = Vocab::spi
      parameter_value = actor.spi
    when 3
      parameter_name = Vocab::agi
      parameter_value = actor.agi
    when 4
      parameter_name = Vocab::counter
      parameter_value = actor.counter_power
    when 5
      parameter_name = Vocab::coop
      parameter_value = actor.coop_power
    when 6
      parameter_name = Vocab::hit
      parameter_value = actor.hit
    when 7
      parameter_name = Vocab::eva
      parameter_value = actor.eva
    when 8
      parameter_name = Vocab::cri
      parameter_value = actor.cri
    end
    self.contents.font.color = system_color
    self.contents.font.bold = true
    self.contents.draw_text(x, y, 120, WLH, parameter_name)
    self.contents.font.color = normal_color
    self.contents.font.bold = Font.default_bold
    self.contents.draw_text(x + 112, y, 36, WLH, parameter_value, 2)
  end

  def draw_exp_info(x, y)
    s1 = @actor.exp_s
    s2 = @actor.next_rest_exp_s
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y + WLH * 0, 180, WLH, Vocab::ExpTotal)
    self.contents.draw_text(x, y + WLH * 2, 180, WLH, s_next)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y + WLH * 1, 180, WLH, s1, 2)
    self.contents.draw_text(x, y + WLH * 3, 180, WLH, s2, 2)
  end

  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, Vocab::equip)
    for i in 0..4
      draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
    end
  end

end

#==============================================================================#
# ** Window_ActorMenuStatus
#==============================================================================#
class Window_ActorMenuStatus < Window_Base

  WLH = 20

  attr_accessor :actor
  attr_accessor :default_height
  attr_accessor :target_x
  attr_accessor :open_mode
  attr_accessor :focused

  def initialize(x, y, actor)
    @default_height = 112
    @default_width  = 320+32
    super(x, y, @default_width, @default_height)
    @index = 0
    @actor = actor
    self.active = false
    self.focused = false
    case @actor.class_id
    when 1..5
      skin = YEM::SYSTEM::WINDOW_HASH[1]
    when 6..10
      skin = YEM::SYSTEM::WINDOW_HASH[4]
    when 11..15
      skin = YEM::SYSTEM::WINDOW_HASH[3]
    end
    @target_x = self.x
    @target_height = @default_height
    @target_width  = @default_width
    @open_height   = 256
    @open_width    = @default_width+64
    @open_mode     = 0
    change_settings(skin)
    refresh()
  end

  def refresh()
    create_contents()
    @data = [] ; @classes = [] ; @equips = []
    self.contents.font.size  = Font.default_size
    self.contents.font.color = normal_color
    self.contents.font.bold  = Font.default_bold
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 96, 0)
    draw_actor_hp(@actor, 4, WLH, 96)
    draw_actor_mp(@actor, 4+12, WLH+12, 96)
    @classes += draw_classes(@actor, self.contents.width-56, 0)
    @equips += draw_actor_equips(@actor, self.contents.width/2, 30)
    draw_actor_state(@actor, 24, (@default_height-32)-24, self.contents.width)
    self.contents.font.size  = Font.default_size
    self.contents.font.color = system_color
    self.contents.font.bold  = true
    self.contents.draw_text(0, 4, self.contents.width-64, WLH, "Classes", 2)
    update_cursor()
  end

  def draw_classes(actor, x, y)
    res = []
    draw_outlined_icon(IEO::Icon.class( actor.class_id),
      x, y, 26, 26, 2, Color.new(200, 208, 192 ))
    draw_outlined_icon(IEO::Icon.class( 0),  # actor.sec_class_id
      x+28, y, 26, 26, 2, Color.new(200, 208, 192 ))
    res << [:class, Rect.new(x-1, y-1, 28, 28)]
    res << [:class, Rect.new(x+28-1, y-1, 28, 28)]
    return res
  end

  def draw_actor_equips(actor, x, y)
    eqs = actor.equips
    color = Color.new(200, 208, 192)
    res = []
    for i in 0...eqs.size
      eq = eqs[i]
      unless eq.nil?()
        draw_outlined_item(eq, x+(28*i), y, 26, 26, 2, color)
      else
        draw_border_rect(x+(28*i), y, 26, 26, 2, color)
      end
      res << [:equip, Rect.new(x+(28*i)-1, y-1, 28, 28)]
    end
    return res
  end

  def update()
    case @open_mode
    when 0
      @height_rate   = 30.0
      @target_height = @default_height
      @target_width  = @default_width
    when 1
      @height_rate   = 30.0
      @target_height = self.focused ? @open_height : @default_height
      @target_width  = self.focused ? @open_width : @default_width
    when 2
      @height_rate   = 30.0
      @target_height = self.focused ? @open_height+56 : @default_height
      @target_width  = self.focused ? @open_width : @default_width
    when 3
      @height_rate   = 10.0
      @target_height = self.focused ? Graphics.height : @default_height
      @target_width  = self.focused ? @open_width : @default_width
    end
    if self.x > @target_x
      self.x = [self.x-self.width/60.0, @target_x].max
    elsif self.x < @target_x
      self.x = [self.x+self.width/60.0, @target_x].min
    end
    if self.height > @target_height
      self.height = [self.height-(@open_height/@height_rate), @target_height].max
    elsif self.height < @target_height
      self.height = [self.height+(@open_height/@height_rate), @target_height].min
    end
    if self.width > @target_width
      self.width = [self.width-(@open_width/30.0), @target_width].max
    elsif self.width < @target_width
      self.width = [self.width+(@open_width/30.0), @target_width].min
    end
    if self.active
      super()
      update_cursor()
      if Input.trigger?(Input::LEFT)
        Sound.play_cursor()
        @index = (@index - 1) % @data.size
      elsif Input.trigger?(Input::RIGHT)
        Sound.play_cursor()
        @index = (@index + 1) % @data.size
      end if @data.size > 0
    end
  end

  def update_cursor()
    unless @data[@index].nil?()
      self.cursor_rect.set(*@data[@index][1].to_a)
    else
      self.cursor_rect.empty
    end
  end

end

#==============================================================================#
# ** ISS011_MenuStatus
#==============================================================================#
class ISS011_MenuStatus # // Container

  attr_reader :x, :y, :z
  attr_accessor :index
  attr_accessor :item_max
  attr_accessor :large_select
  attr_accessor :obj_window
  attr_accessor :status_window
  attr_reader :disposed

  def initialize(sx, sy)
    @x, @y, @z = sx, sy, 0
    @index = -1
    @windows = {}
    @actor_windows = []
    @item_max = 0
    @active = true
    @large_select = false
    @disposed = false
    refresh()
  end

  def active=(bool)
    @active = bool
  end

  def active() ; return @active end

  def dispose()
    dispose_windows()
    @disposed = true
  end

  def dispose_windows()
    @actor_windows.clear()
    @windows.values.each { |w| w.dispose }
    @windows.clear()
    @obj_window.dispose() unless @obj_window.nil?()
    @obj_window = nil
  end

  def x=(new_x)
    return if @x == new_x
    @x = new_x
    @windows.values.each { |w| w.x = @x }
  end

  def y=(new_y)
    return if @y == new_y
    @y = new_y
    @windows.values.each { |w| w.x = @y }
  end

  def refresh()
    i = 0
    dispose_windows()
    $game_party.members.each { |m|
      winm = "Actor#{i}"
      win = Window_ActorMenuStatus.new(20, 0, m)
      win.y = @y+(win.height*i)
      @windows[winm] = win
      @actor_windows[i] = win
      i += 1
    }
    @act_item_max = @actor_windows.size()
    @item_max = @actor_windows.size()
    reset_window_positions()
    update_windows()
  end

  def update()
    update_window_positions()
    update_windows()
    return unless self.active()
    update_user_input()
  end

  def update_windows()
    @obj_window.update() unless @obj_window.nil?()
    @windows.values.each { |win| win.update() }
  end

  def start_selection(type, large=false)
    @actor_windows[@index].active = true
    @large_select = large
    mode = 0
    case @type=type
    when :skill
      @obj_window = Window_Skill.new( @x, (112-16),
        320+32+64, 256-(112),
        @actor_windows[@index].actor )
      @obj_window.opacity = 0
      @obj_window.active = false
      @obj_window.index = -1
      mode = 1
    when :equip
      mode = 0
    when :status
      @status_window = ISS011_Window_Status.new( @x, (112-16),
        320+32+64, Graphics.height-(112),
        @actor_windows[@index].actor )
      @status_window.visible = false
      @status_window.opacity = 0
      mode = 0
    end
    @actor_windows.each { |win|
      win.active = false
      win.open_mode = mode
    }
  end

  def end_selection()
    @actor_windows.each { |win| win.active = false }
    @obj_window.dispose() unless @obj_window.nil?() ; @obj_window = nil
    @status_window.dispose() unless @status_window.nil?() ; @status_window = nil
    @large_select = false
  end

  def start_status_view()
    self.active = false
    @status_window.visible = true
    @status_window.actor = @actor_windows[@index].actor
    @actor_windows[@index].open_mode = 3
    @status_window.refresh()
    @status_window.height = Graphics.height-(112)
    @status_window.width = 320+32+64
  end

  def end_status_view()
    self.active = true
    @status_window.visible = false
    @status_window.actor = nil
    @actor_windows[@index].open_mode = 0
    @status_window.refresh()
  end

  def start_obj_selection()
    self.active = false
    @actor_windows.each { |win|
      win.active = false
      win.open_mode = 2
    }
    @obj_window.active = true
    @obj_window.index = 0
    @help_window = Window_Help.new()
    @help_window.opacity = 0
    @help_window.width = @obj_window.width
    @help_window.x = @obj_window.x
    @help_window.y = @obj_window.y + @obj_window.height - 16
    @help_window.create_contents()
    @obj_window.help_window = @help_window
  end

  def end_obj_selection()
    self.active = true
    @actor_windows.each { |win|
      win.active = true
      win.open_mode = 1
    }
    @obj_window.active = false
    @obj_window.index = -1
    @obj_window.help_window = nil
    @help_window.dispose() ; @help_window = nil
  end

  def update_window_positions()
    windoworder = [] ; @act_item_max.times { |i| windoworder << i }
    backind = [@index, 0].max
    windoworder.rotate!(backind) if @large_select
    for i in 0...@act_item_max
      binx = windoworder[i]
      win = @actor_windows[binx]
      win.y = @y+(i*112)
      win.y += @actor_windows[backind].height -
       @actor_windows[windoworder[i-1]].default_height if i > 0
      win.target_x = @x + 24
      win.z = @z + i
      win.opacity = win.contents_opacity = 128
      win.focused = false
    end
    if @index >= 0
      if @large_select #|| @type == :status
        @actor_windows[@index].target_x = @x
      else
        @actor_windows[@index].target_x = @x + 46
      end
      @actor_windows[@index].focused = true
      unless @obj_window.nil?()
        @actor_windows[@index].opacity = (
         @actor_windows[@index].contents_opacity = (@obj_window.active ? 198 : 255))
        @obj_window.x = @actor_windows[@index].x
        if @obj_window.actor != @actor_windows[@index].actor
          @obj_window.actor = @actor_windows[@index].actor
          @obj_window.refresh()
          @obj_window.index = @obj_window.active ? @obj_window.index % [@obj_window.item_max, 1].max : -1
        end
      else
        @actor_windows[@index].opacity = @actor_windows[@index].contents_opacity = 255
      end
      unless @status_window.nil?()
        @actor_windows[@index].opacity = 198
        @status_window.x = @actor_windows[@index].x
        @status_window.y = @actor_windows[@index].y + 112 - 16
      end
    end

    unless @help_window.nil?()
      @help_window.x = @obj_window.x
      @help_window.y = @obj_window.y + @obj_window.height
    end
  end

  def update_user_input()
    return if @item_max == 0
    if Input.repeat?(Input::UP)
      @actor_windows[@index].active = false
      Sound.play_cursor()
      @index -= 1
      @index %= @item_max
      @actor_windows[@index].active = true
    elsif Input.repeat?(Input::DOWN)
      @actor_windows[@index].active = false
      Sound.play_cursor
      @index += 1
      @index %= @item_max
      @actor_windows[@index].active = true
    end
  end

  def reset_window_positions()
    for i in 0...@act_item_max
      @actor_windows[i].x = 32 +
        @actor_windows[i].width +
        @actor_windows[i].target_x = @x + 24
    end
  end

  def selected_window()
    return @actor_windows[@index]
  end

end

#==============================================================================#
# ** RPG::XBGM
#==============================================================================#
class RPG::XBGM < RPG::BGM
end

#==============================================================================#
# ** Scene_Menu
#==============================================================================#
class Scene_Menu < Scene_Base

  Menu_Music = RPG::XBGM.new("Investigating", 100, 100)

  def start()
    super()
    create_menu_background()
    create_command_window()
    @gold_window = Window_Gold.new(0, 360)
    @status_window = ISS011_MenuStatus.new(160, 0)
    @status_window.active = false
    Menu_Music.play()
    tsz = 4
    @minimap_sprite = Sprite_MenuMap.new( nil, 0, @command_window.height,
     40, 46, tsz )
    @minimap_sprite.update()
  end

  def terminate()
    super()
    dispose_menu_background()
    @command_window.dispose()
    @gold_window.dispose()
    @status_window.dispose()
    @minimap_sprite.dispose()
    $game_map.autoplay() if $scene.is_a?(Scene_Map)
  end

  def update()
    super()
    update_menu_background()
    @command_window.update if @command_window.active
    @gold_window.update if @gold_window.active
    @status_window.update()
    @minimap_sprite.update()
    if @command_window.active
      update_command_selection()
    elsif @status_window.active
      update_actor_selection()
    elsif !@status_window.obj_window.nil?() && @status_window.obj_window.active
      update_obj_selection()
    elsif !@status_window.status_window.nil?() && @status_window.status_window.active
      update_status_view()
    elsif @target_window.active
      update_obj_target_selection()
    end
  end

  def create_command_window
    s1 = Vocab::item
    s2 = Vocab::skill
    s3 = Vocab::equip
    s4 = Vocab::status
    s5 = Vocab::save
    s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0          # If number of party members is 0
      @command_window.draw_item(0, false)     # Disable item
      @command_window.draw_item(1, false)     # Disable skill
      @command_window.draw_item(2, false)     # Disable equipment
      @command_window.draw_item(3, false)     # Disable status
    end
    if $game_system.save_disabled             # If save is forbidden
      @command_window.draw_item(4, false)     # Disable save
    end
  end

  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0      # Item
        $scene = Scene_Item.new
      when 1,2,3  # Skill, equipment, status
        start_actor_selection
      when 4      # Save
        $scene = Scene_File.new(true, false, false)
      when 5      # End Game
        $scene = Scene_End.new
      end
    end
  end

  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
    case @command_window.index
    when 1
      @status_window.start_selection(:skill, true)
    when 2
      @status_window.start_selection(:equip, false)
    when 3
      @status_window.start_selection(:status, true)
    else
      @status_window.start_selection(:nil, false)
    end
  end

  def end_actor_selection
    @command_window.active = true
    @status_window.active = false
    @status_window.index = -1
    @status_window.end_selection()
  end

  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1  # skill
        start_obj_selection()
        #$scene = Scene_Skill.new(@status_window.index)
      when 2  # equipment
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # status
        start_status_view()
        #$scene = Scene_Status.new(@status_window.index)
      end
    end
  end

  def start_status_view()
    @status_window.start_status_view()
  end

  def end_status_view()
    @status_window.end_status_view()
  end

  def update_status_view()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_status_view()
    end
  end

  def start_obj_selection()
    @status_window.start_obj_selection()
  end

  def end_obj_selection()
    @status_window.end_obj_selection()
  end

  def start_obj_target_selection()
    @target_window = Window_MenuStatus.new(160, 0)
    @target_window.active = true
    @status_window.x = Graphics.width
    @status_window.obj_window.active = false
  end

  def end_obj_target_selection()
    @target_window.dispose()
    @target_window = nil
    @status_window.x = 160
    @status_window.obj_window.active = true
  end

  def update_obj_selection()
    if Input.trigger?(Input::B)
      Sound.play_cancel()
      end_obj_selection()
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 1
        @skill = @status_window.obj_window.skill
        @actor = @status_window.selected_window.actor
        unless @skill.nil?()
          @actor.last_skill_id = @skill.id
        end
        if @actor.skill_can_use?(@skill)
          Sound.play_decision()
          determine_skill()
        else
          Sound.play_buzzer()
        end
      end
    end
  end

  def update_obj_target_selection()
    @target_window.update()
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_obj_target_selection()
    elsif Input.trigger?(Input::C)
      case @command_window.index
      when 1
        if @actor.skill_can_use?(@skill)
          Sound.play_decision()
          determine_target()
        else
          Sound.play_buzzer()
        end
      end
    end
  end

  def determine_skill
    if @skill.for_friend?
      start_obj_target_selection()
      if @skill.for_all?
        @target_window.index = 99
      elsif @skill.for_user?
        @target_window.index = @actor.index + 100
      else
        if $game_party.last_target_index < @target_window.item_max
          @target_window.index = $game_party.last_target_index
        else
          @target_window.index = 0
        end
      end
    else
      use_skill_nontarget
    end
  end

  def determine_target
    used = false
    if @skill.for_all?
      for target in $game_party.members
        target.skill_effect(@actor, @skill)
        used = true unless target.skipped
      end
    elsif @skill.for_user?
      target = $game_party.members[@target_window.index - 100]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    else
      $game_party.last_target_index = @target_window.index
      target = $game_party.members[@target_window.index]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    end
    if used
      use_skill_nontarget
    else
      Sound.play_buzzer
    end
  end

  def use_skill_nontarget()
    Sound.play_use_skill()
    @actor.custom_skill_cost(@skill, :perform)
    @actor.custom_skill_subcost(@skill, :perform)
    @status_window.obj_window.refresh()
    @target_window.refresh()
    if $game_party.all_dead?()
      $scene = Scene_Gameover.new()
    elsif @skill.common_event_id > 0
      $game_temp.common_event_id = @skill.common_event_id
      $scene = Scene_Map.new()
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
