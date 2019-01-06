# Zeus Lights & Shadows v1.3 for XP, VX and VXace by Zeus81
# €30 for commercial use
# Licence : http://creativecommons.org/licenses/by-nc-nd/3.0/
# Contact : zeusex81@gmail.com
# (fr) Manuel d'utilisation : http://pastebin.com/raw.php?i=xfu8yG0q
# (en) User Guide           : http://pastebin.com/raw.php?i=9bnzSHCw
#      Demo : https://www.dropbox.com/sh/cajvk3wf6ue0ivf/QA9zgrm2Vx

module Zeus_Lights_Shadows
  extend self
  
  Disable_Lights = false
  Disable_Shadows = false
  Disable_AutoShadows = false
  
  def light(key = "event#@event_id")
    $game_map.lights[key]  ||= Game_Light.new
  end
  def shadow(key = "event#@event_id")
    $game_map.shadows[key] ||= Game_Shadow.new
  end
  def set_shadowable(value, chara_id=@event_id)
    chara = zls_get_character(chara_id)
    chara.shadowable = value if chara
  end
  def zls_get_character(id)
    case id
    when  0        ; nil
    when -1        ; $game_player
    when -2, -3, -4; $game_player.followers[-id-2] if RPG_VERSION == :vxace
    when -5, -6, -7; $game_map.vehicles[-id-5] if RPG_VERSION != :xp
    else             $game_map.events[id]
    end
  end
end

$imported ||= {}
$imported[:Zeus_Lights_Shadows] = __FILE__
RPG_VERSION = RUBY_VERSION == '1.8.1' ? defined?(Hangup) ? :xp : :vx : :vxace

module Zeus_Animation
  def animate(variable, target_value, duration=0, ext=nil)
    @za_animations ||= {}
    if duration < 1
      update_animation_value(variable, target_value, 1, ext)
      @za_animations.delete(variable)
    else
      @za_animations[variable] = [target_value, duration.to_i, ext]
    end
  end
private
  def update_animations
    @za_animations ||= {}
    @za_animations.delete_if do |variable, data|
      update_animation_value(variable, *data)
      (data[1] -= 1) == 0
    end
  end
  def calculate_next_value(value, target_value, duration)
    (value * (duration - 1) + target_value) / duration
  end
  def update_animation_value(variable, target_value, duration, ext)
    value = instance_variable_get(variable)
    method_name = "update_animation_variable_#{variable.to_s[1..-1]}"
    method_name = "update_animation_#{value.class}" unless respond_to?(method_name)
    send(method_name, variable, value, target_value, duration, ext)
  end
  def update_animation_Color(variable, value, target_value, duration, ext)
    value.red   = calculate_next_value(value.red  , target_value.red  , duration)
    value.green = calculate_next_value(value.green, target_value.green, duration)
    value.blue  = calculate_next_value(value.blue , target_value.blue , duration)
    value.alpha = calculate_next_value(value.alpha, target_value.alpha, duration)
  end
  def update_animation_Float(variable, value, target_value, duration, ext)
    value = calculate_next_value(value, target_value, duration)
    instance_variable_set(variable, value)
  end
  alias update_animation_Fixnum update_animation_Float
  alias update_animation_Bignum update_animation_Float
end

