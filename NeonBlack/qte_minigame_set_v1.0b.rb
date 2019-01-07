##-----------------------------------------------------------------------------
## QTE Minigames v1.0b
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0b - 8.22.2013
##  Small updates to options
## v1.0 - 8.18.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["QTE_Minigames"] = 1.0                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script adds 4 minigames that can be played by typing out a simple
## script call.  Each of the 4 script calls has 3 options that can be changed
## to make the game harder or easier.
##
##------
## MashQTE.play  -or-  MashQTE.play(presses, time, button)
##  - Play a button mashing minigame.  This minigame requires the player to
##    press a single button as fast as they can to satisfy a number of button
##    presses before time runs out.  The 3 options are as follows:
##
##    presses - The number of times the button must be pressed before the
##              minigame is won.
##    time - The amount of time, in frames, that the player has to finish the
##           minigame.  60 frames = 1 second.
##    button - The button the player must press for the minigame.  Examples of
##             valid buttons include :C, :X, :LEFT, etc.
##
## Examples:
##    MashQTE.play(15, 120, :A)
##    MashQTE.play(50)
##
##------
## TriggerQTE.play  -or-  TriggerQTE.play(match, time)
##  - Play a button matching minigame.  The player must match all buttons as
##    quickly as possible to win the minigame.  There are two options as
##    follows:
##
##    match - The number of buttons the player must match.  The pattern is
##            randomly generated.
##    time - The amount of time, in frames, the player has to match the
##           pattern.  60 frames = 1 second.
##
## Examples:
##    TriggerQTE.play(6, 180)
##    TriggerQTE.play(4)
##
##------
## MatchQTE.play  -or-  MatchQTE.play(match, time)
##  - Play a minigame where the player must press each button as the indicator
##    hovers over it.  The player is given a short period of time before the
##    game starts and then must press the pattern as the indicator hovers over
##    each part of the pattern.  This is similar to the Trigger minigame. 
##    There are 2 options as follows:
##
##    match - The number of buttons the player must match.
##    time - The time in frames to complete the minigame.
##
## Examples:
##    MatchQTE.play(8, 330)
##    MatchQTE.play(5)
##
##------
## TargetQTE.play  -or-  TargetQTE.play(zoom, time, speed)
##  - Play a minigame where the player must press a button when the indicator
##    is in a certain target region.  The indicator will scroll back and forth
##    until time runs out or the player wins the minigame.  There are 3 options
##    as follows:
##
##    zoom - The zoom of the bar.  As a general rule of thumb the minimum value
##           for this should be 1.0.  Making this value higher will cause the
##           target area to be larger.
##    time - The time in frames to win the minigame.
##    speed - The amount of pixels the indicator moves every frame.  Higher
##            numbers move faster and as such are harder to win.
##
## Examples:
##    TargetQTE.play(1.5, 90, 7)
##    TargetQTE.play(1.0, 150)
##----------------------------------------------------------------------------##
                                                                              ##
module CPMinigame ## Do not touch this line                                   ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
#     Common Settings:
#
# Choose if you would like the background blurred and if you would like the
# background dimmed.
BlurBack = true
DimBack  = true

# The color to dim the background to if a dimming background is enabled.
# [Red, Green, Blue, Opacity]
DimSetting = [16, 16, 16, 128]

# This is the switch used to indicate if the minigame was won or lost.  The
# switch will turn on when the game is won and off when the game is lost.
GameSwitch = 41

# This is the variable that stores the number of correct button presses made
# during a minigame.  This can be used to reward the player for partial
# completion of the minigame or anything else you can think to use it for.
GameVariable = 41

# This is the background color for all bars used in the minigames.  Remember
# that colors use [Red, Green, Blue, Opacity].
BarBackColor = [0, 0, 0, 64]

#------
#     Mash Button Minigame Settings:
#
# This is the background image for the minigame.
ButtonImages = "MiniGameButtons"

# These are the default presses, time, and button for the minigame.  See the
# instructions section of this minigame for further explaination.
DefMPresses = 20
DefMTime    = 240
DefMButton  = :C

# These are the graphics used by the minigame.  The first is the background
# image and the second is a foreground image.  They are layered on top of each
# other.
MBackImage = "MenuBackItem"
MashImage  = "MiniGameMashText"

# These settings are for the button that appears to the left of the minigame
# HUD.  Offset is the X offset in pixels of the tap icon over the button icon.
MashOffset = 10
ButtonZoom = 2.0

