class Spriteset_Battle
  def battleback1_bitmap
    if battleback1_name      
      bitmap = Bitmap.new(Graphics.width,Graphics.height)
      bit = Cache.battleback1(battleback1_name)
      bitmap.stretch_blt(bitmap.rect, bit, bit.rect)
      return bitmap
    else
      create_blurry_background_bitmap
    end
  end

  def battleback2_bitmap
    if battleback2_name
      bitmap = Bitmap.new(Graphics.width,Graphics.height)
      bit = Cache.battleback2(battleback2_name)
      bitmap.stretch_blt(bitmap.rect, bit, bit.rect)
      return bitmap
    else
      Bitmap.new(1, 1)
    end
  end
end