#encoding:UTF-8
# Scene_Menu
#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================

class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    @gold_window = Window_Gold.new(0, 360)
    @status_window = Window_MenuStatus.new(160, 0)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @command_window.update
    @gold_window.update
    @status_window.update
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::item
    s2 = Vocab::skill
    s3 = Vocab::equip
    s4 = Vocab::status
    s5 = Vocab::save
    s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0          # If number of party members is 0
      @command_window.draw_item(0, false)     # Disable item
      @command_window.draw_item(1, false)     # Disable skill
      @command_window.draw_item(2, false)     # Disable equipment
      @command_window.draw_item(3, false)     # Disable status
    end
    if $game_system.save_disabled             # If save is forbidden
      @command_window.draw_item(4, false)     # Disable save
    end
  end
  #--------------------------------------------------------------------------
  # * Update Command Selection
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0      # Item
        $scene = Scene_Item.new
      when 1,2,3  # Skill, equipment, status
        start_actor_selection
      when 4      # Save
        $scene = Scene_File.new(true, false, false)
      when 5      # End Game
        $scene = Scene_End.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * End Actor Selection
  #--------------------------------------------------------------------------
  def end_actor_selection
    @command_window.active = true
    @status_window.active = false
    @status_window.index = -1
  end
  #--------------------------------------------------------------------------
  # * Update Actor Selection
  #--------------------------------------------------------------------------
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1  # skill
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # equipment
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # status
        $scene = Scene_Status.new(@status_window.index)
      end
    end
  end
end
