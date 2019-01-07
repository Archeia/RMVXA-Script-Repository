class Scene_Menu < Scene_MenuBase
  alias cp_form_personal command_personal
  def command_personal
    @status_window.form = false
    cp_form_personal
  end
  
  alias cp_form_formation command_formation
  def command_formation
    @status_window.form = true
    cp_form_formation
  end
end

class Window_MenuStatus < Window_Selectable
  attr_accessor :form
  
  def process_ok
    return Sound.play_buzzer if @form && @index == 0
    super
    $game_party.menu_actor = $game_party.members[index]
  end
end