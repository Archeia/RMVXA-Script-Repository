=begin
#===============================================================================
 Title: Overlay Map Zoom
 Author: Hime
 Date: Mar 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 31
   - updated to support overlay map opacities
 Mar 27, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Required
 
 - Overlay Maps
 http://himeworks.com/2013/03/15/overlay-maps-layered-maps-in-ace/
 
 - Overlay Map Zoom files
 http://himeworks.net63.net/rpgmaker/files/overlay_mapZoom_pack.zip
--------------------------------------------------------------------------------
 ** Description
 
 This is an add-on for Overlay Maps.
 It adds zooming functionality to the overlay maps.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Overlay Maps and above Main.
 
 Download the map zoom files and place
   * the MGC_Map_Ace.dll in the System folder
   * the three autotile pictures in Graphics/System folder
 
--------------------------------------------------------------------------------
 ** Usage
 
 The zoom value that you specify for the overlay map is used to determine
 whether the map should be zoomed in or zoomed out. Refer to the Overlay
 Maps script to see where to specify the zoom value.
 
 If zoom value is less than 1, then it is smaller
 If zoom value is equal to 1, then it is normal size
 If zoom value is greater than 1, then it is bigger

--------------------------------------------------------------------------------
 ** Credits
 
 MGC, for the map zoom code and tilemap dll
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_OverlayZooming"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Overlay_Map_Zoom
  
    # whether the parallax should be zoomed or not.
    Parallax_Zoom = true
  end
end

#==============================================================================
# ** Spriteset_OverlayMap
#==============================================================================
class Spriteset_OverlayMap < Spriteset_Map

  alias :th_overlay_zooming_create_viewports :create_viewports
  def create_viewports
    th_overlay_zooming_create_viewports
    @viewport1.zoom = @map.zoom
  end
  
  #--------------------------------------------------------------------------
  # * Overwrite. Create Tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = OverlayTilemap.new(@viewport1)
    @tilemap.map_data = @map.data
    @tilemap.opacity = @map.opacity
    load_tileset
  end

  #--------------------------------------------------------------------------
  # * Update Parallax
  #--------------------------------------------------------------------------
  alias :th_overlay_zoom_update_parallax :update_parallax
  def update_parallax
    @parallax.update_viewport_zoom
    th_overlay_zoom_update_parallax
  end
end

#==============================================================================
# ** Viewport
#==============================================================================
class Viewport
  #--------------------------------------------------------------------------
  # * Attributs
  #--------------------------------------------------------------------------
  attr_reader :zoom
  attr_accessor :contains_zoomable_map
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias initialize_mgc_zoom initialize
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize(*args)
    initialize_mgc_zoom(*args)
    self.zoom = 1.0
    @contains_zoomable_map = false
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut zoom
  #--------------------------------------------------------------------------
  def zoom=(new_zoom)
    unless zoom == new_zoom
      if new_zoom < 0.125 || new_zoom > 8.0 then return end
      @zoom = new_zoom
    end
  end
end