class Game_Light_Shadow_Base
  include Zeus_Animation
  attr_accessor :chara_id, :active, :visible, :filename, :opacity, :color,
                :x, :y, :ox, :oy, :zoom_x, :zoom_y, :parallax_x, :parallax_y,
                :direction, :directions, :pattern, :patterns, :anime_rate
  def initialize
    clear
  end
  def clear
    @chara_id = 0
    @active = false
    @visible = true
    @filename = ""
    @opacity = 255
    @color ||= Color.new(0, 0, 0)
    @color.set(0, 0, 0, 255)
    @x = 0
    @y = 0
    @ox = 0.5
    @oy = 0.5
    @zoom_x = 1.0
    @zoom_y = 1.0
    @zoom2 = Math.sqrt(100.0)
    @parallax_x = 1.0
    @parallax_y = 1.0
    @direction = 0
    @directions = 1
    @pattern = 0
    @patterns = 1
    @anime_rate = 0.0
  end
  def setup(filename)
    @active = true
    @filename = filename
  end
  def update
    update_animations
    update_pattern
  end
  def update_pattern
    if @anime_rate > 0 and Graphics.frame_count % @anime_rate < 1
      @pattern += 1
      @pattern %= @patterns
    end
  end
  def set_pos(x, y, duration=0)
    animate(:@x, x, duration)
    animate(:@y, y, duration)
  end
  def set_origin(ox, oy, duration=0)
    animate(:@ox, ox / 100.0, duration)
    animate(:@oy, oy / 100.0, duration)
  end
  def set_parallax(x, y, duration=0)
    animate(:@parallax_x, x, duration)
    animate(:@parallax_y, y, duration)
  end
  def set_opacity(opacity, duration=0)
    opacity = opacity * 255 / 100
    animate(:@opacity, opacity, duration)
  end
  def set_color(red, green, blue, alpha, duration=0)
    animate(:@color, Color.new(red, green, blue, alpha), duration)
  end
  def set_zoom(zoom, duration=0)
    zoom = Math.sqrt([1, zoom].max)
    animate(:@zoom2, zoom, duration)
  end
  def update_animation_variable_zoom2(variable, value, target_value, duration, ext)
    @zoom2 = calculate_next_value(value, target_value, duration)
    @zoom_y = @zoom_x = @zoom2 ** 2 / 100.0
  end
end

class Game_Shadow < Game_Light_Shadow_Base
  attr_accessor :size, :shadowable
  def clear
    super
    @size = nil
    @shadowable = true
  end
  def setup(filename_or_width, height=0)
    if filename_or_width.is_a?(String)
      @size = nil
      super(filename_or_width)
    else
      super("")
      @size ||= Rect.new(0, 0, 0, 0)
      @size.set(0, 0, filename_or_width.to_i, height.to_i)
    end
  end
end

class Game_Light < Game_Light_Shadow_Base
  attr_accessor :z, :angle, :mirror, :blend_type, :flicker,
                :wave_amp, :wave_length, :wave_speed, :wave_phase
  def clear
    super
    @z = 0xC001
    @angle = 0.0
    @mirror = false
    @blend_type = 1
    @wave_amp = 0
    @wave_length = 180
    @wave_speed = 360
    @wave_phase = 0.0
    @flicker = 1.0
    @flicker_variance = 0.0
    @flicker_rate = 4.0
  end
  def update
    super
    update_flicker
  end
  def update_flicker
    if @flicker_variance == 0
      @flicker = 1
    elsif @flicker_rate == 0 or Graphics.frame_count % @flicker_rate < 1
      case rand(100)
      when 33; value = 1 - @flicker_variance*2
      when 66; value = 1 + @flicker_variance*2
      else     value = 1 - @flicker_variance + @flicker_variance*2*rand
      end
      animate(:@flicker, value, @flicker_rate.to_i)
    end
  end
  def set_angle(angle, duration=0)
    animate(:@angle, angle, duration)
  end
  def set_wave(amp, length, speed, duration=0)
    animate(:@wave_amp   , amp   , duration)
    animate(:@wave_length, length, duration)
    animate(:@wave_speed , speed , duration)
  end
  def set_flicker(variance, refresh_rate, duration=0)
    animate(:@flicker_variance , variance / 100.0, duration)
    animate(:@flicker_rate     , refresh_rate    , duration)
  end
end

class Game_Character
  attr_accessor :shadowable
  def shadowable
    @shadowable = true if @shadowable.nil?
    @shadowable
  end
end

