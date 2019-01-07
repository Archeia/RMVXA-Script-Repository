=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - GRAPHIC SHIFT v1.0
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Support          ╒═════════════════════════════════════════════════════════╛
 While I'm flattered and I'm glad that people have been sharing and asking
 support for scripts in other RPG Maker communities, I would like to ask that
 you please avoid posting my scripts outside of where I frequent because it
 would make finding support and fixing bugs difficult for both of you and me.
   
 If you're ever looking for support, I can be reached at the following:
 ╔═════════════════════════════════════════════╗
 ║       http://www.rpgmakervxace.net/         ║
 ╚═════════════════════════════════════════════╝
 pm me : Estriole.
  
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
    This script shift graphic to match the 'building'. you might want your
 building to trigger at the door instead of wall.
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 * Shift graphic by pixel
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.06.10           Initial Release
 
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 Compatible with most script.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 create comment in your event page:
 <graphic_Shift: [x,y]>
 change x -> how many pixel to the right
 change y -> how many pixel to the bottom
 use negative value for the opposing side. (up/left)
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 This is part of the EST - DECOR AND BUILD SERIES.

=end

class Sprite_Character < Sprite_Base
  alias est_set_character_bitmap set_character_bitmap  
  def set_character_bitmap
    est_set_character_bitmap
    a = check_graphic_shift(@character.note)[0]? check_graphic_shift(@character.note)[0] : 0 rescue 0
    b = check_graphic_shift(@character.note)[1]? check_graphic_shift(@character.note)[1] : 0 rescue 0
    self.ox = @cw / 2 - (a)
    self.oy = @ch - (b)
  end
  def check_graphic_shift(note)
    return [0,0] if !note[/<graphic_shift:(.*)>/im]
    a = note[/<graphic_shift:(.*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| eval("[#{x}]")}
    return noteargs = a[0]
  end
end