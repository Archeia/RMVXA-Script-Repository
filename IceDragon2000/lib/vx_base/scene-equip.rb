#encoding:UTF-8
# Scene_Equip
#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs the equipment screen processing.
#==============================================================================

class Scene_Equip < Scene_Base
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  EQUIP_TYPE_MAX = 5                      # Number of equip region
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_index : actor index
  #     equip_index : equipment index
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @help_window = Window_Help.new
    create_item_windows
    @equip_window = Window_Equip.new(208, 56, @actor)
    @equip_window.help_window = @help_window
    @equip_window.index = @equip_index
    @status_window = Window_EquipStatus.new(0, 56, @actor)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @equip_window.dispose
    @status_window.dispose
    dispose_item_windows
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(2)
  end
  #--------------------------------------------------------------------------
  # * Switch to Next Actor Screen
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #--------------------------------------------------------------------------
  # * Switch to Previous Actor Screen
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Equip.new(@actor_index, @equip_window.index)
  end
  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    update_equip_window
    update_status_window
    update_item_windows
    if @equip_window.active
      update_equip_selection
    elsif @item_window.active
      update_item_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_item_windows
    @item_windows = []
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i] = Window_EquipItem.new(0, 208, 544, 208, @actor, i)
      @item_windows[i].help_window = @help_window
      @item_windows[i].visible = (@equip_index == i)
      @item_windows[i].y = 208
      @item_windows[i].height = 208
      @item_windows[i].active = false
      @item_windows[i].index = -1
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Item Window
  #--------------------------------------------------------------------------
  def dispose_item_windows
    for window in @item_windows
      window.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * Update Item Window
  #--------------------------------------------------------------------------
  def update_item_windows
    for i in 0...EQUIP_TYPE_MAX
      @item_windows[i].visible = (@equip_window.index == i)
      @item_windows[i].update
    end
    @item_window = @item_windows[@equip_window.index]
  end
  #--------------------------------------------------------------------------
  # * Update Equipment Window
  #--------------------------------------------------------------------------
  def update_equip_window
    @equip_window.update
  end
  #--------------------------------------------------------------------------
  # * Update Status Window
  #--------------------------------------------------------------------------
  def update_status_window
    if @equip_window.active
      @status_window.set_new_parameters(nil, nil, nil, nil)
    elsif @item_window.active
      temp_actor = @actor.clone
      temp_actor.change_equip(@equip_window.index, @item_window.item, true)
      new_atk = temp_actor.atk
      new_def = temp_actor.def
      new_spi = temp_actor.spi
      new_agi = temp_actor.agi
      @status_window.set_new_parameters(new_atk, new_def, new_spi, new_agi)
    end
    @status_window.update
  end
  #--------------------------------------------------------------------------
  # * Update Equip Region Selection
  #--------------------------------------------------------------------------
  def update_equip_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      if @actor.fix_equipment
        Sound.play_buzzer
      else
        Sound.play_decision
        @equip_window.active = false
        @item_window.active = true
        @item_window.index = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
    elsif Input.trigger?(Input::C)
      Sound.play_equip
      @actor.change_equip(@equip_window.index, @item_window.item)
      @equip_window.active = true
      @item_window.active = false
      @item_window.index = -1
      @equip_window.refresh
      for item_window in @item_windows
        item_window.refresh
      end
    end
  end
end
