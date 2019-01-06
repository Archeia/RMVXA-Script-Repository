#Popup Window v1.2d
#----------#
#Features: Create a popup window for anything you want! How magical!
#
#Usage:    Script calls:
#           (In Events:)
#           pop_up(['text','text', ... ], timer(opt), x(opt), y(opt))
#           (Anywhere else:)
#           Popup.add(['text','text', ... ], timer(opt), x(opt), y(opt))
#
#          Examples:
#           pop_up(['\i[5] Mage class unlocked!!'])
#           pop_up(['\c[16] Class Change:\c[0]',
#                   ' Speak to any mysterious hermit to change class!'],240)
#
#   Escape codes not working? You have two options... switch to '' singe quotes
#    instead of "" double quotes, or double up on \\ slashes.
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
$imported = {} if $imported.nil?
$imported[:Vlue_PopupWindow] = true
 
POPUP_DURATION = 180
 
class Popup_Window < Window_Base
  def initialize(text,timer,x,y)
    super(0,0,25,100)
    text.each do |string|
      temp_string = string.gsub(/\\[^invpgINVPG]\[\d{0,3}\]/) { "" }
      temp_string = temp_string.gsub(/\\i\[\d{0,3}\]/) { icon_width }
      temp_string = convert_escape_characters(temp_string)
      self.width = [text_size(temp_string).width+standard_padding*2+12,self.width].max
    end
    self.height = text.size * line_height + line_height
    if x.nil?
      self.x = Graphics.width / 2 - self.width / 2
    else
      self.x = x
    end
    if y.nil?
      self.y = Graphics.height / 2 - self.height / 2
    else
      self.y = y
    end
    @text = text
    @timer = timer
    create_contents
    refresh
    self.openness = 0
    open
  end
  def icon_width
    size = text_size(' ').width
    ' ' * (24 / size)
  end
  def refresh
    contents.clear
    yy = 0
    @text.each do |string|
      draw_text_ex(0,yy,string)
      yy += line_height
    end
  end
  def update
    super
    @timer -= 1
    close if @timer == 0
  end
end
 
module Popup
  def self.init
    @queue = []
  end
  def self.add(text, timer = POPUP_DURATION, x = nil, y = nil)
    @queue.push([text,timer,x,y])
  end
  def self.queue
    @queue
  end
end  
 
Popup.init
 
class Scene_Base
  alias popupwin_preterminate pre_terminate
  alias popupwin_update update
  def update
    popupwin_update
    update_popup_window_text unless $popup.nil?
    return if Popup.queue.empty?
    if $popup.nil? or $popup.close?
      text = Popup.queue.pop
      $popup = Popup_Window.new(text[0], text[1], text[2], text[3])
    end
  end
  def update_popup_window_text
    $popup.update
    $popup.close if Input.trigger?(:C)
    if !$popup.disposed? and $popup.close?
      $popup.dispose
      $popup = nil
    end
  end
  def pre_terminate
    popupwin_preterminate
    $popup.visible = false unless $popup.nil?
  end
end
 
class Game_Interpreter
  alias popup_command_355 command_355
  def pop_up(text, timer = POPUP_DURATION, x = nil, y = nil)
    Popup.add(text, timer, x, y)
  end
  def command_355
    popup_command_355
    wait_for_popup #if SceneManager.scene.is_a?(Scene_Map)
  end
  def wait_for_popup
    Fiber.yield while !Popup.queue.empty? || $popup
  end
end