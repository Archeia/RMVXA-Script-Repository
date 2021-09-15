$simport.r 'iek/riviera/scene/menu', '1.0.0', 'Riviera styled Main Menu' do |h|
  h.depend 'iek/riviera/scene/menu_base', '>= 1.0.0'
end

class Scene_Menu
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler :item,      method(:command_item)
    @command_window.set_handler :skill,     method(:command_personal)
    @command_window.set_handler :equip,     method(:command_personal)
    @command_window.set_handler :status,    method(:command_personal)
    @command_window.set_handler :formation, method(:command_formation)
    @command_window.set_handler :save,      method(:command_save)
    @command_window.set_handler :game_end,  method(:command_game_end)
    @command_window.set_handler :cancel,    method(:return_scene)

    @command_window.x = @content_rect.x
    @command_window.y = @content_rect.y
  end

  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = @content_rect.y2 - @gold_window.height
  end

  def create_status_window
    @status_window = Window_MenuStatus.new @command_window.x2, @content_rect.y
  end

  def header_string
    'Menu'
  end
end
