require 'iei/arts_system/windows/arts_command'
require 'iei/arts_system/windows/arts_list'
require 'iei/arts_system/windows/arts_status'

class Scene::Arts < Scene::MenuUnitBase
  def start
    super
    create_all_windows
  end

  def create_all_windows
    super
    create_command_window
    create_status_window
    create_equip_window
    create_item_window
  end

  def create_command_window
    @command_window = Window::ArtsCommand.new(@canvas.x, @canvas.y)
    @command_window.help_window = @help_window
    @command_window.set_unit(@unit)
    @command_window.set_handler :equip   , method(:command_equip)
    @command_window.set_handler :unequip , method(:command_unequip)
    @command_window.set_handler :clear   , method(:command_clear)
    @command_window.set_handler :list    , method(:command_list)
    @command_window.set_handler :cancel  , method(:return_scene)
    @command_window.set_handler :pagedown, method(:next_unit)
    @command_window.set_handler :pageup  , method(:prev_unit)

    window_manager.add(@command_window)
  end

  def create_status_window
    @status_window = Window::ArtsStatus.new(@command_window.x2, @canvas.y,
                                            @help_window.width-@command_window.width)
    @status_window.set_unit(@unit)

    window_manager.add(@status_window)
  end

  def create_equip_window
    @equip_window = Window::ArtsList.new(
      @help_window.x, @status_window.y2, @canvas.width/2)
    @equip_window.set_unit(@unit)
    @equip_window.help_window = @help_window

    window_manager.add(@equip_window)
  end

  def create_item_window
    @item_window = Window::ArtsList.new(
      @equip_window.x2, @status_window.y2, @equip_window.width)
    @item_window.set_unit($game.party)
    @item_window.help_window = @help_window
    @item_window.height = @canvas.y2-@item_window.y

    window_manager.add(@item_window)
  end

  def command_equip
    @item_window.set_handler :ok, method(:equip_current_item)
    @item_window.set_handler :cancel, method(:end_item_selection)
    #@item_window.set_handler :pageup, method(:pred_element)
    #@item_window.set_handler :pagedown, method(:succ_element)
    @equip_window.set_handler :ok,method(:start_item_selection)
    @equip_window.set_handler :cancel,method(:end_equip_selection)
    @equip_window.activate
  end

  def command_unequip
    @equip_window.set_handler :ok,method(:unequip_current_item)
    @equip_window.set_handler :cancel,method(:end_equip_selection)
    @equip_window.activate
  end

  def command_clear
    @unit.entity.unequip_arts
    @help_window.clear
    @equip_window.refresh
    @item_window.refresh
    @status_window.refresh
    @command_window.refresh
    @command_window.activate
  end

  def command_list
    @item_window.set_handler(:ok, method(:show_item_full_info))
    @item_window.set_handler(:cancel, method(:end_item_list))
    @item_window.activate

    # eye candy
    @item_window.start_close
    @equip_window.start_close
    wait_for_windows(@item_window)
    @item_window.x = @canvas.x
    @item_window.width = @canvas.width
    @item_window.refresh
    @item_window.start_open
  end

  def start_item_selection
    @item_window.activate
  end

  def end_item_selection
    @equip_window.activate
  end

  def equip_current_item
    @equip_window.current_item = @item_window.item
    @equip_window.activate
    @status_window.refresh
  end

  def unequip_current_item
    @equip_window.current_item = nil
    @equip_window.activate
    @status_window.refresh
  end

  def end_equip_selection
    @command_window.activate
  end

  def show_item_full_info
  end

  def end_item_list
    @command_window.activate
    @item_window.start_close
    wait_for_windows(@item_window)
    @item_window.x     = @equip_window.x2
    @item_window.width = @canvas.width/2
    @item_window.refresh
    @equip_window.start_open
    @item_window.start_open
  end

  def update
    super
  end

  def on_unit_change
    @command_window.set_unit(@unit)
    @status_window.set_unit(@unit)
    @equip_window.set_unit(@unit)
    @command_window.activate
  end
end
