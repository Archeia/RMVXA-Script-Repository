#===========================================================================
# Animated Battlebacks (VX)
#   by jmoresca 
#   July 18,2009
#
# Ported to RMVXA
#   by DrDhoom
#   May 20, 2013
#===========================================================================
# 
# How to use:
#    Just configure the AnimBB module
#
# FAQ's
#    How to set the Animated Battlebacks?
#       Save your set of images like this : <name of battle back><anim no>
#       Example:
#          if you have a BattleBack named "sample_bb" then
#          image set will be: sample_bb1, sample_bb2, sample_bb3  
# 
#    How to set Animation Speed?
#       edit FRAMES_PER_UPDATE or you can specify a battleback on UPDATE_PER_BB
#
#============================================================================
module AnimBB
  FRAMES_PER_UPDATE = 20 #Adjust the speed here. [The lower the faster]
  UPDATE_PER_BB = {"Clouds"=>40,"desert_0"=>22, "mansion_0"=>6, "gate_0"=>12} #Speed for specific background
end
class Spriteset_Battle
  include AnimBB
  
  def update_battleback1
    if battleback1_name
      @updateBB1_no = @updateBB1_no + 1
      if @count1 != 0
        if UPDATE_PER_BB.include?(@originalBB1)
          if UPDATE_PER_BB[@originalBB1] == @updateBB1_no
            @updateBB1_no = 0
            @frame_no1 = @frame_no1 + 1
            if @frame_no1 > @count1
              @back1_sprite.bitmap = Cache.battleback1(@originalBB1)
              @frame_no1 = 0
            else
              @back1_sprite.bitmap = Cache.battleback1(@originalBB1 + (@frame_no1).to_s)
            end
          end
        else
          if @updateBB1_no == FRAMES_PER_UPDATE
            @updateBB1_no = 0
            @frame_no1 = @frame_no1 + 1
            if @frame_no1 > @count1
              @back1_sprite.bitmap = Cache.battleback1(@originalBB1)
              @frame_no1 = 0
            else
              @back1_sprite.bitmap = Cache.battleback1(@originalBB1 + (@frame_no1).to_s)
            end
          end
        end
      else
        @updateBB1_no = 0
      end
      @back1_sprite.update
    else
      @back1_sprite.update
    end
  end
  
  def update_battleback2
    if battleback2_name
      @updateBB2_no = @updateBB2_no + 1
      if @count2 != 0
        if UPDATE_PER_BB.include?(@originalBB2)
          if UPDATE_PER_BB[@originalBB2] == @updateBB2_no
            @updateBB2_no = 0
            @frame_no2 = @frame_no2 + 1
            if @frame_no2 > @count2
              @back2_sprite.bitmap = Cache.battleback2(@originalBB2)
              @frame_no2 = 0
            else
              @back2_sprite.bitmap = Cache.battleback2(@originalBB2 + (@frame_no2).to_s)
            end
          end
        else
          if @updateBB2_no == FRAMES_PER_UPDATE
            @updateBB2_no = 0
            @frame_no2 = @frame_no2 + 1
            if @frame_no2 > @count2
              @back2_sprite.bitmap = Cache.battleback2(@originalBB2)
              @frame_no2 = 0
            else
              @back2_sprite.bitmap = Cache.battleback2(@originalBB2 + (@frame_no2).to_s)
            end
          end
        end
      else
        @updateBB2_no = 0
      end
      @back2_sprite.update
    else
      @back2_sprite.update
    end
  end

  def create_battleback1
    if battleback1_name
      @originalBB1 = battleback1_name
      @count1 = 0
      @updateBB1_no = 0
      @frame_no1 = 0
      loop do
        begin
          @count1 += 1
          sample = Cache.battleback1(@originalBB1 + @count1.to_s)
        rescue
          @count1 -= 1
          break
        end
      end      
    end
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  
  def create_battleback2
    if battleback2_name
      @originalBB2 = battleback2_name
      @count2 = 0
      @updateBB2_no = 0
      @frame_no2 = 0
      loop do
        begin
          @count2 = @count2 + 1
          sample = Cache.battleback2(@originalBB2 + @count2.to_s)
        rescue
          @count2 = @count2 - 1
          break
        end
      end      
    end
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z = 0
    center_sprite(@back2_sprite)
  end
end