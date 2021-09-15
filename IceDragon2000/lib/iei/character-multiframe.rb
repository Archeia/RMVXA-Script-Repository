#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Character Multi Frames"
#-define HDR_GDC :dc=>"05/21/2012"
#-define HDR_GDM :dm=>"05/21/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"0.1"
#-inject gen_script_header_wotail HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#-inject gen_script_des "How To Use"
=begin
 -- This is a BETA script, and is therefore not final
 put #[number_of_columns,number_of_rows] in a filename to modify its
 default frame progression
 EG.
   $Actor4#[12,8].png
 --
 To modify the frame order simply change use a 'script' command
 in a 'move route'
   self.anime_style = n
   n is:
     0 - Ping Pong, 1 - Forward, 2 - Reverse, 3 - Random
 --
=end
$simport.r 'iei/multiframe', '1.0.0', 'IEI Multiframe'
#-inject gen_class_header "Game_Character"
class Game::Character

  def pattern_frames
    @pattern_frames ||= begin
      n = @character_name.match(/\#\[(\d+),(\d+)\]/)||[nil,3,4]
      n[1,2].map{|s|s.to_i}
    end
  end

  def update_anime_pattern
    if @last_char_name != @character_name
      @defpattern_a = @pattern_frames = nil
      @last_char_name = @character_name
    end
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % (pattern_frames[0] + anime_frame_add)
    end
  end

  def anime_frame_add
    return 1 if anime_style == 0
    0
  end

  # // 0 - Ping Pong, 1 - Forward, 2 - Reverse, 3 - Random
  def anime_style
    @anime_style ||= 0
  end

  attr_writer :anime_style

  def anime_pattern
    case anime_style
    when 0 ;
      (@defpattern_a||=((0...pattern_frames[0]).to_a+(1...(pattern_frames[0]-1)).to_a.reverse))[@pattern]
    when 1 ; @pattern
    when 2 ; pattern_frames[0] - @pattern
    when 3 ; rand(pattern_frames[0])
    end
  end

end

#-inject gen_class_header "Sprite_Character"
class Sprite::Character

  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    hfrms, vfrms = @character ? @character.pattern_frames : [3,4]
    if sign && sign.include?('$')
      @cw = bitmap.width / hfrms
      @ch = bitmap.height / vfrms
    else
      @cw = bitmap.width / (hfrms * 4)
      @ch = bitmap.height / (vfrms * 2)
    end
    self.ox = @cw / 2
    self.oy = @ch
  end

  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.anime_pattern #< 3 ? @character.pattern : 1
      hfrms, vfrms = @character.pattern_frames
      sx = (index % 4 * hfrms + pattern) * @cw
      sy = (index / 4 * vfrms + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end

end
#-inject gen_script_footer
