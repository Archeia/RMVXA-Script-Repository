#===============================================================
# ● [VX Snippet] ◦ Sprite Mover ◦ □
# * Move sprite in pixel to get right location~ *
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Thaiware RPG Maker Community
# ◦ Released on: 02/06/2008
# ◦ Version: 1.0
#==================================================================
# ** HOW TO USE **
#-----------------------------------------------------------------
# * In the event page that you want to move sprite, add comment:
#  MOVE x_plus, y_plus
# ** x_plus: how many pixel you want to move sprite horizontally
# (- number: move left | + number: move right)
# ** y_plus: how many pixel you want to move sprite vertically
# (- number: move up | + number: move down)

# * For example, add comment:
#  MOVE 0, -20
# ** to move sprite up 20 pixel~
#==================================================================


class Game_Event < Game_Character
  attr_accessor :spr_move
  alias wora_mover_gameve_setup setup_page
  
  def setup_page(*args)
    wora_mover_gameve_setup(*args)
    mover = comment?('MOVE', true)
    if !mover[0]
      @spr_move = nil
    else
      @spr_move = @list[mover[1]].parameters[0].clone
      @spr_move.sub!('MOVE','').gsub!(/\s+/){''}
      @spr_move = @spr_move.split(',')
      @spr_move.each_index {|i| @spr_move[i] = @spr_move[i].to_i }
    end
  end
  
  def comment?(comment, return_index = false )
    if !@list.nil?
      for i in 0...@list.size - 1
        next if @list[i].code != 108
        if @list[i].parameters[0].include?(comment)
          return [true, i] if return_index
          return true
        end
      end
    end
    return [false, nil] if return_index
    return false
  end
end

class Sprite_Character < Sprite_Base
  alias wora_mover_sprcha_upd update
  
  def update
    wora_mover_sprcha_upd
    if @character.is_a?(Game_Event) and !@character.spr_move.nil?
      self.x = @character.screen_x + @character.spr_move[0]
      self.y = @character.screen_y + @character.spr_move[1]
    end
  end
end