# This is the color of the bar that fills up as the player taps the button.
# [Red, Green, Blue, Opacity]
MashBarColor = [128, 197, 118]

# These are the success and failure sound effects for the minigame.
# ["Filename", Volume, Pitch]
MashSuccess  = ["Chime2", 80, 115]
MashFailure  = ["Stare", 80, 95]

#------
#     Trigger Minigame Settings:
#
# These are the default settings of the minigame.  See instructions above for
# further explaination.
DefTMatch   = 5
DefTTime    = 150

# These are the buttons that can be mixed into the pattern.  Allowed buttons
# include :A, :B, :C, :X, :Y, :Z, :LEFT, :RIGHT, :UP, and :DOWN.
DefTButtons = [:LEFT, :RIGHT, :UP, :DOWN]

# This is the image used for the background.  It is stretched to fit the time
# and buttons.
TBackImage = "MenuBackItem"

# This is the color of the bar for the time of the minigame.
# [Red, Green, Blue, Opacity]
TriggerBarColor   = [245, 198, 75]

# These are the sound effects used by the minigame.  ButtonGood and ButtonBad
# are used to indicate if the player has pressed a matching button or not.
# ["Filename", Volume, Pitch]
TriggerButtonGood = ["Switch1", 70, 130]
TriggerButtonBad  = ["Cancel1", 75, 85]
TriggerSuccess    = ["Chime2", 80, 115]
TriggerFailure    = ["Stare", 80, 95]

# This setting determines what happens when an incorrect button is pressed.
# This can be one of 3 values.
# 1 = Do nothing.
# 2 = Restart minigame.
# 3 = Fail the minigame.
# 4 = Custom.  Meant for scripters.  Search for "##~Bookmark1" to edit.
TriggerWrong = 3

#------
#     Matching Minigame Settings:
#
# These are the default settings of the minigame.  See instructions above for
# further explaination.
DefSMatch   = 4
DefSTime    = 204

# These are the buttons that can be mixed into the pattern.  Allowed buttons
# include :A, :B, :C, :X, :Y, :Z, :LEFT, :RIGHT, :UP, and :DOWN.
DefSButtons = [:LEFT, :RIGHT, :UP, :DOWN]

# This is the image to be used as the menu back.  It is stretched to fit all
# the buttons to be pressed.
SBackImage     = "MenuBackItem"

# This value is the X offset of the pointer that appears above the button to be
# pressed.
SPointerOffset = 0

# This is the color of the bar for the time of the minigame.
# [Red, Green, Blue, Opacity]
MatchBarColor   = [192, 15, 45]

# These are the sound effects used by the minigame.  ButtonGood and ButtonBad
# are used to indicate if the player has pressed a matching button or not.
# ["Filename", Volume, Pitch]
MatchButtonGood = ["Switch1", 70, 130]
MatchButtonBad  = ["Cancel1", 75, 85]
MatchSuccess    = ["Chime2", 80, 115]
MatchFailure    = ["Stare", 80, 95]

# This settings determines what happens when an incorrect button is pressed.
# This can be one of 3 values.
# 1 = Do nothing.
# 2 = Mark the button wrong.
# 3 = Fail the minigame.
# 4 = Custom.  Meant for scripters.  Search for "##~Bookmark3" to edit.
MatchWrong = 3

#------
#     Target Minigame Settings:
#
# These are the default settings of the minigame.  See instructions above for
# futher explaination.
DefXZoom  = 1.5
DefXTime  = 120
DefXSpeed = 7

# These are the main images used by the script.  The back image holds the text
# and counter, the bar image is the target bar.
XBackImage   = "MenuBackItem"
XBarImage    = "MiniGameTarget"
TargetImage  = "MiniGameTargetText"
TargetSlider = "MiniGameTargetSlider"

# The Y offset of the slider.
SliderOffset = 4

# The button that must be pressed for the minigame.
TargetButton = :C

# The area of the bar that can be used to win the minigame.  This value must
# be a decimal.  A value of 1.0 would be the entire bar while 0.0 would be none
# of the bar.  If the target area is 20% of the bar, the value you put here
# would be 0.2.
TargetArea   = 0.15

# The sound effects used by the minigame.
# ["Filename", Volume, Pitch]
TargetButtonBad = ["Cancel2", 85, 125]
TargetSuccess   = ["Chime2", 80, 115]
TargetFailure   = ["Stare", 80, 95]

