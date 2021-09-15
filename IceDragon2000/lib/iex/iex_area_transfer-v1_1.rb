#==============================================================================#
# ** IEX(Icy Engine Xelion) - Area Transfer
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Area)
# ** Script Type   : Map Transfer Via Areas
# ** Date Created  : 11/02/2010 (DD/MM/YYYY)
# ** Date Modified : 07/17/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Area Transfer
# ** Difficulty    : Normal
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This allows areas to transfer the player to another map just like a event..
# Nothing more to say..
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
#  Put <trans area: map_id, x, y, direction, compensate_offset> in an area's name
#  map_id is straight forward
#
#  x and y are the transfer positions
#
#  direction
#  2 - Down 
#  4 - Left
#  6 - Right
#  8 - Up
#
#  compensate_offset (Set to 0 if not using)
#  Is a bit hard to explain, this will offset the player correctly when using the
#  transfer area to another map... >,< Though Unspeakable evil will happen
#  If they aren't the same size..
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Anything that makes changes to areas.
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Should have no problems
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   RPG::Area 
#     new-method :transfer_area?
#     new-method :get_transfer_info
#     new-method :iex_valid_area?
#     new-method :iex_map_x
#     new-method :iex_map_y
#   Game_Map
#     alias      :setup
#     new-method :iex_setup_transfer_table
#     new-method :valid_transfer_coord?
#     new-method :get_transfer_area
#   Game_Player
#     alias      :initialize
#     alias      :update
#     new-method :iex_artrnfs_phs1
#     new-method :iex_artrnfs_phs2
#     new-method :iex_artrnfs_phs3
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  10/29/2010 - V1.0  Finished Script
#  01/03/2011 - V1.0a Bug Fix, Double Transfer?
#  01/07/2011 - V1.0b Bug Fix, Double Transfer
#  01/08/2011 - V1.0c Small Change
#  01/16/2011 - V1.0d Unsharpened Transfer
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Transfer has sharpened (The moment the player moves inside the Area, they
#  will be transfered)
#
#------------------------------------------------------------------------------#
$imported ||= {} 
$imported["IEX_AreaTransfer"] = true

#==============================================================================#
# ** IEX::AREA_TRANSFER
#==============================================================================#
module IEX
  module AREA_TRANSFER
    #            ['filename', volume, pitch]
    MOVE_SOUND = ["Move",         90,   100]
  end  
end  

#==============================================================================#
# ** RPG::Area
#==============================================================================#
class RPG::Area 

  #--------------------------------------------------------------------------#
  # * new-method :transfer_area?
  #--------------------------------------------------------------------------#  
  def transfer_area?()
    @transfer_area ||= @name =~ 
     /<(?:TRANS_AREA|trans area):[ ]*(\d+(?:\s*,\s*\d+)*)>/i ? 
     true : false 
    return @transfer_area
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :get_transfer_info
  #--------------------------------------------------------------------------#  
  def get_transfer_info
    if @transfer_info.nil?()
      @transfer_info = []
      case @name
      when /<(?:TRANS_AREA|trans area):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
        @transfer_info
        $1.scan(/\d+/).each { |val| 
        @transfer_info.push(val.to_i)}
      end
    end  
    return @transfer_info
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_valid_area?
  #--------------------------------------------------------------------------#  
  def iex_valid_area?( x_x, y_y )
    stack_ans = []
    bool_x = (x_x >= @rect.x and x_x < @rect.x + @rect.width)
      stack_ans.push(bool_x)
    bool_y = (y_y >= @rect.y and y_y < @rect.y + @rect.height)
      stack_ans.push(bool_y)
    return stack_ans
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_map_x
  #--------------------------------------------------------------------------#  
  def iex_map_x
    return @rect.x 
  end  
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_map_y
  #--------------------------------------------------------------------------#  
  def iex_map_y
    return @rect.y 
  end  
  
end

$iex_transfer_tables = {}
#==============================================================================#
# ** Game Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#   
  alias :iex_area_transfer_setup :setup unless $@
  def setup( *args, &block )
    iex_area_transfer_setup( *args, &block )
    iex_setup_transfer_table()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_setup_transfer_table
  #--------------------------------------------------------------------------#   
  def iex_setup_transfer_table()
    if $iex_transfer_tables[@map_id].nil?()
      iex_transfer_table = Table.new( @map.data.xsize, @map.data.ysize, 12 )
      valid_areas = []
      for area in $data_areas.values
        next if area == nil
        next if area.map_id != $game_map.map_id
        next unless area.transfer_area?
        valid_areas.push(area)
      end  
      for m_x in 0...self.width
        for m_y in 0...self.height
          iex_transfer_table[m_x, m_y, 0] = 0
          iex_transfer_table[m_x, m_y, 1] = 0
          for ar in valid_areas
            valid = ar.iex_valid_area?(m_x, m_y).all?()
            if valid
              transfer_data = ar.get_transfer_info
              iex_transfer_table[m_x, m_y, 0] = 1
              iex_transfer_table[m_x, m_y, 1] = ar.id
            end  
          end 
        end
      end
      $iex_transfer_tables[@map_id] = iex_transfer_table
    end
    @iex_transfer_table = $iex_transfer_tables[@map_id]
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :valid_transfer_coord?
  #--------------------------------------------------------------------------# 
  def valid_transfer_coord?( t_x, t_y )
    return @iex_transfer_table[t_x, t_y, 0] == 1 
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :get_transfer_area
  #--------------------------------------------------------------------------# 
  def get_transfer_area( t_x, t_y )
    return @iex_transfer_table[t_x, t_y, 1]
  end
  
end

#==============================================================================#
# ** Game Player
#==============================================================================#
class Game_Player < Game_Character

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------# 
  alias :iex_area_transfer_initialize :initialize unless $@
  def initialize( *args, &block )
    @prep_trans = nil
    @just_transfered = false
    iex_area_transfer_initialize( *args, &block )
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------# 
  alias :iex_area_transfer_update :update unless $@
  def update( *args, &block )
    @just_transfered = false if @iex_ply_old_x != self.x or @iex_ply_old_y != self.y
    iex_artrnfs_phs1()  
    iex_area_transfer_update( *args, &block )
    iex_artrnfs_phs2()
    iex_artrnfs_phs3()
  end
  
  #--------------------------------------------------------------------------#
  # * new-methods :ax/ay
  #--------------------------------------------------------------------------#
  def ax() ; return Integer(@real_x / 256.0) end #Integer(@real_x / 256) end
  def ay() ; return Integer(@real_y / 256.0) end #Integer(@real_y / 256) end
  
  #--------------------------------------------------------------------------#
  # * new-methods :iex_artrnfs_phs*
  #--------------------------------------------------------------------------#
  def iex_artrnfs_phs1()
    @iex_ply_old_x = self.x
    @iex_ply_old_y = self.y
  end
  
  def iex_artrnfs_phs2()
    aox = ax #- 1
    aoy = ay #- 1
    if @prep_trans.nil? and !self.moving? and !@just_transfered
      if $game_map.valid_transfer_coord?(aox, aoy)
        transfer_area = $game_map.get_transfer_area(aox, aoy)
        area = $data_areas[transfer_area]
        transfer_data = area.get_transfer_info
        tr_map_id = transfer_data[0]
        tr_x = transfer_data[1]
        tr_y = transfer_data[2]
        tr_direc = transfer_data[3]
        if transfer_data[4] == 1
          case tr_direc
          when 2, 8
            if self.x > area.iex_map_x
              tr_x += (self.x - area.iex_map_x)
            end  
          when 4, 6
            if self.y > area.iex_map_y
              tr_y += (self.y - area.iex_map_y) 
            end  
          end 
        end  
        @prep_trans = [tr_map_id, tr_x, tr_y, tr_direc].clone
      end
    end
  end
  
  def iex_artrnfs_phs3
    if !@prep_trans.nil? && (self.x == ax && self.y == ay)
      ms = IEX::AREA_TRANSFER::MOVE_SOUND
      move_sound = RPG::SE.new(ms[0], ms[1], ms[2])
      move_sound.play
      reserve_transfer(@prep_trans[0], @prep_trans[1], @prep_trans[2], 
        @prep_trans[3])
      @iex_ply_old_x = @prep_trans[1]
      @iex_ply_old_y = @prep_trans[2]
      @prep_trans = nil
      @just_transfered = true
    end
  end 
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#