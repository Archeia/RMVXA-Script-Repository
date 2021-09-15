#encoding:UTF-8
# Window_MenuActor
#==============================================================================
# ** Window_MenuActor
#------------------------------------------------------------------------------
#  This window is for selecting actors that will be the target of item or
# skill use.
#==============================================================================

class Window_MenuActor < Window_MenuStatus
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    $game_party.target_actor = $game_party.members[index] unless @cursor_all
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select($game_party.target_actor.index || 0)
  end
  #--------------------------------------------------------------------------
  # * Set Position of Cursor for Item
  #--------------------------------------------------------------------------
  def select_for_item(item)
    @cursor_fix = item.for_user?
    @cursor_all = item.for_all?
    if @cursor_fix
      select($game_party.menu_actor.index)
    elsif @cursor_all
      select(0)
    else
      select_last
    end
  end
end