# This setting determines what happens when an incorrect button is pressed.
# This can be one of 3 values.
# 1 = Restart minigame.
# 2 = Fail minigame.
# 3 = Custom.  Meant for scripters.  Search for "##~Bookmark2" to edit.
TargetWrong = 2
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end

## The common class for all minigames.  All other games are built off this.
class Scene_CPMinigame < Scene_Base
  include CPMinigame  ## Include the above module in this class.
  
  ButtonIndex ={ ## A hash containing the spritesheet setup.
    :UPLEFT => 0, :UP => 1, :UPRIGHT => 2, :L => 3, :R => 4, :ARROW => 5,
    :TAP => 6, :LEFT => 7, :CENTER => 8, :RIGHT => 9, :X => 10, :Y => 11,
    :Z => 12, :GOOD => 13, :DOWNLEFT => 14, :DOWN => 15, :DOWNRIGHT => 16,
    :A => 17, :B => 18, :C => 19, :BAD => 20}
  
  @@background_image = nil
  
  def self.get_background_image ## Gets a custom background image.
    @@background_image = Graphics.snap_to_bitmap
    @@background_image.blur if BlurBack
  end
  
  def start
    super  ## The basic common start and post stats with a wait command.
    create_background
    create_game_sprites
  end
  
  def post_start
    super
    wait(5)
  end
  
  def terminate
    super  ## The basic terminate which auto disposes for me.
    dispose_background
    dispose_game_sprites
  end
  
  def create_background  ## Background create and dispose.
    @background_sprite = Sprite.new
    @background_sprite.bitmap = @@background_image
    @background_sprite.color.set(*DimSetting) if DimBack
  end
  
  def dispose_background
    @background_sprite.dispose
  end
  
  ## Gets a button image from the spritesheet and returns a bitmap with only
  ## the selected image on it.  Used by all minigames except the slider.
  def get_button_image(button)
    button_bitmap = Cache.system(ButtonImages)
    bitmap = Bitmap.new(button_bitmap.width / 7, button_bitmap.height / 3)
    return bitmap unless ButtonIndex.include?(button)
    index = ButtonIndex[button]
    rect = Rect.new(index % 7 * bitmap.width, index / 7 * bitmap.height,
                    bitmap.width, bitmap.height)
    bitmap.blt(0, 0, button_bitmap, rect)
    return bitmap
  end
  
  ## Success and failure main methods.  These set the switch and wait after the
  ## game has been won before sending the player to the previous scene.
  def minigame_success
    set_complete_variable
    $game_switches[GameSwitch] = true
    wait(40)
    return_scene
  end
  
  def minigame_failure
    set_complete_variable
    $game_switches[GameSwitch] = false
    wait(40)
    return_scene
  end
  
  def set_complete_variable
  end
  
  def wait(duration = 20)  ## An added wait command to allow me to pause things.
    duration.times { update_basic }
  end
end