#==============================================================================
# ** MGC::Tilemap
#==============================================================================
class OverlayTilemap
  #--------------------------------------------------------------------------
  # * Attributs
  #--------------------------------------------------------------------------
  attr_reader :viewport, :visible, :ox, :oy, :opacity, :blend_type, :color,
  :tone, :wave_amp, :wave_length, :wave_speed, :wave_phase, :zoom, :map_data,
  :flags
  attr_accessor :bitmaps, :flash_data
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  RENDER = Win32API.new("System/MGC_Map_Ace", "renderMap", "l", "l")
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    self.bitmaps = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    @map_data = 0
    @flags = 0
    self.flash_data = nil
    @cx = Graphics.width >> 1
    @cy = Graphics.height >> 1
    @sprite_render = Sprite.new(viewport)
    @render = Bitmap.new(Graphics.width + 64, Graphics.height + 64)
    @sprite_render.bitmap = @render
    @sprite_render.x = -32
    @sprite_render.y = -32
    @sprite_render.z = 0
    @sprite_render_layer2 = Sprite.new(viewport)
    @render_layer2 = Bitmap.new(Graphics.width + 64, Graphics.height + 64)
    @sprite_render_layer2.bitmap = @render_layer2
    @sprite_render_layer2.x = -32
    @sprite_render_layer2.y = -32
    @sprite_render_layer2.z = 200
    @zoom_incr = 0.0
    @zoom_duration = 0
    @parameters = [@render, @render_layer2, map_data, bitmaps,
    Cache.system('autotiles_data'), Cache.system('autotiles_data_small'),
    Cache.system('autotiles_data_xsmall'), flags, 0, 0, 0, 0, 0, 0, 1024,
    100, $game_map.loop_horizontal?, $game_map.loop_vertical?]
    self.visible = true
    self.zoom = 1.0
    self.ox = 0
    self.oy = 0
    self.opacity = 255
    self.blend_type = 0
    self.color = Color.new
    self.tone = Tone.new
    self.wave_amp = 0
    self.wave_length = 180
    self.wave_speed = 360
    self.wave_phase = 0.0
    @refresh_all = true
    @sprite_render.no_viewport_zoom = true
    @sprite_render_layer2.no_viewport_zoom = true
    viewport.contains_zoomable_map = true
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut map_data
  #--------------------------------------------------------------------------
  def map_data=(new_map_data)
    @map_data = new_map_data
    @parameters[2] = @map_data
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut flags
  #--------------------------------------------------------------------------
  def flags=(new_flags)
    @flags = new_flags
    @parameters[7] = @flags
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut zoom
  #--------------------------------------------------------------------------
  def zoom=(new_zoom)
    unless zoom == new_zoom
      if new_zoom < 0.125 || new_zoom > 8.0 then return end
      @zoom = new_zoom
      @parameters[14] = (1024.0 / new_zoom).to_i
      vox = @ox
      @ox = nil
      self.ox = vox
      voy = @oy
      @oy = nil
      self.oy = voy
      @need_refresh = true
      @refresh_all = true
    end
  end
  #--------------------------------------------------------------------------
  # * Incrementation de la valeur du zoom
  #--------------------------------------------------------------------------
  def incr_zoom(val = 0.02)
    @zoom_incr += val
    new_zoom = 2 ** @zoom_incr
    self.zoom = new_zoom
  end
  #--------------------------------------------------------------------------
  # * Pour aller progressivement vers une nouvelle valeur de zoom
  #--------------------------------------------------------------------------
  def to_zoom(new_zoom, duration)
    unless zoom == new_zoom
      if new_zoom < 0.125 || new_zoom > 8.0 then return end
      @zoom_duration = duration
      target_zoom_incr = Math.log(new_zoom) / Math.log(2)
      @zoom_step = (target_zoom_incr - @zoom_incr) / duration
      @target_zoom = new_zoom
    end
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut visible
  #--------------------------------------------------------------------------
  def shadow_opacity=(value)
    @parameters[15] = [[value, 0].max, 255].min
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut visible
  #--------------------------------------------------------------------------
  def visible=(flag)
    @visible = flag
    @sprite_render.visible = flag
    @sprite_render_layer2.visible = flag
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut ox
  #--------------------------------------------------------------------------
  def ox=(new_ox)
    @parameters[12] = 0
    unless new_ox == @ox
      if ox && $game_map.loop_horizontal?
        if (new_ox.to_i - ox >> 5) == $game_map.width - 1 ||
          (ox - new_ox.to_i >> 5) == $game_map.width - 1
        then
          @refresh_all = true
        end
      end
      @ox = new_ox.to_i
      ox_zoom = (@ox << 10) / @parameters[14]
      ox_floor = ox_zoom >> 5 << 5
      unless ox_floor == @parameters[8]
        @parameters[12] = ox_floor - @parameters[8] >> 5
        @need_refresh = true
      end
      @parameters[8] = ox_floor
      @sprite_render.ox = ox_zoom - ox_floor
      @sprite_render_layer2.ox = @sprite_render.ox
    end
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut oy
  #--------------------------------------------------------------------------
  def oy=(new_oy)
    @parameters[13] = 0
    unless new_oy == @oy
      if oy && $game_map.loop_vertical?
        if (new_oy.to_i - oy >> 5) == $game_map.height - 1 ||
          (oy - new_oy.to_i >> 5) == $game_map.height - 1
        then
          @refresh_all = true
        end
      end
      @oy = new_oy.to_i
      oy_zoom = (@oy << 10) / @parameters[14]
      oy_floor = oy_zoom >> 5 << 5
      unless oy_floor == @parameters[9]
        @parameters[13] = oy_floor - @parameters[9] >> 5
        @need_refresh = true
      end
      @parameters[9] = oy_floor
      @sprite_render.oy = oy_zoom - oy_floor
      @sprite_render_layer2.oy = @sprite_render.oy
    end
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut opacity
  #--------------------------------------------------------------------------
  def opacity=(new_opacity)
    @opacity = new_opacity
    @sprite_render.opacity = new_opacity
    @sprite_render_layer2.opacity = new_opacity
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut blend_type
  #--------------------------------------------------------------------------
  def blend_type=(new_blend_type)
    @blend_type = new_blend_type
    @sprite_render.blend_type = new_blend_type
    @sprite_render_layer2.blend_type = new_blend_type
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut color
  #--------------------------------------------------------------------------
  def color=(new_color)
    @color = new_color
    @sprite_render.color = new_color
    @sprite_render_layer2.color = new_color
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut tone
  #--------------------------------------------------------------------------
  def tone=(new_tone)
    @tone = new_tone
    @sprite_render.tone = new_tone
    @sprite_render_layer2.tone = new_tone
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut wave_amp
  #--------------------------------------------------------------------------
  def wave_amp=(new_wave_amp)
    @wave_amp = new_wave_amp
    @sprite_render.wave_amp = new_wave_amp
    @sprite_render_layer2.wave_amp = new_wave_amp
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut wave_length
  #--------------------------------------------------------------------------
  def wave_length=(new_wave_length)
    @wave_length = new_wave_length
    @sprite_render.wave_length = new_wave_length
    @sprite_render_layer2.wave_length = new_wave_length
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut wave_speed
  #--------------------------------------------------------------------------
  def wave_speed=(new_wave_speed)
    @wave_speed = new_wave_speed
    @sprite_render.wave_speed = new_wave_speed
    @sprite_render_layer2.wave_speed = new_wave_speed
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut wave_phase
  #--------------------------------------------------------------------------
  def wave_phase=(new_wave_phase)
    @wave_phase = new_wave_phase
    @sprite_render.wave_phase = new_wave_phase
    @sprite_render_layer2.wave_phase = new_wave_phase
  end
  #--------------------------------------------------------------------------
  # * Liberation de l'instance
  #--------------------------------------------------------------------------
  def dispose
    @render.dispose
    @render_layer2.dispose
    @sprite_render.dispose
    @sprite_render_layer2.dispose
  end
  #--------------------------------------------------------------------------
  # * Retourne true si l'instance a ete liberee
  #--------------------------------------------------------------------------
  def disposed?
    return @render.disposed?
  end
  #--------------------------------------------------------------------------
  # * Mise a jour, appelee normalement a chaque frame
  #--------------------------------------------------------------------------
  def update
    if @visible
      self.zoom = viewport.zoom
      if @zoom_duration > 0
        @zoom_duration -= 1
        if @zoom_duration == 0
          self.zoom = @target_zoom
        else
          incr_zoom(@zoom_step)
        end
      end
      if Graphics.frame_count & 31 == 0
        @parameters[10] += 1
        @parameters[10] %= 3
        unless @need_refresh
          @need_refresh_anim = true
        end
      end
      if @need_refresh
        if @refresh_all
          @render.clear
          @render_layer2.clear
          @parameters[12] = 0
          @parameters[13] = 0
          @refresh_all = false
        end
        @parameters[11] = 0
        RENDER.call(@parameters.__id__)
        @need_refresh = false
      elsif @need_refresh_anim
        @parameters[11] = 1
        @parameters[12] = 0
        @parameters[13] = 0
        RENDER.call(@parameters.__id__)
        @need_refresh_anim = false
      end
      @sprite_render.update
      @sprite_render_layer2.update
    end
  end
  #--------------------------------------------------------------------------
  # * Flash des couches de la tilemap
  #--------------------------------------------------------------------------
  def flash(color, duration)
    @sprite_render.flash(color, duration)
    @sprite_render_layer2.flash(color, duration)
  end
