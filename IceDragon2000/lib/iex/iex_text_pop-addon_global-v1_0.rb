#==============================================================================#
# ** IEX(Icy Engine Xelion) - Global Text Pop
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon > IEX - Text Pop
# ** Requires      : IEX - Text Pop
# ** Date Created  : 10/18/2010
# ** Date Modified : 10/23/2010
# ** Version       : 1.0
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
#  This is an addon for the IEX - Text Pop, instead of the sprite handling
#  the pops, it is sent to the map for handling instead, this allows the
#  pop to continue after the parents removal.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# 10/23/2010 - V1.0 Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Yggdrasil_Text_Pop"] = true

if $imported["IEX_Text_Pop"]
  
class Scene_Map < Scene_Base
  attr_accessor :iex_ygg_global_text_pops
  
  alias iex_yggdrasil_text_pop_patch_initialize initialize unless $@
  def initialize(*args)
    iex_yggdrasil_text_pop_patch_initialize(*args)
    @iex_ygg_global_text_pops = []
    @iex_ygg_needs_compact = false
  end
  
  alias iex_yggdrasil_text_pop_patch_terminate terminate unless $@
  def terminate(*args)
    iex_yggdrasil_text_pop_patch_terminate(*args)
    for spr in @iex_ygg_global_text_pops
      next if spr == nil
      spr[0].dispose if spr[0] != nil
      spr[0] = nil
      spr[1] = nil
    end  
    @iex_ygg_global_text_pops.clear
    @iex_ygg_global_text_pops = []
  end
  
  alias iex_yggdrasil_text_pop_patch_update update unless $@
  def update(*args)
    iex_yggdrasil_text_pop_patch_update(*args)
    iex_ygg_update_text_pops
  end
  
  def iex_ygg_update_text_pops
    fin = []
    @iex_ygg_needs_compact = false
    return if @iex_ygg_global_text_pops.empty?
    for i in 0..@iex_ygg_global_text_pops.size
      spri = @iex_ygg_global_text_pops[i]
      next if spri == nil
      if spri[1] == nil or spri[0] == nil
        @iex_ygg_needs_compact = true
        next
      end  
      fin.push(spri[1].finished)
      if spri[1].finished
        iex_ygg_dispose_text_pop(spri)
        @iex_ygg_global_text_pops.delete(i)
        spri[0] = nil
        spri[1] = nil
      else
        spri[1].pop_update
      end
    end
    if @iex_ygg_needs_compact
      @iex_ygg_global_text_pops.compact!
      @iex_ygg_needs_compact = false
    end  
    @iex_ygg_global_text_pops.clear if fin.all?
    fin.clear
  end
  
  def iex_ygg_dispose_text_pop(spri)
    return if spri == nil
    return if spri[0] == nil
    spri[1].stop_update = true
    spri[0].dispose
  end
  
end

class Sprite_Character < Sprite_Base
  
  alias iex_yggdrasil_text_pop_patch_update update unless $@
  def update
    iex_yggdrasil_text_pop_patch_update
    unless @ixtp_text_pop.empty?
      if $scene.is_a?(Scene_Map)
        $scene.iex_ygg_global_text_pops += @ixtp_text_pop
        @ixtp_text_pop.clear
        @ixtp_text_pop = []
      end
    end    
  end
  
  def ixtp_update_text_pop
  end
  
  def ixtp_dispose_text_pop
  end
    
  def ixtp_dispose_all_text_pop
    @ixtp_text_pop.clear
    @ixtp_text_pop = []
  end
  
end

end