##------
## Button Mash Minigame
##------
class MashQTE < Scene_CPMinigame
  @@prepared_valuesM = []
  
  ## Sets up the first bits of the game before starting it.  Same in all
  ## 4 minigames.
  def self.play(presses = DefMPresses, time = DefMTime, button = DefMButton)
    get_background_image
    @@prepared_valuesM = [presses, time, button]
    SceneManager.call(MashQTE)
    Fiber.yield
  end
  
  ## Minigame creation process.
  def create_game_sprites
    create_back_sprite
    create_tap_bar
    create_button_sprite
    create_tap_sprite
    create_number_sprites
  end
  
  def create_back_sprite
    @menu_back = Sprite.new(@viewport)
    bit1 = Cache.system(MBackImage)
    bit2 = Cache.system(MashImage)
    wd, ht = bit1.width, [bit1.height, bit2.height].max
    @menu_back.bitmap = Bitmap.new(wd, ht)
    @menu_back.ox, @menu_back.oy = @menu_back.width / 2, @menu_back.height / 2
    @menu_back.x, @menu_back.y = Graphics.width / 2, Graphics.height / 2 - 4
    @menu_back.bitmap.blt(0, (ht - bit1.height) / 2, bit1, bit1.rect)
    @menu_back.bitmap.blt(0, (ht - bit2.height) / 2, bit2, bit2.rect)
  end
  
  def create_tap_bar
    @tap_bar = Sprite.new(@viewport)
    @tap_bar.bitmap = Bitmap.new(@menu_back.width, @menu_back.height + 8)
    @tap_bar.ox, @tap_bar.oy = @menu_back.ox, @menu_back.oy
    @tap_bar.x, @tap_bar.y = @menu_back.x, @menu_back.y
    @tapped_times = [0, 0, @@prepared_valuesM[0]]
    c3 = Color.new(*BarBackColor)
    @tap_bar.bitmap.fill_rect(0, @tap_bar.height - 8, @tap_bar.width, 8, c3)
  end
  
  def create_button_sprite
    z = ButtonZoom
    @button_sprite = Sprite.new(@viewport)
    @button_sprite.bitmap = get_button_image(@@prepared_valuesM[2])
    @button_sprite.ox = @button_sprite.width / 2
    @button_sprite.oy = @button_sprite.height / 2
    @button_sprite.x = @menu_back.x - @menu_back.ox - (@button_sprite.ox * z)
    @button_sprite.y = @menu_back.y + 4
    @button_sprite.zoom_x = @button_sprite.zoom_y = z
  end
  
  def create_tap_sprite
    @tap_sprite = Sprite.new(@viewport)
    @tap_sprite.bitmap = get_button_image(:TAP)
    @tap_sprite.ox = @tap_sprite.width / 2
    @tap_sprite.oy = @tap_sprite.height
    @tap_sprite.x = @button_sprite.x + MashOffset
    z = ButtonZoom
    @tap_sprite.zoom_x = @tap_sprite.zoom_y = z
    @tap_sprite.y = @button_sprite.y - 8 * @tap_sprite.zoom_x
    @tap_sprite.z = 50
    @tap_counter = 0
  end
  
  def create_number_sprites
    @number_sprite = Sprite.new(@viewport)
    @number_sprite.bitmap = Bitmap.new(@menu_back.width, @menu_back.height)
    @number_sprite.ox, @number_sprite.oy = @menu_back.ox, @menu_back.oy
    @number_sprite.x, @number_sprite.y = @menu_back.x, @menu_back.y
    @timer_value = @@prepared_valuesM[1]
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
  end
  
  def update
    super  ## Main gameplay process.  Nothing too interesting from here on.
    update_tap_sprite
    update_timer_sprite
    update_tap_count
  end
  
  def update_tap_sprite
    @tap_counter += 1
    if @tap_counter % 32 == 0
      @tap_sprite.y = @button_sprite.y - 8 * @tap_sprite.zoom_x
    elsif (@tap_counter + 16) % 32 == 0
      @tap_sprite.y = @button_sprite.y
    end
  end
  
  def update_timer_sprite
    @timer_value -= 1
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.clear
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
    return minigame_failure if value <= 0.0
  end
  
  def update_tap_count
    if Input.trigger?(@@prepared_valuesM[2])
      @tapped_times[1] += 1
    end
    if @tapped_times[0] != @tapped_times[1]
      @tapped_times[0] = @tapped_times[1]
      @tap_bar.bitmap.clear
      c1 = Color.new(*MashBarColor)
      w = (@tap_bar.width - 2) * (@tapped_times[1].to_f / @tapped_times[2])
      c3 = Color.new(*BarBackColor)
      @tap_bar.bitmap.fill_rect(0, @tap_bar.height - 8, @tap_bar.width, 8, c3)
      @tap_bar.bitmap.fill_rect(1, @tap_bar.height - 7, w, 6, c1)
    end
    if @tapped_times[1] >= @tapped_times[2]
      minigame_success
    end
  end
  
  def dispose_game_sprites
    @menu_back.dispose
    @tap_bar.dispose
    @button_sprite.dispose
    @tap_sprite.dispose
    @number_sprite.dispose
  end
  
  def minigame_success
    RPG::SE.new(*MashSuccess).play
    super
  end
  
  def minigame_failure
    RPG::SE.new(*MashFailure).play
    super
  end
  
  def set_complete_variable
    super
    $game_variables[GameVariable] = @tapped_times[1]
  end
end

