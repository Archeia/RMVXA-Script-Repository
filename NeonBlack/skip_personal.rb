class Scene_Menu < Scene_MenuBase
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:skill,     method(:do_command_skill))
    @command_window.set_handler(:equip,     method(:command_personal))
    @command_window.set_handler(:status,    method(:do_command_status))
    @command_window.set_handler(:formation, method(:command_formation))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end
  
  def do_command_skill
    SceneManager.call(Scene_Skill)
  end
  
  def do_command_status
    SceneManager.call(Scene_Status)
  end
end

class Window_Status < Window_Selectable
  def process_handling
    super
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:RIGHT)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:LEFT)
  end
end

class Window_SkillCommand < Window_Command
  def process_handling
    super
    return unless active
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:RIGHT)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:LEFT)
  end
end