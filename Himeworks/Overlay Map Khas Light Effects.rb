#===============================================================================
# Patch for khas awesome light effects and Overlay Maps
# Place this script below both scripts and above Main
#===============================================================================
class Game_OverlayMap < Game_Map
  
  alias :th_khas_light_effects_overlay_maps_setup_events :setup_events
  def setup_events    
    @light_sources.nil? ? @light_sources = [] : @light_sources.clear
    setup_surfaces    
    merge_surfaces
    th_khas_light_effects_overlay_maps_setup_events
  end
end

class Spriteset_OverlayMap < Spriteset_Map 
  def dispose_lights
    @map.lantern.dispose
    @map.light_sources.each { |source| source.dispose_light }
    @map.light_surface.bitmap.dispose
    @map.light_surface.dispose
    @map.light_surface = nil
  end
  def update_lights
    @map.light_surface.bitmap.clear
    @map.light_surface.bitmap.fill_rect(0,0,640,480,@map.effect_surface.color)
    @map.light_sources.each { |source| source.draw_light }
    return unless @map.lantern.visible
    @btr = @map.lantern.get_graphic
    x = @map.lantern.x
    y = @map.lantern.y
    r = @map.lantern.range
    sx = x + r
    sy = y + r
    dr = r*2
    @map.surfaces.each { |s| s.render_shadow(x,y,sx,sy,r,@btr) if s.visible?(sx,sy) && s.within?(x,x+dr,y,y+dr) }
    @map.light_surface.bitmap.blt(@map.lantern.sx,@map.lantern.sy,@btr,Rect.new(0,0,dr,dr),@map.lantern.opacity)
  end
  def setup_lights
    @btr = nil    
    @map.lantern.restore
    @map.light_sources.each { |source| source.restore_light }
    @map.light_surface = Sprite.new
    @map.light_surface.bitmap = Bitmap.new(640,480)
    @map.light_surface.bitmap.fill_rect(0,0,640,480,@map.effect_surface.color)
    @map.light_surface.blend_type = 2
    @map.light_surface.opacity = @map.effect_surface.alpha
    @map.light_surface.z = Surface_Z
  end
end