#encoding:UTF-8
# Scene_Item
#==============================================================================
# ** Scene_Item
#------------------------------------------------------------------------------
#  This class performs the item screen processing.
#==============================================================================

class Scene_Item < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    @item_window = Window_Item.new(0, 56, 544, 360)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.active = false
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @viewport.dispose
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Return to Original Screen
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(0)
  end
  #--------------------------------------------------------------------------
  # * Update Frame
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    @item_window.update
    @target_window.update
    if @item_window.active
      update_item_selection
    elsif @target_window.active
      update_target_selection
    end
  end
  #--------------------------------------------------------------------------
  # * Update Item Selection
  #--------------------------------------------------------------------------
  def update_item_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Confirm Item
  #--------------------------------------------------------------------------
  def determine_item
    if @item.for_friend?
      show_target_window(@item_window.index % 2 == 0)
      if @item.for_all?
        @target_window.index = 99
      else
        if $game_party.last_target_index < @target_window.item_max
          @target_window.index = $game_party.last_target_index
        else
          @target_window.index = 0
        end
      end
    else
      use_item_nontarget
    end
  end
  #--------------------------------------------------------------------------
  # * Update Target Selection
  #--------------------------------------------------------------------------
  def update_target_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if $game_party.item_number(@item) == 0    # If item is used up
        @item_window.refresh                    # Recreate the window contents
      end
      hide_target_window
    elsif Input.trigger?(Input::C)
      if not $game_party.item_can_use?(@item)
        Sound.play_buzzer
      else
        determine_target
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Confirm Target
  #    If there is no effect (such as using a potion on an incapacitated
  #    character), play a buzzer SE.
  #--------------------------------------------------------------------------
  def determine_target
    used = false
    if @item.for_all?
      for target in $game_party.members
        target.item_effect(target, @item)
        used = true unless target.skipped
      end
    else
      $game_party.last_target_index = @target_window.index
      target = $game_party.members[@target_window.index]
      target.item_effect(target, @item)
      used = true unless target.skipped
    end
    if used
      use_item_nontarget
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Show Target Window
  #     right : Right justification flag (if false, left justification)
  #--------------------------------------------------------------------------
  def show_target_window(right)
    @item_window.active = false
    width_remain = 544 - @target_window.width
    @target_window.x = right ? width_remain : 0
    @target_window.visible = true
    @target_window.active = true
    if right
      @viewport.rect.set(0, 0, width_remain, 416)
      @viewport.ox = 0
    else
      @viewport.rect.set(@target_window.width, 0, width_remain, 416)
      @viewport.ox = @target_window.width
    end
  end
  #--------------------------------------------------------------------------
  # * Hide Target Window
  #--------------------------------------------------------------------------
  def hide_target_window
    @item_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, 544, 416)
    @viewport.ox = 0
  end
  #--------------------------------------------------------------------------
  # * Use Item (apply effects to non-ally targets)
  #--------------------------------------------------------------------------
  def use_item_nontarget
    Sound.play_use_item
    $game_party.consume_item(@item)
    @item_window.draw_item(@item_window.index)
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @item.common_event_id > 0
      $game_temp.common_event_id = @item.common_event_id
      $scene = Scene_Map.new
    end
  end
end
