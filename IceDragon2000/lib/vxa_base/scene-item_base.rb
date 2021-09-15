#encoding:UTF-8
# Scene_ItemBase
#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
#  This class performs common processing for the item screen and skill screen.
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_actor_window
  end
  #--------------------------------------------------------------------------
  # * Create Actor Window
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_MenuActor.new
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  #--------------------------------------------------------------------------
  # * Get Currently Selected Item
  #--------------------------------------------------------------------------
  def item
    @item_window.item
  end
  #--------------------------------------------------------------------------
  # * Get Item's User
  #--------------------------------------------------------------------------
  def user
    $game_party.movable_members.max_by {|member| member.pha }
  end
  #--------------------------------------------------------------------------
  # * Determine if Cursor Is in Left Column
  #--------------------------------------------------------------------------
  def cursor_left?
    @item_window.index % 2 == 0
  end
  #--------------------------------------------------------------------------
  # * Show Subwindow
  #--------------------------------------------------------------------------
  def show_sub_window(window)
    width_remain = Graphics.width - window.width
    window.x = cursor_left? ? width_remain : 0
    @viewport.rect.x = @viewport.ox = cursor_left? ? 0 : window.width
    @viewport.rect.width = width_remain
    window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Hide Subwindow
  #--------------------------------------------------------------------------
  def hide_sub_window(window)
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    window.hide.deactivate
    activate_item_window
  end
  #--------------------------------------------------------------------------
  # * Actor [OK]
  #--------------------------------------------------------------------------
  def on_actor_ok
    if item_usable?
      use_item
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * Actor [Cancel]
  #--------------------------------------------------------------------------
  def on_actor_cancel
    hide_sub_window(@actor_window)
  end
  #--------------------------------------------------------------------------
  # * Confirm Item
  #--------------------------------------------------------------------------
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window)
      @actor_window.select_for_item(item)
    else
      use_item
      activate_item_window
    end
  end
  #--------------------------------------------------------------------------
  # * Activate Item Window
  #--------------------------------------------------------------------------
  def activate_item_window
    @item_window.refresh
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # * Get Array of Actors Targeted by Item Use
  #--------------------------------------------------------------------------
  def item_target_actors
    if !item.for_friend?
      []
    elsif item.for_all?
      $game_party.members
    else
      [$game_party.members[@actor_window.index]]
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Item is Usable
  #--------------------------------------------------------------------------
  def item_usable?
    user.usable?(item) && item_effects_valid?
  end
  #--------------------------------------------------------------------------
  # * Determine if Item Is Effective
  #--------------------------------------------------------------------------
  def item_effects_valid?
    item_target_actors.any? do |target|
      target.item_test(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # * Use Item on Actor
  #--------------------------------------------------------------------------
  def use_item_to_actors
    item_target_actors.each do |target|
      item.repeats.times { target.item_apply(user, item) }
    end
  end
  #--------------------------------------------------------------------------
  # * Use Item
  #--------------------------------------------------------------------------
  def use_item
    play_se_for_item
    user.use_item(item)
    use_item_to_actors
    check_common_event
    check_gameover
    @actor_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Determine if Common Event Is Reserved
  #    Transition to the map screen if the event call is reserved.
  #--------------------------------------------------------------------------
  def check_common_event
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
end
