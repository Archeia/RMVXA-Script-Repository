#==============================================================================#
# ** IEX(Icy Engine Xelion) - Map Overlays
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Map)
# ** Script-Type   : Fog Effects
# ** Date Created  : 08/16/2010 (DD/MM/YYYY)
# ** Date Modified : 08/07/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Map Overlays
# ** Difficulty    : Normal, Hard
# ** Version       : 2.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script allows to apply a set of fog effects above or and below your map.
# These effects are customizable.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
# 2.0 Tags! Apply to Maps Name
#------------------------------------------------------------------------------#
# <overlay: overlay_set_name>
#
# You can use as many of these tags as you like in the maps name.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
#
# Below
#  Materials
#  Anything that makes changes to sprites
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#------------------------------------------------------------------------------#
# Classes
# new-class IEX_Map_Overlay_Sprite
#   RPG::MapInfo
#     alias      :name
#     new-method :get_overlays
#   Game_Map
#     new-method :iex_overlays
#   Spriteset_Map
#     alias      :create_parallax
#     alias      :dispose_parallax
#     alias      :update_parallax
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  08/16/2010 - V1.0  Started And Finished Script
#  12/07/2010 - V2.0  Reworked Script
#  01/08/2010 - V2.0a Small Change
#  08/07/2011 - V2.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {}
if $imported["IEX_Environment"]
  $iex_map_overlays_on = IEX::ENVIRONMENT::MAP_OVERLAY_SYSTEM
else
  $iex_map_overlays_on = true
end

if $iex_map_overlays_on
  $imported["IEX_Map_Overlays"] = true

#==============================================================================#
# ** IEX::MAP_OVERLAY
#==============================================================================#
module IEX
  module MAP_OVERLAY
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * OVERLAY_GROUPS
  #--------------------------------------------------------------------------#
  # This is a set of overlays, because it would be tedious to create multiple
  # fogs for a map, without having the map name, being super long
  # I decided to turn it into a hash and use the name to reference it.
  #
  # Compulsory settings
  # :filename
  # :x_multi
  # :y_multi
  # :z_pos
  # :opacity
  # :blend_type
  # :negative
  #
  # Optional Settings
  # :tone_over
  # :below
  #
  #--------------------------------------------------------------------------#
    OVERLAY_GROUPS = {}
    OVERLAY_GROUPS["BasicFog"] = {
    :filename =>"Niebla",
    :x_multi => -1,
    :y_multi => 1,
    :z_pos => 320,
    :opacity => 48,
    :blend_type => 1,
    :negative => false,
    #:below => false,
    #:tone_over => Tone.new(-128, -54, 0),
    }

    OVERLAY_GROUPS["Sunlight"] = {
    :filename =>"BrightSunlight",
    :x_multi => 0,
    :y_multi => 0,
    :z_pos => 320,
    :opacity => 48,
    :blend_type => 1,
    :negative => false,
    #:below => false,
    #:tone_over => Tone.new(-128, -54, 0),
    }

    OVERLAY_GROUPS["DemiscuBasic"] = {
    :filename =>"Sombra1",
    :x_multi => 1,
    :y_multi => 1,
    :z_pos => 320,
    :opacity => 44,
    :blend_type => 1,
    :negative => true,
    #:tone_over => Tone.new(-128, -54, 0),
    }

    OVERLAY_GROUPS["DesertBasic"] = {
    :filename =>"005-Sandstorm01",
    :x_multi => 1,
    :y_multi => 0.8,
    :z_pos => 320,
    :opacity => 64,
    :blend_type => 1,
    :negative => true,
    :tone_over => Tone.new(128, 54, 0),
    }
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# ** IEX_Map_Overlay_Sprite
#==============================================================================#
class IEX_Map_Overlay_Sprite < Plane

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :x_speed
  attr_accessor :y_speed
  attr_accessor :negative

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(viewport = nil)
    super(viewport)
    @x_speed = 1
    @y_speed = 1
    @negative = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_scroll
  #--------------------------------------------------------------------------#
  def update_scroll()
    if @negative
      self.ox = -$game_map.calc_parallax_x(self.bitmap) * @x_speed
      self.oy = -$game_map.calc_parallax_y(self.bitmap) * @y_speed
     else
      self.ox = $game_map.calc_parallax_x(self.bitmap) * @x_speed
      self.oy = $game_map.calc_parallax_y(self.bitmap) * @y_speed
    end
  end