class Game_Map
  include Zeus_Lights_Shadows
  attr_reader :lights, :shadows, :auto_shadows
  alias zeus_lights_shadows_setup setup
  def setup(map_id)
    @lights  ||= {}
    @lights.each_value  {|data| data.clear if data.chara_id >= 0}
    @shadows ||= {}
    @shadows.each_value {|data| data.clear if data.chara_id >= 0}
    zeus_lights_shadows_setup(map_id)
    @auto_shadows ||= []
    @auto_shadows.clear
    init_auto_shadows if RPG_VERSION != :xp and (!Disable_Shadows or Disable_AutoShadows)
  end
  alias zeus_lights_shadows_update update
  def update(*args)
    zeus_lights_shadows_update(*args)
    @lights.each_value  {|data| data.update}
    @shadows.each_value {|data| data.update}
  end
  
  case RPG_VERSION
  when :vx
    
    def init_auto_shadows
      grounds = [1552...1664, 2816...3008, 3200...3392, 3584...3776, 3968...4160]
      is_ground = Proc.new {|id| grounds.any? {|range| range.include?(id)}}
      is_wall = Proc.new {|id| id >= 4352}
      data.xsize.times do |x|
        data.ysize.times do |y|
          tile_id = data[x, y, 0]
          if is_wall.call(tile_id)
            data[x, y, 1] = tile_id
            data[x, y, 0] = 0
          elsif !Disable_Shadows and !Disable_AutoShadows and
                x > 0 and y > 0 and is_ground.call(tile_id) and
                is_wall.call(data[x-1, y, 1]) and is_wall.call(data[x-1, y-1, 1])
          then
            @auto_shadows << [x*32, y*32, 16, 32]
          end
        end
      end
    end
    
  when :vxace
    
    def init_auto_shadows
      data.xsize.times do |x|
        data.ysize.times do |y|
          shadow_id = data[x, y, 3] & 0b1111
          data[x, y, 3] -= shadow_id
          next if Disable_Shadows or Disable_AutoShadows or shadow_id == 0
          case shadow_id
          when  3; @auto_shadows << [x*32, y*32, 32, 16]
          when  5; @auto_shadows << [x*32, y*32, 16, 32]
          when 10; @auto_shadows << [x*32+16, y*32, 16, 32]
          when 12; @auto_shadows << [x*32, y*32+16, 32, 16]
          when 15; @auto_shadows << [x*32, y*32, 32, 32]
          else
            4.times do |i|
              if shadow_id[i] == 1
                @auto_shadows << [x*32 + i%2*16, y*32 + i/2*16, 16, 16]
              end
            end
          end
        end
      end
    end
    
  end # case RPG_VERSION
  
end

if RPG_VERSION == :xp
  Cache = RPG::Cache
  Game_Interpreter = Interpreter
end

class Game_Interpreter
  include Zeus_Lights_Shadows
end

