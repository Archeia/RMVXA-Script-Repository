#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                              *Title Scene*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                            Date: 8/11/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: This script overwrites the methods in Scene_Title:
#│                                  start
#│                          create_command_window 
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: none                          
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: Configure the settings in the configuration section to your 
#│                needs. Then you must create the images.
#│
#│                Command Images(New Game, Exit, Continue):
#│                  Create .png images of any size you wish with the names 
#│                  specified in the configuration section. Use the position
#│                  setting to adjust the image placement. Images must be in the
#│                  Graphics/System folder!
#│
#│                Random Images:
#│                  Create as many images as you want, using the same size .png.
#│                  Add the image names between the brackets in the 
#│                  configuration section by the variable "RAND_PICS". Images 
#│                  must be in the Graphics/System folder!
#│
#│                Scrolling Image:
#│                  Create a .png of the image you want to be scrolling in the
#│                  background. FOR BEST RESULTS the image should wrap both 
#│                  vertically and horizontally! Save the image in the 
#│                  Graphics/System folder, and configure the settings to fit
#│                  your image.
#│
#│                Random and Scrolling images can be disabled in the 
#│                configuration section, command images are needed for this
#│                script!
#│                
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaTitleScreen"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Configuration
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module TitleScreen
    
    #Command List Settings -----------------------------------------------------
    module Start
      SELECT   = "Start_S"   #File Name For Selected View Of New Game Button
      UNSELECT = "Start"   #File Name For Unselected View Of New Game Button
      POSITION = [325, 340]   #X And Y Coordinates For New Game Button
    end
    
    module Load
      SELECT   = "Load_S"   #File Name For Selected View Of Continue Button
      UNSELECT = "Load"   #File Name For Unselected View Of Continue Button
      POSITION = [400, 340]   #X And Y Coordinates For Continue Button   
    end
    
    module End
      SELECT   = "End_S"   #File Name For Selected View Of End Game Button
      UNSELECT = "End"   #File Name For Unselected View Of End Game Button
      POSITION = [475, 340]   #X And Y Coordinates For End Game Button
    end
    #End Command List Settings -------------------------------------------------
    ############################################################################
    ############################################################################
    #Control Settings ----------------------------------------------------------
    ENABLE_UPDOWN    = false   #True Enables Up And Down Movement For Buttons
    
    ENABLE_LEFTRIGHT = true  #True Enables Left And Right Movement For Buttons
    #End Control Settings ------------------------------------------------------
    ############################################################################
    ############################################################################
    #Scrolling Background Settings ---------------------------------------------
    SCROLL_BG     = true   #Set To True To Enable A Scrolling Background Image
    
    SCROLL_IMAGE  = "Scroll"   #Image Name For The Scrolling Background
    
    SCROLL_Y      = 64   #Starting Y coordinate
    
    SCROLL_SPEED  = 1   #Speed The Image Will Scroll At, Higher Is Faster
    
    #End Scrolling Background Settings -----------------------------------------
    ############################################################################
    ############################################################################
    #Random Picture Drawing Settings -------------------------------------------
    RAND_PICS_ON    = true   #True Enables Random Pictures, False Disables It
    
    RAND_PICS       = ["pic1", "pic2", "pic3"]   #Picture List To Draw From

    RAND_PIC_X      = 335   #The X Position Of The Pictures
    
    RAND_PIC_Y      = 71   #The Y Position Of The Pictures
    
    RAND_PIC_WIDTH  = 210   #The Width Of The Pictures
    
    RAND_PIC_HEIGHT = 282   #The Height Of The Pictures
    #End Random Picture Drawing Settings ---------------------------------------
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_ERandPic
#└──────────────────────────────────────────────────────────────────────────────
class Window_ERandPic < Window_Base
  
  #NEW - INITIALIZE
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @randpics = Euphoria::TitleScreen::RAND_PICS
    create_rand_picture
  end
  
  #NEW - CREATE_RAND_PICTURE
  def create_rand_picture
    if Euphoria::TitleScreen::RAND_PICS_ON == true
      pic = rand(pic_number)
      bitmap = Cache.system(@randpics[pic])
      rect = Rect.new(0, 0, 544, 416)
      enabled = true
      contents.blt(0, 0, bitmap, rect, enabled ? 255 : translucent_alpha)
      bitmap.dispose
    end
  end
  
  #NEW - PIC_NUMBER
  def pic_number
    return Euphoria::TitleScreen::RAND_PICS.size
  end
  
  #NEW - STANDARD_PADDING
  def standard_padding
    return 0
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_EScrollBG
#└──────────────────────────────────────────────────────────────────────────────
class Window_EScrollBG < Window_Base
  
  #NEW - INITIALIZE
  def initialize(x, y, width, height)
    super(x, y, width, height)
    create_bg_image
  end
  
  #NEW - CREATE_BG_IMAGE
  def create_bg_image
    @scrollbg = Plane.new
    @scrollbg.bitmap = Cache.system(Euphoria::TitleScreen::SCROLL_IMAGE)
  end
    
  #NEW - UPDATE
  def update
    super
    @scrollbg.ox += Euphoria::TitleScreen::SCROLL_SPEED
  end
    
  #NEW - DISPOSE
  def dispose
    super
    @scrollbg.bitmap.dispose
    @scrollbg.dispose
  end
    
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ ETitleCommands
#└──────────────────────────────────────────────────────────────────────────────
class ETitleCommands
  attr_reader :com_list
  
  include Euphoria::TitleScreen
  
  #NEW - INITIALIZE
  def initialize(viewport)
    @index = 0
    @viewport = viewport
    @active = true
    create_com_sprites
    update_command
  end  
  
  #NEW - CREATE_COMMAND_SPRITES
  def create_com_sprites
    @com_list = []
    @com_list.push(Sprite_ETitleCom.new(Start, @viewport))
    @com_list.push(Sprite_ETitleCom.new(Load,  @viewport))
    @com_list.push(Sprite_ETitleCom.new(End,   @viewport))
  end
  
  #NEW - UPDATE_COMMAND
  def update_command
    @com_list.each {|cmd| cmd.unselect_pic}
    @com_list[@index].select_pic
  end
    
  #NEW - UPDATE
  def update
    return unless @active
    update_index
    update_scene if Input.trigger?(:C) 
  end
  
  #NEW - UPDATE_INDEX
  def update_index
    if ENABLE_LEFTRIGHT == true
      if Input.repeat?(:LEFT)
        Sound.play_cursor
        @index -= 1
        wrap_index
        update_command
      elsif Input.repeat?(:RIGHT)
        Sound.play_cursor
        @index += 1
        wrap_index
        update_command
      end
    end
    if ENABLE_UPDOWN == true
      if Input.repeat?(:UP)
        Sound.play_cursor
        @index -= 1
        wrap_index
        update_command
      elsif Input.repeat?(:DOWN)
        Sound.play_cursor
        @index += 1
        wrap_index
        update_command
      end
    end
  end
    
  #NEW - WRAP_INDEX
  def wrap_index
    @index = 0 if @index > max_index
    @index = max_index if @index < 0
  end
  
  #NEW - MAX_INDEX
  def max_index
    return 2
  end
  
  #NEW - UPDATE_SCENE
  def update_scene
    @active = @com_list[@index].call
  end
  
  #NEW - DISPOSE
  def dispose
    @com_list.each {|cmd| cmd.dispose}
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Sprite_ETitleCom
#└──────────────────────────────────────────────────────────────────────────────
class Sprite_ETitleCom < Sprite
  
  #NEW - INITIALIZE
  def initialize(mod, viewport)
    super(viewport)
    @mod = mod
    self.z = 200    
    update_pos
  end
  
  #NEW - SET_HANDLER
  def set_handler(method, enable = true)
    @handler = method
    @enable = enable
  end
  
  #NEW - UNSELECT_PIC
  def unselect_pic
    self.bitmap = Cache.system(@mod::UNSELECT)
  end
  
  #NEW - SELECT_PIC
  def select_pic
    self.bitmap = Cache.system(@mod::SELECT)
  end
  
  #NEW - UPDATE_POS
  def update_pos
    self.x = @mod::POSITION[0]
    self.y = @mod::POSITION[1]
  end
  
  #NEW - CALL
  def call
    if @enable
      Sound.play_ok
      @handler.call
      return false
    else
      Sound.play_buzzer
      return true
    end
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Scene_Title
#└──────────────────────────────────────────────────────────────────────────────
class Scene_Title < Scene_Base
  
  #OVERWRITE - START
  def start
    super
    SceneManager.clear
    Graphics.freeze
    create_background
    create_foreground
    create_command_window
    play_title_music
    create_randpic_window
    create_scroll_background
  end
  
  #NEW - CREATE_SCROLL_BACKGROUND
  def create_scroll_background
    if Euphoria::TitleScreen::SCROLL_BG == true
      @scroll_window = Window_EScrollBG.new(0, Euphoria::TitleScreen::SCROLL_Y,
          544, 416)
      @scroll_window.viewport = @viewport
      @scroll_window.opacity = 0
      @scroll_window.z = 50
    end
  end
    
  
  #NEW - CREATE_RANDPIC_WINDOW
  def create_randpic_window
    @randpic_window = Window_ERandPic.new(Euphoria::TitleScreen::RAND_PIC_X,
       Euphoria::TitleScreen::RAND_PIC_Y, Euphoria::TitleScreen::RAND_PIC_WIDTH, 
       Euphoria::TitleScreen::RAND_PIC_HEIGHT)
    @randpic_window.viewport = @viewport
    @randpic_window.opacity = 0
    @randpic_window.z = 75
  end
  
  #OVERWRITE - CREATE_COMMAND_WINDOW
  def create_command_window
    @sprites = ETitleCommands.new(@viewport)
    @sprites.com_list[0].set_handler(method(:command_new_game))
    @sprites.com_list[1].set_handler(method(:command_continue), can_load?)
    @sprites.com_list[2].set_handler(method(:command_shutdown))
  end

  #NEW - CAN_LOAD?
  def can_load?
    DataManager.save_file_exists?
  end
  
  #ALIAS - UPDATE
  alias euphoria_title_scenetitle_update_21 update
  def update
    euphoria_title_scenetitle_update_21
    @sprites.update
  end
  
  #ALIAS - TERMINATE
  alias euphoria_title_scenetitle_terminate_21 terminate
  def terminate
    euphoria_title_scenetitle_terminate_21
    @sprites.dispose
  end
  
  #OVERWRITE - CLOSE_COMMAND_WINDOW
  def close_command_window
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────