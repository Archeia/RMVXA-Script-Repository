=begin
Khas Awesome Light Effects - Disable Switch addon
v1.0 - DrDhoom
=end

module Dhoom
  module KALE
    SWITCH_DISABLE_LIGHT_EFFECTS = 10
  end
end

class Spriteset_Map
  include Dhoom::KALE
  def dispose_lights
    $game_map.lantern.dispose
    $game_map.light_sources.each { |source| source.dispose_light }
    unless $game_map.light_surface.nil?
      $game_map.light_surface.bitmap.dispose
      $game_map.light_surface.dispose
      $game_map.light_surface = nil
    end
  end
  
  alias dhoom_kale_sprsmap_update_lights update_lights
  def update_lights
    return if $game_switches[SWITCH_DISABLE_LIGHT_EFFECTS]
    dhoom_kale_sprsmap_update_lights
  end
  
  alias dhoom_kale_sprsmap_setup_lights  setup_lights 
  def setup_lights   
    return if $game_switches[SWITCH_DISABLE_LIGHT_EFFECTS]
    dhoom_kale_sprsmap_setup_lights
  end
end