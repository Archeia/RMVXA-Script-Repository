#encoding:UTF-8
# Scene_Map
#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset
    create_all_windows
    @menu_calling = false
  end
  #--------------------------------------------------------------------------
  # * Execute Transition
  #    Performs a fade in when the screen has been blacked out, such as
  #    immediately after a battle or load.
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # * Get Transition Speed
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_spriteset
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update
    update_scene if scene_change_ok?
  end
  #--------------------------------------------------------------------------
  # * Determine if Scene Transition Is Possible
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # * Update Scene Transition
  #--------------------------------------------------------------------------
  def update_scene
    check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # * Update Frame (for Fade In)
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # * General-Purpose Fade Processing
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # * Fadein Screen
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # * Fadeout Screen
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # * Screen Fade In (White)
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # * Screen Fade Out (White)
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # * Create Sprite Set
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # * Free Sprite Set
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # * Create All Windows
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_location_window
  end
  #--------------------------------------------------------------------------
  # * Create Message Window
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * Create Scrolling Text Window
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # * Create Map Name Window
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # * Update Player Transfer
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # * Update Encounter
  #--------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # * Call Menu Screen
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand.init_command_position
  end
  #--------------------------------------------------------------------------
  # * Determine if Debug Call by F9 key
  #--------------------------------------------------------------------------
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && Input.press?(:F9)
  end
  #--------------------------------------------------------------------------
  # * Player Transfer Processing
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    post_transfer
  end
  #--------------------------------------------------------------------------
  # * Preprocessing for Transferring Player
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # * Post Processing for Transferring Player
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end
  #--------------------------------------------------------------------------
  # * Preprocessing for Battle Screen Transition
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # * Preprocessing for Title Screen Transition
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # * Execute Pre-Battle Transition
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # * Get Fade Out Speed
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # * Get Fade In Speed
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # * Get Fade Out Speed for Title Screen Transition
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end
end
