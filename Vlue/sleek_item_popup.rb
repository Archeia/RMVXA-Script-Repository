#Sleek Item Popup v1.14a
#----------#
#Features: A nice and sleek little pop up you can use to tell the player
#           they received (or lost) an item! Now with automatic popups whenever
#           you use the gain item commands in events!
#
#Usage:   Event Script Call:
#           popup(type,item,amount,[duration],[xoff],[yoff])
#
#          Where: type is category of item (0 = item, 1 = weapon,
#                                            2 = armor, 3 = gold)
#                 item is the id number of the item
#                 amount is the amount lost or gained
#                 duration is the time the window is up and is optional
#          
#          Examples:
#            popup(0,1,5)
#            popup(2,12,1,120)
#            $PU_AUTOMATIC_POPUP = false
#            $PU_AUTOMATIC_POPUP = true
#        
#Customization: Everything down there under customization
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
$imported = {} if $imported.nil?
$imported[:Vlue_SleekPopup] = true
 
#Sound effect played on popup: # "Filename", Volume(0-100), Pitch(50-150)
PU_SOUND_EFFECT_GAIN = ["Item3",100,50]
PU_SOUND_EFFECT_LOSE = ["Item3",100,50]
PU_SOUND_GOLD_GAIN = ["Coin",100,50]
PU_SOUND_GOLD_LOSE = ["Coin",100,50]
 
#Animation to be played on the player during popup
PU_USE_ANIMATION = false
PU_POPUP_ANIMATION = 2
 
#Duration in frames of Item Popup fadein and fadeout
PU_FADEIN_TIME = 30
PU_FADEOUT_TIME = 30
 
#Default duration of the popup
PU_DEFAULT_DURATION = 90
 
#Use automatic popup? Can be enabled/disabled in game, see examples
$PU_AUTOMATIC_POPUP = true
PU_IGNORE_ITEM_LOSS = true
 
#Whether to use a custom or default font
PU_USE_CUSTOM_FONT = false
 
#Settings for custom item popup font
PU_DEFAULT_FONT_NAME = ["Verdana"]
PU_DEFAULT_FONT_SIZE = 16
PU_DEFAULT_FONT_COLOR = Color.new(255,255,255,255)
PU_DEFAULT_FONT_BOLD = false
PU_DEFAULT_FONT_ITALIC = false
PU_DEFAULT_FONT_SHADOW = false
PU_DEFAULT_FONT_OUTLINE = true
 
#Compact mode will hide the amount unless it's greater then 1
PU_COMPACT_MODE = true
 
#Background Icon to be displayed under item icon
PU_USE_BACKGROUND_ICON = true
PU_BACKGROUND_ICON = 102
 
#Gold details:
PU_GOLD_NAME = "Gold"
PU_GOLD_ICON = 262
 
#True for single line, false for multi line
PU_SINGLE_LINE = true
 