class Spriteset_Lights_Shadows
  include Zeus_Lights_Shadows
  ShadowData = Struct.new(:bitmap, :opacity, :src_rect, :color,
                          :x, :y, :ox, :oy, :zoom_x, :zoom_y)
  def initialize(viewport)
    @viewport = viewport
    @luminosity = 0
    unless Disable_Lights
      @night_layer = Sprite.new(@viewport)
      @night_layer.z = 0xC000
      @night_layer.blend_type = 2
      @night_layer.visible = false
      @night_color = Color.new(0, 0, 0)
      @lights = {}
    end
    unless Disable_Shadows
      @shadows_layer = Sprite.new(@viewport)
      @shadows_layer.visible = false
      @auto_shadows_color = Color.new(0, 0, 0, 255)
      @shadow_data = ShadowData.new
      @shadow_data.src_rect = Rect.new(0, 0, 0, 0)
    end
    refresh_bitmaps
  end
  def dispose
    unless Disable_Lights
      @night_layer.bitmap.dispose
      @night_layer.dispose
      @lights.each_value {|sprite| sprite.dispose}
    end
    unless Disable_Shadows
      @shadows_layer.bitmap.dispose
      @shadows_layer.dispose
    end
  end
  def update(character_sprites)
    refresh_bitmaps if bitmaps_need_refresh?
    update_luminosity
    update_lights unless Disable_Lights
    update_shadows(character_sprites) unless Disable_Shadows
  end
    def refresh_bitmaps
      unless Disable_Lights
        @night_layer.bitmap.dispose if @night_layer.bitmap
        @night_layer.bitmap   = Bitmap.new(@viewport.rect.width, @viewport.rect.height)
      end
      unless Disable_Shadows
        @shadows_layer.bitmap.dispose if @shadows_layer.bitmap
        @shadows_layer.bitmap = Bitmap.new(@viewport.rect.width, @viewport.rect.height)
      end
    end
    def bitmaps_need_refresh?
      unless Disable_Lights
        return true if @night_layer.bitmap.width    != @viewport.rect.width or
                       @night_layer.bitmap.height   != @viewport.rect.height
      end
      unless Disable_Shadows
        return true if @shadows_layer.bitmap.width  != @viewport.rect.width or
                       @shadows_layer.bitmap.height != @viewport.rect.height
      end
      return false
    end
    def update_luminosity
      r, g, b = @viewport.tone.red, @viewport.tone.green, @viewport.tone.blue
      @luminosity = (30*r.to_i + 59*g.to_i + 11*b.to_i) / 100
    end
  def update_lights
    $game_map.lights.delete_if do |key, data|
      if data.active
        update_light_sprite(key, data)
      else
        sprite = @lights.delete(key) and sprite.dispose
      end
      !data.active
    end
    @night_color.set(0, 0, 0)
    unless no_lights?
      r, g, b = @viewport.tone.red, @viewport.tone.green, @viewport.tone.blue
      @viewport.tone.red   += @night_color.red   = -r if r < 0
      @viewport.tone.green += @night_color.green = -g if g < 0
      @viewport.tone.blue  += @night_color.blue  = -b if b < 0
    end
    if @night_color.red + @night_color.green + @night_color.blue == 0
      @night_layer.visible = false
      return
    end
    @night_layer.visible = true
    @night_layer.x = @viewport.ox
    @night_layer.y = @viewport.oy
    @night_layer.bitmap.fill_rect(@night_layer.bitmap.rect, @night_color)
    @lights.each_value do |sprite|
      draw_layer_sprite(@night_layer.bitmap, sprite) if sprite.visible
    end
  end
    def no_lights?
      @lights.all? {|key,sprite| !sprite.visible}
    end
    def update_light_sprite(key, data)
      sprite = @lights[key] ||= Sprite.new(@viewport)
      chara  = zls_get_character(data.chara_id)
      return unless sprite.visible = calculate_visible(data, chara)
      sprite.bitmap     = Cache.picture(data.filename)
      w = sprite.bitmap.width  / data.patterns
      h = sprite.bitmap.height / data.directions
      synchronize_direction_pattern(data, chara) if chara
      sprite.src_rect.set(data.pattern*w, data.direction*h, w, h)
      sprite.color      = data.color
      sprite.x          = calculate_x(data.x, data.parallax_x, chara)
      sprite.y          = calculate_y(data.y, data.parallax_y, chara)
      sprite.z          = data.z
      sprite.ox         = data.ox * w
      sprite.oy         = data.oy * h
      sprite.zoom_x     = data.zoom_x * data.flicker
      sprite.zoom_y     = data.zoom_y * data.flicker
      sprite.angle      = data.angle
      sprite.mirror     = data.mirror
      sprite.opacity    = data.opacity
      sprite.blend_type = data.blend_type
      if RPG_VERSION != :xp
        sprite.wave_amp    = data.wave_amp
        sprite.wave_length = data.wave_length
        sprite.wave_speed  = data.wave_speed
        sprite.wave_phase  = data.wave_phase
        sprite.update
        data.wave_phase    = sprite.wave_phase
      end
    end
    def draw_layer_sprite(layer, sprite)
      if sprite.zoom_x == 1 and sprite.zoom_y == 1
        x = sprite.x - sprite.ox - @viewport.ox
        y = sprite.y - sprite.oy - @viewport.oy
        layer.blt(x, y, sprite.bitmap, sprite.src_rect, sprite.opacity)
      else
        dest_rect = Rect.new(
          sprite.x - sprite.ox * sprite.zoom_x - @viewport.ox,
          sprite.y - sprite.oy * sprite.zoom_y - @viewport.oy,
          sprite.src_rect.width  * sprite.zoom_x,
          sprite.src_rect.height * sprite.zoom_y)
        layer.stretch_blt(dest_rect, sprite.bitmap, sprite.src_rect, sprite.opacity)
      end
    end
    
  def update_shadows(character_sprites)
    $game_map.shadows.delete_if {|key, data| !data.active}
    if @luminosity <= -64 or no_shadows?
      if @shadows_layer.visible
        @shadows_layer.visible = false
        character_sprites.each {|chara| chara.color.alpha = 0}
      end
      return
    end
    @shadows_layer.visible = true
    @shadows_layer.x = @viewport.ox
    @shadows_layer.y = @viewport.oy
    @shadows_layer.opacity = 128 + (@luminosity>0 ? @luminosity/2 : @luminosity*2)
    @shadows_layer.bitmap.clear
    $game_map.shadows.each_value do |data|
      update_shadow_data(data) if data.shadowable
    end
    draw_auto_shadows
    draw_airship_shadow if RPG_VERSION != :xp
    for sprite in character_sprites
      if !shadowable_character?(sprite.character)
        sprite.color.alpha = 0
      elsif sprite.x >= 0 and sprite.x < @shadows_layer.bitmap.width and
            sprite.y >= 4 and sprite.y < @shadows_layer.bitmap.height+4
      then
        sprite.color = @shadows_layer.bitmap.get_pixel(sprite.x, sprite.y-4)
        sprite.color.alpha = sprite.color.alpha * @shadows_layer.opacity / 255
      end
    end
    $game_map.shadows.each_value do |data|
      update_shadow_data(data) if !data.shadowable
    end
  end
    def no_shadows?
      $game_map.auto_shadows.empty? and
      $game_map.shadows.all? do |key,data|
        !calculate_visible(data, zls_get_character(data.chara_id))
      end
    end
    def shadowable_character?(chara)
      if RPG_VERSION != :xp and chara == $game_map.airship
      then chara.altitude < 16
      else chara.shadowable
      end
    end
    def draw_auto_shadows
      for x, y, w, h in $game_map.auto_shadows
        x = calculate_x(x, 1, nil) - @viewport.ox
        y = calculate_y(y, 1, nil) - @viewport.oy
        @shadows_layer.bitmap.fill_rect(x, y, w, h, @auto_shadows_color)
      end
    end
    def draw_airship_shadow
      return if $game_map.airship.transparent or $game_map.airship.altitude == 0
      bmp     = Cache.system("Shadow")
      opacity = [$game_map.airship.altitude * 8, 255].min
      x = $game_map.airship.screen_x - bmp.width / 2 - @viewport.ox
      y = $game_map.airship.screen_y - bmp.height - @viewport.oy +
          $game_map.airship.altitude + 4
      @shadows_layer.bitmap.blt(x, y, bmp, bmp.rect, opacity)
    end
    def update_shadow_data(data)
      chara = zls_get_character(data.chara_id)
      return unless calculate_visible(data, chara)
      if data.size
        @shadow_data.src_rect.set(0, 0, w=data.size.width, h=data.size.height)
        @shadow_data.color   = data.color
        @shadow_data.bitmap  = nil
      else
        @shadow_data.bitmap  = Cache.picture(data.filename)
        @shadow_data.opacity = data.opacity
        w = @shadow_data.bitmap.width  / data.patterns
        h = @shadow_data.bitmap.height / data.directions
        synchronize_direction_pattern(data, chara) if chara
        @shadow_data.src_rect.set(data.pattern*w, data.direction*h, w, h)
      end
      @shadow_data.x       = calculate_x(data.x, data.parallax_x, chara)
      @shadow_data.y       = calculate_y(data.y, data.parallax_y, chara)
      @shadow_data.ox      = data.ox * w
      @shadow_data.oy      = data.oy * h
      @shadow_data.zoom_x  = data.zoom_x
      @shadow_data.zoom_y  = data.zoom_y
      draw_layer_shadow(@shadows_layer.bitmap, @shadow_data)
    end
    def draw_layer_shadow(layer, shadow)
      if shadow.bitmap
        draw_layer_sprite(layer, shadow)
      else
        dest_rect = Rect.new(
          shadow.x - shadow.ox * shadow.zoom_x - @viewport.ox,
          shadow.y - shadow.oy * shadow.zoom_y - @viewport.oy,
          shadow.src_rect.width  * shadow.zoom_x,
          shadow.src_rect.height * shadow.zoom_y)
        layer.fill_rect(dest_rect, shadow.color)
      end
    end
  
  def synchronize_direction_pattern(data, chara)
    case data.directions
    when 2; data.direction = (chara.direction - 1) / 4
    when 4; data.direction = (chara.direction - 1) / 2
    when 8; data.direction =  chara.direction - 1 - chara.direction / 5
    end
    if data.anime_rate == 0
      data.pattern = chara.pattern < 3 || RPG_VERSION == :xp ? chara.pattern : 1
      data.pattern %= data.patterns
    end
  end
  def calculate_visible(data, chara)
    if chara
      return false if chara.transparent
      if chara.is_a?(Game_Event)
        return false unless chara.list
      elsif RPG_VERSION == :vxace and chara.is_a?(Game_Follower)
        return false unless chara.visible?
      end
    end
    return false unless data.visible and data.opacity > 0
    return true if !data.filename.empty?
    return true if data.is_a?(Game_Shadow) and data.size
    return false
  end
  def calculate_x(x, parallax_x, chara)
    if chara
      x + chara.screen_x
    elsif RPG_VERSION == :xp or parallax_x != 1 or !$game_map.loop_horizontal?
      case RPG_VERSION
      when :xp   ; x - $game_map.display_x * parallax_x / 4
      when :vx   ; x - $game_map.display_x * parallax_x / 8
      when :vxace; x - $game_map.display_x * parallax_x * 32
      end
    else
      case RPG_VERSION
      when :vx   ; $game_map.adjust_x(x * 8) / 8
      when :vxace; $game_map.adjust_x(x / 32.0) * 32
      end
    end
  end
  def calculate_y(y, parallax_y, chara)
    if chara
      y + chara.screen_y
    elsif RPG_VERSION == :xp or parallax_y != 1 or !$game_map.loop_vertical?
      case RPG_VERSION
      when :xp   ; y - $game_map.display_y * parallax_y / 4
      when :vx   ; y - $game_map.display_y * parallax_y / 8
      when :vxace; y - $game_map.display_y * parallax_y * 32
      end
    else
      case RPG_VERSION
      when :vx   ; $game_map.adjust_y(y * 8) / 8
      when :vxace; $game_map.adjust_y(y / 32.0) * 32
      end
    end
  end
  
