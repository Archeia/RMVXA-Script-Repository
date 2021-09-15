#encoding:UTF-8
# SceneManager
#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # * Module Instance Variables
  #--------------------------------------------------------------------------
  @scene = nil                            # current scene object
  @stack = []                             # stack for hierarchical transitions
  @background_bitmap = nil                # background bitmap
  #--------------------------------------------------------------------------
  # * Execute
  #--------------------------------------------------------------------------
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    @scene = first_scene_class.new
    @scene.main while @scene
  end
  #--------------------------------------------------------------------------
  # * Get First Scene Class
  #--------------------------------------------------------------------------
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Title
  end
  #--------------------------------------------------------------------------
  # * Use MIDI?
  #--------------------------------------------------------------------------
  def self.use_midi?
    $data_system.opt_use_midi
  end
  #--------------------------------------------------------------------------
  # * Get Current Scene
  #--------------------------------------------------------------------------
  def self.scene
    @scene
  end
  #--------------------------------------------------------------------------
  # * Determine Current Scene Class
  #--------------------------------------------------------------------------
  def self.scene_is?(scene_class)
    @scene.instance_of?(scene_class)
  end
  #--------------------------------------------------------------------------
  # * Direct Transition
  #--------------------------------------------------------------------------
  def self.goto(scene_class)
    @scene = scene_class.new
  end
  #--------------------------------------------------------------------------
  # * Call
  #--------------------------------------------------------------------------
  def self.call(scene_class)
    @stack.push(@scene)
    @scene = scene_class.new
  end
  #--------------------------------------------------------------------------
  # * Return to Caller
  #--------------------------------------------------------------------------
  def self.return
    @scene = @stack.pop
  end
  #--------------------------------------------------------------------------
  # * Clear Call Stack
  #--------------------------------------------------------------------------
  def self.clear
    @stack.clear
  end
  #--------------------------------------------------------------------------
  # * Exit Game
  #--------------------------------------------------------------------------
  def self.exit
    @scene = nil
  end
  #--------------------------------------------------------------------------
  # * Create Snapshot to Use as Background
  #--------------------------------------------------------------------------
  def self.snapshot_for_background
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
    @background_bitmap.blur
  end
  #--------------------------------------------------------------------------
  # * Get Background Bitmap
  #--------------------------------------------------------------------------
  def self.background_bitmap
    @background_bitmap
  end
end