end

#==============================================================================
# ** Plane
#==============================================================================
class Plane
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias initialize_mgc_zoom initialize
    alias ox_mgc_zoom= ox=
    alias oy_mgc_zoom= oy=
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize(*args)
    initialize_mgc_zoom(*args)
    @phase_viewport_zoom = false
    self.ox = 0
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut ox
  #--------------------------------------------------------------------------
  def ox=(new_ox)
    unless @phase_viewport_zoom
      @base_ox = new_ox
    end
    self.ox_mgc_zoom = new_ox
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut ox
  #--------------------------------------------------------------------------
  def ox
    return @base_ox
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut oy
  #--------------------------------------------------------------------------
  def oy=(new_oy)
    unless @phase_viewport_zoom
      @base_oy = new_oy
    end
    self.oy_mgc_zoom = new_oy
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut oy
  #--------------------------------------------------------------------------
  def oy
    return @base_oy
  end
  #--------------------------------------------------------------------------
  # * Mise a jour du zoom en fonction du zoom du viewport
  #--------------------------------------------------------------------------
  def update_viewport_zoom
    if TH::Overlay_Map_Zoom::Parallax_Zoom
      zoom_x == viewport.zoom
      @phase_viewport_zoom = true
      self.zoom_x = viewport.zoom
      self.zoom_y = viewport.zoom
      self.ox = - ((Graphics.width >> 1) +
      (ox - (Graphics.width >> 1)) * viewport.zoom).to_i
      self.oy = - ((Graphics.height >> 1) +
      (oy - (Graphics.height >> 1)) * viewport.zoom).to_i
      @phase_viewport_zoom = false
    end
  end
