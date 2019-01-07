###--------------------------------------------------------------------------###
#  Animated Battler Graphic script                                             #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 11.27.2011                                                           #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Game_Enemy:  initialize                                       #
#                Scene_Title:  load_bt_database, load_database                 #
#  Overwrites  - Sprite_Battler:  update_battler_bitmap                        #
#  New Objects - Game_Enemy: ani_frames, z_size                                #
#                Sprite_Battler: animated_sprite_bitmap                        #
#                Scene_Title: load_cp_ani_cache                                #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is plug and play and needs no modding to work.  Some monster    #
#  commands are available below and described in some detail.                  #
#                                                                              #
#      Commands:                                                               #
#  sprite[x:y]  - Used to define an animations sheet.  Place this command in   #
#                 the description box of whatever monster you want to change.  #
#                 Change "x" to the filename for the animation sheet.          #
#                 Change "y" to the number of frames contained in the sheet.   #
#                                                                              #
#                 Example: "sprite[Gallade:10]                                 #
#                          The monster graphic "Gallade" will be used and the  #
#                          graphic will cycle through 10 stages of animation.  #
#                                                                              #
#      zoom[x]  - Change the size of the battler where "x" is the actual       #
#                 pixel size.  For example, 100% zoome is just "1", 200% zoom  #
#                 is "2", etc.  It is important to note that this command may  #
#                 only be used on animated battlers.                           #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

class Game_Enemy < Game_Battler
  alias cp_ani_initialize initialize unless $@
  def initialize(index, enemy_id)
    cp_ani_initialize(index, enemy_id)
    @ani_frames = enemy.ani_frames
    @z_size = enemy.z_size
  end
    ####-------------------------------------------------
    #New objects used to properly call the new variables.
  def ani_frames
    return @ani_frames
  end
  
  def z_size
    return @z_size
  end
end

class Sprite_Battler < Sprite_Base
  def update_battler_bitmap
    @frame_count = 0 if @frame_count == nil
    @frame_count += 1 if @ani_frames != 0
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue or
       @frame_count >= 4
      @frame_count = 0
      @ani_frames = @battler.ani_frames
      @z_size = @battler.z_size
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      if @ani_frames == 0
        self.bitmap = Cache.battler(@battler_name, @battler_hue)
      else
        self.bitmap = animated_sprite_bitmap
      end
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
  end  
    ####-----------------------------------------
    #New object used to draw the animated sprite.
  def animated_sprite_bitmap
    @frame_set = -1 if @frame_set == nil
    @frame_set += 1
    @frame_set = 0 if @frame_set >= @ani_frames
    
    zi = @z_size
    tempbat = Cache.battler(@battler_name, @battler_hue)
    howide = tempbat.width / @ani_frames
    temprec = Rect.new(@frame_set * howide, 0, howide, tempbat.height)
    tempmap = Bitmap.new(tempbat.width / @ani_frames * zi, tempbat.height * zi)
    tempmap.stretch_blt(tempmap.rect, tempbat, temprec)
    return tempmap
  end
end

module CP
  module REGEXP
    module ENEMY
      SPRITE = /sprite\[(\w+):(\d+)\]/i
      ZSIZE = /zoom\[(\d+)\]/i
    end
  end
end

class RPG::Enemy
  attr_accessor :ani_frames
  attr_accessor :z_size
  
  def cache_enemy_cp_ani
    return if @cp_cached_enemy; @cp_cached_enemy = true
    @ani_frames = 0
    @z_size = 1
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when CP::REGEXP::ENEMY::SPRITE
        @battler_name = $1.to_s
        @ani_frames = $2.to_i
      when CP::REGEXP::ENEMY::ZSIZE
        @z_size = $1.to_i
      end
    }
  end
end

class Scene_Title < Scene_Base
  alias cp_bt_load_database load_bt_database unless $@
  def load_bt_database
    cp_bt_load_database
    load_cp_ani_cache
  end
  
  alias cp_ani_load_database load_database unless $@
  def load_database
    cp_ani_load_database
    load_cp_ani_cache
  end
  
  def load_cp_ani_cache
    for obj in $data_enemies
      next if obj == nil
      obj.cache_enemy_cp_ani if obj.is_a?(RPG::Enemy)
    end
  end
end