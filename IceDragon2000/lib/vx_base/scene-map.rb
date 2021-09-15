#encoding:UTF-8
# Scene_Map
#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    $game_map.refresh
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # * Execute Transition
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0       # After battle or loading, etc.
      fadein(30)
    else                              # Restoration from menu, etc.
      Graphics.transition(15)
    end
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    if $scene.is_a?(Scene_Battle)     # If switching to battle screen
      @spriteset.dispose_characters   # Hide characters for background creation
    end
    snapshot_for_background
    @spriteset.dispose
    @message_window.dispose
    if $scene.is_a?(Scene_Battle)     # If switching to battle screen
      perform_battle_transition       # Execute pre-battle transition
    end
  end
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update                   # Update game screen
    Input.update                      # Update input information
    $game_map.update                  # Update map
    @spriteset.update                 # Update sprite set
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.interpreter.update      # Update interpreter
    $game_map.update                  # Update map
    $game_player.update               # Update player
    $game_system.update               # Update timer
    @spriteset.update                 # Update sprite set
    @message_window.update            # Update message window
    unless $game_message.visible      # Unless displaying a message
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
  end
  #--------------------------------------------------------------------------
  # * Fade In Screen
  #     duration : time
  #    If you use Graphics.fadeout directly on the map screen, a number of
  #    problems can occur, such as weather effects and parallax  scrolling
  #    being stopped. So instead, perform a dynamic fade-in.
  #--------------------------------------------------------------------------
  def fadein(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 * i / duration
      update_basic
    end
    Graphics.brightness = 255
  end
  #--------------------------------------------------------------------------
  # * Fade Out Screen
  #     duration : time
  #    As with the fadein above, Graphics.fadein is not used directly.
  #--------------------------------------------------------------------------
  def fadeout(duration)
    Graphics.transition(0)
    for i in 0..duration-1
      Graphics.brightness = 255 - 255 * i / duration
      update_basic
    end
    Graphics.brightness = 0
  end
  #--------------------------------------------------------------------------
  # * Player Transfer  Processing
  #--------------------------------------------------------------------------
  def update_transfer_player
    return unless $game_player.transfer?
    fade = (Graphics.brightness > 0)
    fadeout(30) if fade
    @spriteset.dispose              # Dispose of sprite set
    $game_player.perform_transfer   # Execute player transfer
    $game_map.autoplay              # Automatically switch BGM and BGS
    $game_map.update
    Graphics.wait(15)
    @spriteset = Spriteset_Map.new  # Recreate sprite set
    fadein(30) if fade
    Input.update
  end
  #--------------------------------------------------------------------------
  # * Encounter Processing
  #--------------------------------------------------------------------------
  def update_encounter
    return if $game_player.encounter_count > 0        # Check steps
    return if $game_map.interpreter.running?          # Event being executed?
    return if $game_system.encounter_disabled         # Encounters forbidden?
    troop_id = $game_player.make_encounter_troop_id   # Determine troop
    return if $data_troops[troop_id] == nil           # Troop is invalid?
    $game_troop.setup(troop_id)
    $game_troop.can_escape = true
    $game_temp.battle_proc = nil
    $game_temp.next_scene = "battle"
    preemptive_or_surprise
  end
  #--------------------------------------------------------------------------
  # * Determine Preemptive Strike and Surprise Attack Chance
  #--------------------------------------------------------------------------
  def preemptive_or_surprise
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    if actors_agi >= enemies_agi
      percent_preemptive = 5
      percent_surprise = 3
    else
      percent_preemptive = 3
      percent_surprise = 5
    end
    if rand(100) < percent_preemptive
      $game_troop.preemptive = true
    elsif rand(100) < percent_surprise
      $game_troop.surprise = true
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button
  #--------------------------------------------------------------------------
  def update_call_menu
    if Input.trigger?(Input::B)
      return if $game_map.interpreter.running?        # Event being executed?
      return if $game_system.menu_disabled            # Menu forbidden?
      $game_temp.menu_beep = true                     # Set SE play flag
      $game_temp.next_scene = "menu"
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Bug Call Due to F9 key
  #--------------------------------------------------------------------------
  def update_call_debug
    if $TEST and Input.press?(Input::F9)    # F9 key during test play
      $game_temp.next_scene = "debug"
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Screen Switch
  #--------------------------------------------------------------------------
  def update_scene_change
    return if $game_player.moving?    # Is player moving?
    case $game_temp.next_scene
    when "battle"
      call_battle
    when "shop"
      call_shop
    when "name"
      call_name
    when "menu"
      call_menu
    when "save"
      call_save
    when "debug"
      call_debug
    when "gameover"
      call_gameover
    when "title"
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Switch to Battle Screen
  #--------------------------------------------------------------------------
  def call_battle
    @spriteset.update
    Graphics.update
    $game_player.make_encounter_count
    $game_player.straighten
    $game_temp.map_bgm = RPG::BGM.last
    $game_temp.map_bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    Sound.play_battle_start
    $game_system.battle_bgm.play
    $game_temp.next_scene = nil
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Shop Screen
  #--------------------------------------------------------------------------
  def call_shop
    $game_temp.next_scene = nil
    $scene = Scene_Shop.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Name Input Screen
  #--------------------------------------------------------------------------
  def call_name
    $game_temp.next_scene = nil
    $scene = Scene_Name.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Menu Screen
  #--------------------------------------------------------------------------
  def call_menu
    if $game_temp.menu_beep
      Sound.play_decision
      $game_temp.menu_beep = false
    end
    $game_temp.next_scene = nil
    $scene = Scene_Menu.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Save Screen
  #--------------------------------------------------------------------------
  def call_save
    $game_temp.next_scene = nil
    $scene = Scene_File.new(true, false, true)
  end
  #--------------------------------------------------------------------------
  # * Switch to Debug Screen
  #--------------------------------------------------------------------------
  def call_debug
    Sound.play_decision
    $game_temp.next_scene = nil
    $scene = Scene_Debug.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Game Over Screen
  #--------------------------------------------------------------------------
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
  end
  #--------------------------------------------------------------------------
  # * Switch to Title Screen
  #--------------------------------------------------------------------------
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    fadeout(60)
  end
  #--------------------------------------------------------------------------
  # * Execute Pre-battle Transition
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(80, "Graphics/System/BattleStart", 80)
    Graphics.freeze
  end
end
