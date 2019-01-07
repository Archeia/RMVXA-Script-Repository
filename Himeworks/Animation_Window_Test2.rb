class Window_MenuCommand < Window_Command

  def opening_animation
    @new_x = self.x
    self.x = self.x - self.width
  end
  
  def closing_animation
    @slide_speed = 20
    @new_x = self.x + Graphics.width
  end
end

class Window_Gold < Window_Base
  
  def opening_animation
    @new_y = Graphics.height - self.height
    self.y = Graphics.height
  end
  
  def closing_animation
    @slide_speed = 15
    @new_y = self.y - Graphics.height
  end
end

class Window_MainMenuStatus < Window_MenuStatus
  def opening_animation
    @new_x = self.x
    @slide_speed = 30
    self.x = self.x + self.width
  end
  
  def closing_animation
    @slide_speed = 15
    @new_x = self.x - Graphics.width
  end
end

class Scene_Menu < Scene_MenuBase
  
  # Need to use its own window
  def create_status_window
    @status_window = Window_MainMenuStatus.new(@command_window.width, 0)
  end

  #why would you re-position it after you create it?
  def create_gold_window
    @gold_window = Window_Gold.new
  end
end