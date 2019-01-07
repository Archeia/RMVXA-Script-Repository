=begin
#===============================================================================
 Title: Gameover Images
 Author: Hime
 Date: Mar 30, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 30, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to specify custom game over images using
 script calls.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Place all custom gameover images in your project's Graphics/System folder.
 To choose a game over image, make a script call
 
   gameover_image(filename)
   
 Where the `filename` is one of the images in your System folder.
 If you want to use a different image, you must make another script call.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_GameoverImages"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Gameover_Images
    
    Default_Name = "GameOver.png"
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================

class Game_System
  attr_accessor :gameover_name
  
  alias :th_gameover_images_initialize :initialize
  def initialize
    th_gameover_images_initialize
    @gameover_name = TH::Gameover_Images::Default_Name
  end
end

class Game_Interpreter
  
  def gameover_image(name)
    $game_system.gameover_name = name
  end
end

class Scene_Gameover < Scene_Base
  alias :th_gameover_images_create_background :create_background
  def create_background
    th_gameover_images_create_background
    
    # dispose existing bitmap, then assign a new one
    @sprite.bitmap.dispose
    @sprite.bitmap = Cache.system($game_system.gameover_name)
  end
end