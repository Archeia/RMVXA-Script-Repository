#-skip:
# // Picture Follow Character
# // By IceDragon
# // Instructions:
# //   picture_follow(picture_id, character_id)
# //     int picture_id
# //     int character_id
# //      -1 - Player
# //       0 - Current event
# //       1 - every other event
#-end:
$simport.r 'iei/picture/follow', '1.0.0', 'IEI Picture Follow'
#-inject gen_class_header 'Game::Picture'
class Game::Picture

  attr_accessor :flw_char_id

  alias flw_update update
  def update
    flw_update
    update_follow if @flw_char_id
  end

  def update_follow
    chara = $game.map.interpreter.get_character(@flw_char_id)
    @x = chara.screen_x
    @y = chara.screen_y
  end

end

#-inject gen_class_header 'Game::Interpreter'
class Game::Interpreter

  def picture_follow(picture_id, character_id)
    character_id = @event_id if character_id == 0
    screen.pictures[picture_id].flw_char_id = character_id
  end

end
#-inject gen_script_footer