end

#==============================================================================
# ** Sprite
#==============================================================================
class Sprite
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias initialize_mgc_zoom initialize
    alias x_mgc_zoom= x=
    alias y_mgc_zoom= y=
    alias zoom_x_mgc_zoom= zoom_x=
    alias zoom_y_mgc_zoom= zoom_y=
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Attributs
  #--------------------------------------------------------------------------
  attr_accessor :no_viewport_zoom
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize(*args)
    initialize_mgc_zoom(*args)
    @phase_viewport_zoom = false
    self.x = 0
    self.y = 0
    self.zoom_x = 1.0
    self.zoom_y = 1.0
    self.no_viewport_zoom = false
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut x
  #--------------------------------------------------------------------------
  def x=(new_x)
    unless @phase_viewport_zoom
      @base_x = new_x
    end
    self.x_mgc_zoom = new_x
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut y
  #--------------------------------------------------------------------------
  def y=(new_y)
    unless @phase_viewport_zoom
      @base_y = new_y
    end
    self.y_mgc_zoom = new_y
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut x
  #--------------------------------------------------------------------------
  def x
    return @base_x
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut y
  #--------------------------------------------------------------------------
  def y
    return @base_y 
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut zoom_x
  #--------------------------------------------------------------------------
  def zoom_x=(new_zoom_x)
    unless @phase_viewport_zoom
      @base_zoom_x = new_zoom_x
    end
    self.zoom_x_mgc_zoom = new_zoom_x
  end
  #--------------------------------------------------------------------------
  # * Setter pour l'attribut zoom_y
  #--------------------------------------------------------------------------
  def zoom_y=(new_zoom_y)
    unless @phase_viewport_zoom
      @base_zoom_y = new_zoom_y
    end
    self.zoom_y_mgc_zoom = new_zoom_y
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut zoom_x
  #--------------------------------------------------------------------------
  def zoom_x
    return @base_zoom_x
  end
  #--------------------------------------------------------------------------
  # * Getter pour l'attribut zoom_y
  #--------------------------------------------------------------------------
  def zoom_y
    return @base_zoom_y 
  end
  #--------------------------------------------------------------------------
  # * Valeur reelle du zoom_x en prenant en compte le zoom de la carte
  #--------------------------------------------------------------------------
  def zoom_x_global
    return @zoom_x
  end
  #--------------------------------------------------------------------------
  # * Valeur reelle du zoom_y en prenant en compte le zoom de la carte
  #--------------------------------------------------------------------------
  def zoom_y_global
    return @zoom_y 
  end
end