##------
## Trigger Button Minigame.
##------
class TriggerQTE < Scene_CPMinigame
  @@prepared_valuesT = []
  
  def self.play(match = DefTMatch, time = DefTTime, buttons = DefTButtons)
    get_background_image
    @@prepared_valuesT = [match, time, buttons]
    SceneManager.call(TriggerQTE)
    Fiber.yield
  end
  
  def create_game_sprites
    create_qte_pattern
    create_menu_sprite
    create_menu_top
    create_time_bar
    create_number_sprites
  end
  
  def create_menu_sprite
    temp = get_button_image(:A)
    wd = temp.width * (@pattern.size + 2)
    bit0 = Cache.system(TBackImage)
    @menu_back = Sprite.new(@viewport)
    @menu_back.bitmap = Bitmap.new(wd, [bit0.height, temp.height].max)
    rect = Rect.new(0, (@menu_back.height - bit0.height) / 2, wd, bit0.height)
    @menu_back.bitmap.stretch_blt(rect, bit0, bit0.rect)
    @top_edge = (@menu_back.height - temp.height) / 2
    @pattern.each_with_index do |s,i|
      bit = get_button_image(s)
      @menu_back.bitmap.blt(bit.width * i, @top_edge, bit, bit.rect)
    end
    @menu_back.ox, @menu_back.oy = @menu_back.width / 2, @menu_back.height / 2
    @menu_back.x, @menu_back.y = Graphics.width / 2, Graphics.height / 2 - 4
  end
  
  def create_menu_top
    @correct = 0
    @menu_top = Sprite.new(@viewport)
    @menu_top.bitmap = Bitmap.new(@menu_back.width, @menu_back.height)
    @menu_top.z = 50
    @menu_top.ox, @menu_top.oy = @menu_back.ox, @menu_back.oy
    @menu_top.x, @menu_top.y = @menu_back.x, @menu_back.y
  end
  
  def create_time_bar
    @time_bar = Sprite.new(@viewport)
    @time_bar.bitmap = Bitmap.new(@menu_back.width, @menu_back.height + 8)
    @time_bar.ox, @time_bar.oy = @menu_back.ox, @menu_back.oy
    @time_bar.x, @time_bar.y = @menu_back.x, @menu_back.y
    c3 = Color.new(*BarBackColor)
    @time_bar.bitmap.fill_rect(0, @time_bar.height - 8, @time_bar.width, 8, c3)
    c1 = Color.new(*TriggerBarColor)
    @time_bar.bitmap.fill_rect(1, @time_bar.height - 7, @time_bar.width, 6, c1)
  end
  
  def create_number_sprites
    @number_sprite = Sprite.new(@viewport)
    @number_sprite.bitmap = Bitmap.new(@menu_back.width, @menu_back.height)
    @number_sprite.ox, @number_sprite.oy = @menu_back.ox, @menu_back.oy
    @number_sprite.x, @number_sprite.y = @menu_back.x, @menu_back.y
    @timer_value = @@prepared_valuesT[1]
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
  end
  
  def create_qte_pattern
    @pattern = []
    @@prepared_valuesT[0].times do
      @pattern.push(@@prepared_valuesT[2][rand(@@prepared_valuesT[2].size)])
    end
  end
  
  def update
    super
    update_timer_sprite
    update_trigger_count
  end
  
  def update_timer_sprite
    @timer_value -= 1
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.clear
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
    w = (@time_bar.width - 2) * (@timer_value.to_f / @@prepared_valuesT[1])
    c1 = Color.new(*TriggerBarColor)
    c3 = Color.new(*BarBackColor)
    @time_bar.bitmap.fill_rect(0, @time_bar.height - 8, @time_bar.width, 8, c3)
    @time_bar.bitmap.fill_rect(1, @time_bar.height - 7, w, 6, c1)
    return minigame_failure if value <= 0.0
  end
  
  def update_trigger_count
    full = [:LEFT, :RIGHT, :UP, :DOWN, :A, :B, :C, :X, :Y, :Z, :L, :R]
    full.each do |s|
      if Input.trigger?(s)
        if s == @pattern[@correct]
          on_trigger_right
        else
          on_trigger_wrong
        end
        break
      end
    end
  end
  
  def on_trigger_right
    bit = get_button_image(:GOOD)
    @menu_top.bitmap.blt(bit.width * @correct, @top_edge, bit, bit.rect)
    @correct += 1
    return minigame_success if @correct >= @pattern.size
    RPG::SE.new(*TriggerButtonGood).play
  end
  
  def on_trigger_wrong
    case TriggerWrong
    when 1
      RPG::SE.new(*TriggerButtonBad).play
    when 2
      RPG::SE.new(*TriggerButtonBad).play
      @correct = 0
      @menu_top.bitmap.clear
    when 3
      bit = get_button_image(:BAD)
      @menu_top.bitmap.blt(bit.width * @correct, @top_edge, bit, bit.rect)
      minigame_failure
    when 4
      return custom_trigger_wrong
    end
  end
  
  def custom_trigger_wrong
    ##~Bookmark1
    ## This section is meant for custom code for when the player gets an
    ## object wrong from the trigger.  Maker sure TriggerWrong is set to 4
    ## for this section to occur.
  end
  
  def dispose_game_sprites
    @menu_back.dispose
    @menu_top.dispose
    @time_bar.dispose
    @number_sprite.dispose
  end
  
  def minigame_success
    RPG::SE.new(*TriggerSuccess).play
    super
  end
  
  def minigame_failure
    RPG::SE.new(*TriggerFailure).play
    super
  end
  
  def set_complete_variable
    super
    $game_variables[GameVariable] = @correct
  end