end

class Spriteset_Map
  alias zeus_lights_shadows_dispose dispose
  def dispose
    zeus_lights_shadows_dispose
    @lights_shadows.dispose
  end
  alias zeus_lights_shadows_update update
  def update
    zeus_lights_shadows_update
    @lights_shadows ||= Spriteset_Lights_Shadows.new(@viewport1)
    @lights_shadows.update(@character_sprites)
  end
  if RPG_VERSION != :xp and !Zeus_Lights_Shadows::Disable_Shadows
    def create_shadow()  end
    def update_shadow()  end
    def dispose_shadow() end
  end
end

$imported[:Zeus_Weather_Viewport] ||= __FILE__ if RPG_VERSION != :xp
if $imported[:Zeus_Weather_Viewport] == __FILE__
  
  class Spriteset_Map
    alias zeus_weather_viewport_create_weather create_weather
    def create_weather
      zeus_weather_viewport_create_weather
      @weather.weather_viewport = @viewport1
    end
  end
  
  class Spriteset_Weather
    case RPG_VERSION
    when :vx
      def weather_viewport=(viewport)
        for sprite in @sprites
          sprite.viewport = viewport
          sprite.z = 0x8000
        end
      end
    when :vxace
      attr_accessor :weather_viewport
      alias zeus_weather_viewport_add_sprite add_sprite
      def add_sprite
        zeus_weather_viewport_add_sprite
        @sprites[-1].viewport = @weather_viewport
        @sprites[-1].z = 0x8000
      end
    end
  end
  