#==============================================================================
# ** Sprite and all its subclasses
#==============================================================================
[:Sprite, :Sprite_Base, :Sprite_Character, :Sprite_Battler, :Sprite_Picture,
:Sprite_Timer].each {|classname|
  parent = eval("#{classname}.superclass")
  eval(
  "class #{classname} < #{parent}
    unless @already_aliased_mgc_zoom_#{classname}
      alias update_mgc_zoom_#{classname} update
      @already_aliased_mgc_zoom_#{classname} = true
    end
    def update
      update_mgc_zoom_#{classname}
      if self.instance_of?(#{classname})
        unless viewport.nil? || no_viewport_zoom || !viewport.contains_zoomable_map
          @phase_viewport_zoom = true
          self.zoom_x = @base_zoom_x * viewport.zoom
          self.zoom_y = @base_zoom_y * viewport.zoom
          self.x = ((Graphics.width >> 1) +
          (x - (Graphics.width >> 1)) * viewport.zoom).to_i
          self.y = ((Graphics.height >> 1) +
          (y - (Graphics.height >> 1)) * viewport.zoom).to_i
          @phase_viewport_zoom = false
        end
      end
    end
  end")
}

#==============================================================================
# ** Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias update_balloon_mgc_zoom update_balloon
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Update Balloon Icon
  #--------------------------------------------------------------------------
  def update_balloon
    update_balloon_mgc_zoom
    if @balloon_sprite then @balloon_sprite.update end
  end
end

#==============================================================================
# ** Sprite_Base
#==============================================================================
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias animation_set_sprites_mgc_zoom animation_set_sprites
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data (RPG::Animation::Frame)
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    animation_set_sprites_mgc_zoom(frame)
    @ani_sprites.each {|sprite| sprite.update}
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_OverlayMap < Game_Map
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_zoom
    alias set_display_pos_mgc_zoom set_display_pos
    alias scroll_down_mgc_zoom scroll_down
    alias scroll_left_mgc_zoom scroll_left
    alias scroll_right_mgc_zoom scroll_right
    alias scroll_up_mgc_zoom scroll_up
    @already_aliased_mgc_zoom = true
  end
  #--------------------------------------------------------------------------
  # * Set Display Position
  #--------------------------------------------------------------------------
  def set_display_pos(x, y)
    if MGC.zoom_map_active
      if loop_horizontal?
        @display_x = (x + width) % width
      else
        if width * MGC.map_zoom < screen_tile_x
          @display_x = (width - screen_tile_x).abs / 2
        else
          x_min = screen_tile_x * (1.0 / MGC.map_zoom - 1.0) / 2
          x_max = width + screen_tile_x * ((1.0 - 1.0 / MGC.map_zoom) / 2 - 1)
          x = [x_min, [x, x_max].min].max
          @display_x = x
        end
      end
      if loop_vertical?
        @display_y = (y + height) % height
      else
        if height * MGC.map_zoom < screen_tile_y
          @display_y = (height - screen_tile_y).abs / 2
        else
          y_min = screen_tile_y * (1.0 / MGC.map_zoom - 1.0) / 2
          y_max = height + screen_tile_y * ((1.0 - 1.0 / MGC.map_zoom) / 2 - 1)
          y = [y_min, [y, y_max].min].max
          @display_y = y
        end
      end
      @parallax_x = x
      @parallax_y = y
    else
      set_display_pos_mgc_zoom(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if MGC.zoom_map_active
      if loop_vertical?
        @display_y += distance
        @display_y %= @map.height
        @parallax_y += distance if @parallax_loop_y
      else
        last_y = @display_y
        if height * MGC.map_zoom < screen_tile_y
          @display_y = (height - screen_tile_y).abs / 2
        else
          max = height + screen_tile_y * ((1.0 - 1.0 / MGC.map_zoom) / 2 - 1)
          @display_y = [@display_y + distance, max].min
        end
        @parallax_y += @display_y - last_y
      end
    else
      scroll_down_mgc_zoom(distance)
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if MGC.zoom_map_active
      if loop_horizontal?
        @display_x += @map.width - distance
        @display_x %= @map.width 
        @parallax_x -= distance if @parallax_loop_x
      else
        last_x = @display_x
        if width * MGC.map_zoom < screen_tile_x
          @display_x = (width - screen_tile_x).abs / 2
        else
          min = screen_tile_x * (1.0 / MGC.map_zoom - 1.0) / 2
          @display_x = [@display_x - distance, min].max
        end
        @parallax_x += @display_x - last_x
      end
    else
      scroll_left_mgc_zoom(distance)
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if MGC.zoom_map_active
      if loop_horizontal?
        @display_x += distance
        @display_x %= @map.width
        @parallax_x += distance if @parallax_loop_x
      else
        last_x = @display_x
        if width * MGC.map_zoom < screen_tile_x
          @display_x = (width - screen_tile_x).abs / 2
        else
          max = width + screen_tile_x * ((1.0 - 1.0 / MGC.map_zoom) / 2 - 1)
          @display_x = [@display_x + distance, max].min
        end
        @parallax_x += @display_x - last_x
      end
    else
      scroll_right_mgc_zoom(distance)
    end
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if MGC.zoom_map_active
      if loop_vertical?
        @display_y += @map.height - distance
        @display_y %= @map.height
        @parallax_y -= distance if @parallax_loop_y
      else
        last_y = @display_y
        if height * MGC.map_zoom < screen_tile_y
          @display_y = (height - screen_tile_y).abs / 2
        else
          min = screen_tile_y * (1.0 / MGC.map_zoom - 1.0) / 2
          @display_y = [@display_y - distance, min].max
        end
        @parallax_y += @display_y - last_y
      end
    else
      scroll_up_mgc_zoom(distance)
    end
  end
end