end

##------
## Button Match Minigame
##------
class MatchQTE < Scene_CPMinigame
  @@prepared_valuesS = []
  
  def self.play(match = DefSMatch, time = DefSTime, buttons = DefSButtons)
    get_background_image
    @@prepared_valuesS = [match, time, buttons]
    SceneManager.call(MatchQTE)
    Fiber.yield
  end
  
  def create_game_sprites
    create_qte_pattern
    create_menu_sprite
    create_menu_top
    create_pointer
    create_time_bar
  end
  
  def create_menu_sprite
    temp = get_button_image(:A)
    wd = temp.width * (@pattern.size + 2)
    bit0 = Cache.system(SBackImage)
    @menu_back = Sprite.new(@viewport)
    @menu_back.bitmap = Bitmap.new(wd, [bit0.height, temp.height].max)
    rect = Rect.new(0, (@menu_back.height - bit0.height) / 2, wd, bit0.height)
    @menu_back.bitmap.stretch_blt(rect, bit0, bit0.rect)
    @top_edge = (@menu_back.height - temp.height) / 2
    @pattern.each_with_index do |s,i|
      bit = get_button_image(s)
      @menu_back.bitmap.blt(bit.width * (i + 1), @top_edge, bit, bit.rect)
    end
    @menu_back.ox, @menu_back.oy = @menu_back.width / 2, @menu_back.height / 2
    @menu_back.x, @menu_back.y = Graphics.width / 2, Graphics.height / 2 - 4
  end
  
  def create_menu_top
    @menu_top = Sprite.new(@viewport)
    @menu_top.bitmap = Bitmap.new(@menu_back.width, @menu_back.height)
    @menu_top.z = 50
    @menu_top.ox, @menu_top.oy = @menu_back.ox, @menu_back.oy
    @menu_top.x, @menu_top.y = @menu_back.x, @menu_back.y
  end
  
  def create_pointer
    @pointer = Sprite.new(@viewport)
    @pointer.bitmap = get_button_image(:ARROW)
    @pointer.ox = @menu_back.ox - SPointerOffset
    @pointer.oy = @menu_back.oy + @pointer.height
    @pointer.x, @pointer.y = @menu_back.x, @menu_back.y
  end
  
  def create_time_bar
    @time_bar = Sprite.new(@viewport)
    @time_bar.bitmap = Bitmap.new(@menu_back.width, @menu_back.height + 8)
    @time_bar.ox, @time_bar.oy = @menu_back.ox, @menu_back.oy
    @time_bar.x, @time_bar.y = @menu_back.x, @menu_back.y
    @timer_value = 0
    c3 = Color.new(*BarBackColor)
    @time_bar.bitmap.fill_rect(0, @time_bar.height - 8, @time_bar.width, 8, c3)
  end
  
  def create_qte_pattern
    @pattern = []; @matches = []
    @@prepared_valuesS[0].times do
      @pattern.push(@@prepared_valuesS[2][rand(@@prepared_valuesS[2].size)])
    end
  end
  
  def update
    super
    update_timer_sprite
    update_match_count
  end
  
  def update_timer_sprite
    @timer_value += 1
    w = (@time_bar.width - 2) * (@timer_value.to_f / @@prepared_valuesS[1])
    c1 = Color.new(*MatchBarColor)
    c3 = Color.new(*BarBackColor)
    @time_bar.bitmap.fill_rect(0, @time_bar.height - 8, @time_bar.width, 8, c3)
    @time_bar.bitmap.fill_rect(1, @time_bar.height - 7, w, 6, c1)
    @pos = @timer_value / (@@prepared_valuesS[1] / (@@prepared_valuesS[0] + 2))
    @pos = [@pos, @@prepared_valuesS[0] + 1].min
    return check_minigame_value if @timer_value >= @@prepared_valuesS[1]
    @pointer.x = @menu_back.x + (@pos * @pointer.width)
    check_last_pos
  end
  
  def update_match_count
    return if @pos == 0 || @pattern[@pos - 1].nil? || !@matches[@pos - 1].nil?
    full = [:LEFT, :RIGHT, :UP, :DOWN, :A, :B, :C, :X, :Y, :Z, :L, :R]
    full.each do |s|
      if Input.trigger?(s)
        @matches[@pos - 1] = s
        if s == @pattern[@pos - 1]
          on_trigger_right
        else
          on_trigger_wrong
        end
        break
      end
    end
  end
  
  def check_last_pos
    return if @pos < 2 || !@matches[@pos - 2].nil?
    @matches[@pos - 2] = false
    on_trigger_wrong(@pos - 1) unless MatchWrong == 1
  end
  
  def on_trigger_right
    RPG::SE.new(*MatchButtonGood).play
    bit = get_button_image(:GOOD)
    @menu_top.bitmap.blt(bit.width * @pos, @top_edge, bit, bit.rect)
  end
  
  def on_trigger_wrong(pos = @pos)
    case MatchWrong
    when 1
      RPG::SE.new(*TriggerButtonBad).play
      ## Nothing is done.
    when 2
      fill_in_wrong_trigger(pos)
    when 3
      bit = get_button_image(:BAD)
      @menu_top.bitmap.blt(bit.width * pos, @top_edge, bit, bit.rect)
      minigame_failure
    when 4
      return custom_trigger_wrong
    end
  end
  
  def custom_trigger_wrong
    ##~Bookmark3
    ## This section is meant for custom code for when the player gets an
    ## object wrong from the trigger.  Maker sure MatchWrong is set to 3
    ## for this section to occur.
  end
  
  def fill_in_wrong_trigger(pos = @pos)
    RPG::SE.new(*MatchButtonBad).play
    bit = get_button_image(:BAD)
    @menu_top.bitmap.blt(bit.width * pos, @top_edge, bit, bit.rect)
  end
  
  def check_minigame_value
    @pattern.each_with_index do |s,i|
       return minigame_failure if @matches[i] != s
    end
    return minigame_success
  end
  
  def dispose_game_sprites
    @menu_back.dispose
    @menu_top.dispose
    @time_bar.dispose
    @pointer.dispose
  end
  
  def minigame_success
    RPG::SE.new(*MatchSuccess).play
    super
  end
  
  def minigame_failure
    RPG::SE.new(*MatchFailure).play
    super
  end
  
  def set_complete_variable
    super
    var = 0
    @pattern.each_with_index { |s,i| var += 1 if s == @matches[i] }
    $game_variables[GameVariable] = var
  end