class Item_Popup < Window_Base
  def initialize(item, amount, duration, nosound,xoff,yoff)
    super(0,0,100,96)
    if item.name == PU_GOLD_NAME
      sedg, sedl = PU_SOUND_GOLD_GAIN, PU_SOUND_GOLD_LOSE
    else
      sedg, sedl = PU_SOUND_EFFECT_GAIN, PU_SOUND_EFFECT_LOSE
    end
    se = RPG::SE.new(sedg[0],sedg[1],sedg[2]) unless sedg.nil? or nosound
    se2 = RPG::SE.new(sedl[0],sedl[1],sedl[2]) unless sedl.nil? or nosound
    se.play if se and amount > 0
    se2.play if se2 and amount < 0
    self.opacity = 0
    self.x = $game_player.screen_x - 16
    self.y = $game_player.screen_y - 80
    @xoff = 0
    @yoff = 0
    @duration = 90
    @item = item
    @amount = amount
    @name = item.name.clone
    @text = ""
    @padding = ' '*@name.size
    @timer = 0
    @split = (PU_FADEIN_TIME) / @name.size
    @split = 2 if @split < 2
    amount > 0 ? @red = Color.new(0,255,0) : @red = Color.new(255,0,0)
    if PU_USE_CUSTOM_FONT
      contents.font.size = PU_DEFAULT_FONT_SIZE
    else
      contents.font.size = 16
    end
    @textsize = text_size(@name)
    textsize2 = text_size("+" + amount.to_s)
    self.width = @textsize.width + standard_padding * 2 + 24
    self.width += textsize2.width + 48 if PU_SINGLE_LINE
    contents.font.size < 24 ? size = 24 : size = contents.font.size
    self.height = size + standard_padding * 2
    self.height += size if !PU_SINGLE_LINE
    self.x -= self.width / 2
    create_contents
    if PU_USE_CUSTOM_FONT
      contents.font.name = PU_DEFAULT_FONT_NAME
      contents.font.size = PU_DEFAULT_FONT_SIZE
      contents.font.color = PU_DEFAULT_FONT_COLOR
      contents.font.bold = PU_DEFAULT_FONT_BOLD
      contents.font.italic = PU_DEFAULT_FONT_ITALIC
      contents.font.shadow = PU_DEFAULT_FONT_SHADOW
      contents.font.outline = PU_DEFAULT_FONT_OUTLINE
    end
    self.contents_opacity = 0
    $game_player.animation_id = PU_POPUP_ANIMATION if PU_USE_ANIMATION
    update
  end
  def update
    #super
    return if self.disposed?
    self.visible = true if !self.visible
    self.x = $game_player.screen_x - contents.width/4 + 12
    self.y = $game_player.screen_y - 80 + @yoff
    self.x -= self.width / 3
    open if @timer < (PU_FADEIN_TIME)
    close if @timer > (PU_FADEOUT_TIME + @duration)
    @timer += 1
    return if @timer % @split != 0
    @text += @name.slice!(0,1)
    @padding.slice!(0,1)
    contents.clear
    contents.font.color = @red
    stringamount = @amount
    stringamount = "+" + @amount.to_s if @amount > 0
    if PU_SINGLE_LINE
      width = text_size(@item.name).width#@textsize.width
      draw_text(27 + width,0,36,24,stringamount) unless PU_COMPACT_MODE and @amount == 1
      if Module.const_defined?(:AFFIXES)
        contents.font.color = @item.color
      else
        contents.font.color = Font.default_color
      end
      change_color(@item.rarity_colour) if $imported[:TH_ItemRarity]
      draw_text(24,0,contents.width,contents.height,@text+@padding)
      change_color(normal_color)
      draw_icon(PU_BACKGROUND_ICON,0,0) if PU_USE_BACKGROUND_ICON
      draw_icon(@item.icon_index,0,0)
    else
      draw_text(contents.width / 4 + 16,24,36,24,stringamount) unless PU_COMPACT_MODE and @amount == 1
      if Module.const_defined?(:AFFIXES)
        contents.font.color = @item.color
      else
        contents.font.color = Font.default_color
      end
      draw_icon(PU_BACKGROUND_ICON,contents.width / 2 - 24,24) if PU_USE_BACKGROUND_ICON
      draw_icon(@item.icon_index,contents.width / 2 - 24,24)
      draw_text(0,0,contents.width,line_height,@text+@padding)
    end
  end
  def close
    self.contents_opacity -= (255 / (PU_FADEOUT_TIME))
  end
  def open
    self.contents_opacity += (255 / (PU_FADEIN_TIME))
  end
end
 
class Game_Interpreter
  alias pu_command_126 command_126
  alias pu_command_127 command_127
  alias pu_command_128 command_128
  alias pu_command_125 command_125
  def popup(type,item,amount,duration = PU_DEFAULT_DURATION,nosound = false, xo = 0, yo = 0)
    data = $data_items[item] if type == 0
    data = $data_weapons[item] if type == 1
    data = $data_armors[item] if type == 2
    if type == 3
      data = RPG::Item.new
      data.name = PU_GOLD_NAME
      data.icon_index = PU_GOLD_ICON
    end
    Popup_Manager.add(data,amount,duration,nosound,xo,yo)
  end
  def command_125
    pu_command_125
    value = operate_value(@params[0], @params[1], @params[2])
    popup(3,@params[0],value) if $PU_AUTOMATIC_POPUP
  end
end
 
module Popup_Manager
  def self.init
    @queue = []
  end
  def self.add(item,value,dura,ns,xo,yo)
    return if PU_IGNORE_ITEM_LOSS && value < 1
    @queue.insert(0,[item,value,dura,ns,xo,yo])
  end
  def self.queue
    @queue
  end
end  
 
Popup_Manager.init
 
class Scene_Map
  alias popup_update update
  alias popup_preterminate pre_terminate
  def update
    popup_update
    update_popup_window unless $popupwindow.nil?
    return if Popup_Manager.queue.empty?
    if $popupwindow.nil? or $popupwindow.contents_opacity == 0
      var = Popup_Manager.queue.pop
      $popupwindow = Item_Popup.new(var[0],var[1],var[2],var[3],var[4],var[5])
    end
  end
  def update_popup_window
    $popupwindow.update
    $popupwindow.dispose if !$popupwindow.disposed? and $popupwindow.contents_opacity == 0
    $popupwindow = nil if $popupwindow.disposed?
  end
  def pre_terminate
    popup_preterminate
    $popupwindow.visible = false unless $popupwindow.nil?
  end
end

class Game_Party
  def gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    last_number = item_number(item)
    new_number = last_number + amount
    container[item.id] = [[new_number, 0].max, max_item_number(item)].min
    container.delete(item.id) if container[item.id] == 0
    if include_equip && new_number < 0
      discard_members_equip(item, -new_number)
    end
    $game_map.need_refresh = true
    if SceneManager.scene.is_a?(Scene_Map) && $PU_AUTOMATIC_POPUP
      Popup_Manager.add(item,amount,90,false,0,0)
    end
  end
end