end

#==============================================================================#
# ** RPG::MapInfo
#==============================================================================#
class RPG::MapInfo

  #--------------------------------------------------------------------------#
  # * new-method :name
  #--------------------------------------------------------------------------#
  def name() ; return @name end unless method_defined? :name

  #--------------------------------------------------------------------------#
  # * alias-method :name
  #--------------------------------------------------------------------------#
  alias iex_map_overlays_name name unless $@
  def name()
    oldnma = iex_map_overlays_name
    oldnma.gsub!(/<(?:OVERLAY):[ ]*(.*)>/i) { "" }
    return oldnma
  end

  #--------------------------------------------------------------------------#
  # * alias-method :get_overlays
  #--------------------------------------------------------------------------#
  def get_overlays()
    if @ovset.nil?()
      @ovset = []
      @name.scan(/<(?:OVERLAY):[ ]*(.*)>/i).each { |set|
        @ovset.push(IEX::MAP_OVERLAY::OVERLAY_GROUPS[set.to_s]) }
    end
    return @ovset
  end

end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :iex_overlays
  #--------------------------------------------------------------------------#
  def iex_overlays()
    if @map_infos == nil
      @map_infos = load_data("Data/MapInfos.rvdata")
    end
    return @map_infos[@map_id].get_overlays
  end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * alias-method :create_parallax
  #--------------------------------------------------------------------------#
  alias :iex_map_overlays_spm_create_parallax :create_parallax unless $@
  def create_parallax( *args, &block )
    iex_map_overlays_spm_create_parallax( *args, &block )
    @iex_overlays = {}
    iex_store_map = $game_map.iex_overlays
    @iex_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @iex_viewport.z = 30
    @iex_viewport_low = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @iex_viewport_low.z = -50
    unless iex_store_map.empty?
      count = 0
      iex_store_map.each { |iex_ov|
      next if iex_ov == nil
      if iex_ov[:below] == true and iex_ov[:below] != nil
        #@iex_overlays[count] = IEX_Map_Overlay_Sprite.new(@viewport1)#(@iex_viewport_low)
        @iex_overlays[count] = IEX_Map_Overlay_Sprite.new(@iex_viewport_low)
        @iex_overlays[count] -= 10
      else
        #@iex_overlays[count] = IEX_Map_Overlay_Sprite.new(@viewport1)#(@iex_viewport)
        @iex_overlays[count] = IEX_Map_Overlay_Sprite.new(@iex_viewport)
        @iex_overlays[count].z += 200
      end
      @iex_overlays[count].bitmap = Cache.parallax(iex_ov[:filename])
      @iex_overlays[count].x_speed = iex_ov[:x_multi]
      @iex_overlays[count].y_speed = iex_ov[:y_multi]
      @iex_overlays[count].z = iex_ov[:z_pos]
      @iex_overlays[count].opacity = iex_ov[:opacity]
      @iex_overlays[count].blend_type = iex_ov[:blend_type]
      if iex_ov.has_key?(:tone_over)
        @iex_overlays[count].tone = iex_ov[:tone_over]
      end
      count += 1
      }
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose_parallax
  #--------------------------------------------------------------------------#
  alias :iex_map_overlays_spm_dispose_parallax :dispose_parallax unless $@
  def dispose_parallax( *args, &block )
    if @iex_overlays != nil and !@iex_overlays.empty?
      for over in @iex_overlays.keys
        next if over == nil
        next if @iex_overlays[over] == nil
        @iex_overlays[over].dispose
        @iex_overlays[over] = nil
      end
      @iex_overlays.clear
      @iex_overlays = nil
    end
    if @iex_viewport != nil
      @iex_viewport.dispose
      @iex_viewport = nil
    end
    if @iex_viewport_low != nil
      @iex_viewport_low.dispose
      @iex_viewport_low = nil
    end
    iex_map_overlays_spm_dispose_parallax( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update_parallax
  #--------------------------------------------------------------------------#
  alias :iex_map_overlays_spm_update_parallax :update_parallax unless $@
  def update_parallax( *args, &block )
    if @iex_overlays != nil and !@iex_overlays.empty?
      for over in @iex_overlays.keys
        next if over == nil
        @iex_overlays[over].update_scroll
      end
    end
    iex_map_overlays_spm_update_parallax( *args, &block )
  end
end

end # Use script

#==============================================================================#
# ** END OF FILE
#==============================================================================#