end

class ThermonuclearWar < Scene_CPMinigame
  def self.play  ## Type in ThermonuclearWar.play
    get_background_image
    SceneManager.call(ThermonuclearWar)
    Fiber.yield
  end
  
  def create_game_sprites
    black = Color.new(0, 0, 0)
    @blackness = Sprite.new(@viewport)
    @blackness.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @blackness.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, black)
    @blackness.bitmap.font.color = Color.new(255, 255, 255)
    @blackness.visible = false
  end
  
  def update
    super
    wait(45)
    RPG::BGS.stop
    RPG::BGM.stop
    @blackness.visible = true
    rect = @blackness.bitmap.rect
    @blackness.bitmap.fill_rect(rect, Color.new(0, 0, 0))
    @blackness.bitmap.draw_text(rect, "Shall we play a game?", 1)
    wait(180)
    @blackness.bitmap.fill_rect(rect, Color.new(0, 0, 0))
    @blackness.bitmap.draw_text(rect, "How about a game of Thermonuclear War?", 1)
    wait(180)
    @blackness.bitmap.fill_rect(rect, Color.new(0, 0, 0))
    @blackness.bitmap.draw_text(rect, "The only winning move is not to play.", 1)
    wait(180)
    exit
  end
  
  def minigame_success
    RPG::SE.new(*MatchSuccess).play
    super
  end
  
  def minigame_failure
    RPG::SE.new(*MatchFailure).play
    super
  end
  
  def set_complete_variable
    super
    var = 0
    @pattern.each_with_index { |s,i| var += 1 if s == @matches[i] }
    $game_variables[GameVariable] = var
  end
end

