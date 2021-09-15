$simport.r 'iei/anti_lag', '0.1.0', 'IEI Antilag utility'

#-inject gen_module_header 'IEI::AntiLag'
module IEI
  module AntiLag

  end
end

#-inject gen_class_header 'Game::Character'
class Game::Character

  def on_screen?
    self.screen_x.between?(-32, Graphics.width + 32) and
     self.screen_y.between?(-32, Graphics.height + 32)
  end

end

#-inject gen_class_header 'Sprite::Character'
class Sprite::Character

  def update
    super
    if @character && @on_screen = @character.on_screen?
      update_bitmap
      update_src_rect
      update_position
      update_other
    elsif
      self.visible = false
    end
    update_balloon
    setup_new_effect
  end

end