end

$imported[:Zeus_Event_Auto_Setup] ||= __FILE__
if $imported[:Zeus_Event_Auto_Setup] == __FILE__
  
  class Game_Map
    alias zeus_auto_setup setup
    def setup(map_id)
      zeus_auto_setup(map_id)
      @events.each_value {|event| event.auto_setup}
    end
  end
  
  class Game_Event
    alias zeus_auto_setup_refresh refresh
    def refresh
      zeus_auto_setup_refresh
      auto_setup if $game_map.events[@id]
    end
    def auto_setup
      @auto_setup ||= {}
      return unless @auto_setup[:list] != @list and @auto_setup[:list] = @list
      unless @auto_setup.has_key?(@list)
        flag_a, flag_b, a, b = '<setup>', '</setup>', nil, nil
        @list.each_with_index do |command, id|
          if command.code % 300 == 108 # comment
            b = id if  a and command.parameters[0].include?(flag_b)
            a = id if !a and command.parameters[0].include?(flag_a)
            break if a and b
          end
        end
        @auto_setup[@list] = a && b && @list.slice!(a, b-a+1).push(@list[-1])
      end
      if @auto_setup[@list]
        interpreter = Game_Interpreter.new
        interpreter.setup(@auto_setup[@list], @id)
        interpreter.update while interpreter.running?
      end
    end
  end
  
end