##------
## Target Slider Minigame
##------
class TargetQTE < Scene_CPMinigame
  @@prepared_valuesX = []
  
  def self.play(zoom = DefXZoom, time = DefXTime, speed = DefXSpeed)
    get_background_image
    @@prepared_valuesX = [zoom, time, speed]
    SceneManager.call(TargetQTE)
    Fiber.yield
  end
  
  def create_game_sprites
    create_menu_sprite
    create_slider_sprite
    create_number_sprites
  end
  
  def create_menu_sprite
    @menu_back = Sprite.new(@viewport)
    bit0 = Cache.system(XBackImage)
    bit1 = Cache.system(XBarImage)
    bit2 = Cache.system(TargetImage)
    mh = [bit0.height, bit2.height].max
    offx = bit1.height + ((mh - bit0.height) / 2)
    @menu_back.bitmap = Bitmap.new(bit1.width, bit1.height + mh)
    rect1 = Rect.new(0, offx, bit1.width, bit0.height)
    @menu_back.bitmap.stretch_blt(rect1, bit0, bit0.rect)
    @menu_back.bitmap.blt(0, offx, bit2, bit2.rect)
    sx = (bit1.width * @@prepared_valuesX[0] - bit1.width) / 2
    sw = bit1.width - sx * 2
    rect3 = Rect.new(0, 0, bit1.width, bit1.height)
    rect4 = Rect.new(sx, 0, sw, bit1.height)
    @menu_back.bitmap.stretch_blt(rect3, bit1, rect4)
    @hi_section = (bit1.width / 2) / @@prepared_valuesX[2]
    @lo_section = -@hi_section
    @menu_back.ox, @menu_back.oy = @menu_back.width / 2, @menu_back.height / 2
    @menu_back.x, @menu_back.y = Graphics.width / 2, Graphics.height / 2
  end
  
  def create_slider_sprite
    @slider = Sprite.new(@viewport)
    @slider.bitmap = Cache.system(TargetSlider)
    @slider.z = 50
    @slider.ox = @slider.width / 2
    @slider.oy = @menu_back.oy + @slider.height - SliderOffset
    @slider.x = @menu_back.x + @lo_section * @@prepared_valuesX[2]
    @slider.y = @menu_back.y
    @pos = @lo_section
  end
  
  def create_number_sprites
    @number_sprite = Sprite.new(@viewport)
    bit = Cache.system(XBarImage)
    @number_sprite.bitmap = Bitmap.new(@menu_back.width,
                                       @menu_back.height - bit.height)
    @number_sprite.ox = @menu_back.ox
    @number_sprite.x, @number_sprite.y = @menu_back.x, @menu_back.y
    @timer_value = @@prepared_valuesX[1]
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
  end
  
  def update
    super
    update_slider_sprite
    update_timer_sprite
    update_tap_count
  end
  
  def update_slider_sprite
    if @pos == @lo_section
      @dir = 1
    elsif @pos == @hi_section
      @dir = -1
    end
    @pos += @dir
    @slider.x = @menu_back.x + @pos * @@prepared_valuesX[2]
  end
  
  def update_timer_sprite
    @timer_value -= 1
    value = ((@timer_value + 5) / 6).to_f / 10
    @number_sprite.bitmap.clear
    @number_sprite.bitmap.draw_text(@number_sprite.bitmap.rect, "#{value} ", 2)
    return minigame_failure if value <= 0.0
  end
  
  def update_tap_count
    if Input.trigger?(TargetButton)
      spot = (@pos * @@prepared_valuesX[2]).abs
      area = (@menu_back.width * @@prepared_valuesX[0] * TargetArea) / 2
      if area >= spot
        return minigame_success
      else
        return on_target_wrong
      end
    end
  end
  
  def on_target_wrong
    case TargetWrong
    when 1
      RPG::SE.new(*TargetButtonBad).play
      @pos = @lo_section
    when 2
      minigame_failure
    when 3
      return custom_target_wrong
    end
  end
  
  def custom_target_wrong
    ##~Bookmark2
    ## This section is meant for custom code for when the player targets
    ## a bad position on the slider bar.  Maker sure TargetWrong is set to 3
    ## for this section to occur.
  end
  
  def dispose_game_sprites
    @menu_back.dispose
    @slider.dispose
    @number_sprite.dispose
  end
  
  def minigame_success
    RPG::SE.new(*TargetSuccess).play
    super
  end
  
  def minigame_failure
    RPG::SE.new(*TargetFailure).play
    super
  end
  
  def set_complete_variable
    super
    ## Nothing....  Nothing is here....
  end
end


##-----------------------------------------------------------------------------
##  End of script.
##-----------------------------------------------------------------------------