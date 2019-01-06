#--# Basic Enemy HP Bars v 2.9
#
# Adds customizable hp bars to enemies in battle. See configuration
#  below for more detail. Also allows for the option of using a nice
#  graphical hp bar from a image file.
#
# Usage: Plug and play, customize as needed.
#
#------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#Customization starts here:
module DTP_HP
  #Whether to place the hp bar above or below the enemy
  ABOVE_MONSTER = true
  #Whether to use a custome image or not:
  #Image would be placed in Graphics/System and named Custom_HP.png
  CUSTOM_BAR = false
  #Whether to include the hp bar or not
  USE_HP_BAR = true
  #Whether to include an mp bar or not
  USE_MP_BAR = true
 
  #The width of the hp bar
  BAR_WIDTH = 66
  #The height of the hp bar
  BAR_HEIGHT = 5
  #The width of the border around the hp bar
  BORDER_WIDTH = 1
  #The height of the border around the hp bar
  BORDER_HEIGHT = 1
  #Offset the hp bar along the x-axis(left,right)
  BAR_OFFSET_X = 0
  #Offset the hp bar along the y-axis(up,down)
  BAR_OFFSET_Y = 0
 
  #Color for the back of the hp bar
  COLOR_BAR_BACK = Color.new(0,0,0,200)
  #First color for the hp bar gradient
  COLOR_BAR_1 = Color.new(255,0,0)
  #Second color for the hp bar gradient
  COLOR_BAR_2 = Color.new(200,100,100)
  #Outside border color
  COLOR_BORDER_1 = Color.new(0,0,0,185)
  #Inside border color
  COLOR_BORDER_2 = Color.new(255,255,255,185)
  #First color for the mp bar gradient
  MP_COLOR_BAR_1 = Color.new(0,175,255)
  #Second color fot he mp bar gradient
  MP_COLOR_BAR_2 = Color.new(0,0,255)
 
  #Whether to display text or not
  USE_TEXT = true
  #Text to be displayed, chp = current hp, mhp = max hp, php = percentage hp
  #Examples: "php%" or "chp/mhp" or "chp - php%"
  TEXT_DISPLAY = "chp"
  #Offset for the text along the x-axis(left,right)
  TEXT_OFFSET_X = 5
  #Offset for the text along the y-axis(up,down)
  TEXT_OFFSET_Y = -24
  #Size of the displayed text
  TEXT_SIZE = Font.default_size
  #Font of the displayed text
  TEXT_FONT = Font.default_name
 
  #Show bars only when specific actor in party. Array format. Example: [8,7]
  #Set to [] to not use actor only
  SPECIFIC_ACTOR = []
  #Show enemy hp bar only if certain state is applied (like a scan state)
  #Set to 0 to not use state only
  SCAN_STATE = 0
  #Enemies will show hp bar as long as they have been affected but scan state
  #at least once before
  SCAN_ONCE = false
  #Hp bars will only show when you are targetting a monster
  ONLY_ON_TARGET = false
 
  #Text to display if it's a boss monster, accepts same arguments
  BOSS_TEXT = "???"
  #The width of the boss hp bar
  BOSS_BAR_WIDTH = 66
  #The height of the boss hp bar
  BOSS_BAR_HEIGHT = 5
  #The width of the border around the boss hp bar
  BOSS_BORDER_WIDTH = 1
  #The height of the border around the boss hp bar
  BOSS_BORDER_HEIGHT = 1
  #ID's of boss monsters in array format.
  BOSS_MONSTERS = []
end
#Customization ends here
 
class Sprite_Battler
  alias hpbar_update update
  alias hpbar_dispose dispose
  def update
    hpbar_update
    return unless @battler.is_a?(Game_Enemy)
    if @battler
      update_hp_bar
    end
  end
  def update_hp_bar
    boss = DTP_HP::BOSS_MONSTERS.include?(@battler.enemy_id)
    setup_bar if @hp_bar.nil?
    if @text_display.nil?
      @text_display = Sprite_Base.new(self.viewport)
      @text_display.bitmap = Bitmap.new(100,DTP_HP::TEXT_SIZE)
      @text_display.bitmap.font.size = DTP_HP::TEXT_SIZE
      @text_display.bitmap.font.name = DTP_HP::TEXT_FONT
      @text_display.x = @hp_bar.x + DTP_HP::TEXT_OFFSET_X
      @text_display.y = @hp_bar.y + DTP_HP::TEXT_OFFSET_Y
      @text_display.z = 105
    end
    determine_visible
    return unless @hp_bar.visible
    if @hp_bar.opacity != self.opacity
      @hp_bar.opacity = self.opacity
      @mp_bar.opacity = @hp_bar.opacity if DTP_HP::USE_MP_BAR
    end
    @hp_bar.bitmap.clear
    if !boss
      width = DTP_HP::BAR_WIDTH
      height = DTP_HP::BAR_HEIGHT
      bwidth = DTP_HP::BORDER_WIDTH
      bheight = DTP_HP::BORDER_HEIGHT
    else
      width = DTP_HP::BOSS_BAR_WIDTH
      height = DTP_HP::BOSS_BAR_HEIGHT
      bwidth = DTP_HP::BOSS_BORDER_WIDTH
      bheight = DTP_HP::BOSS_BORDER_HEIGHT
    end
    btotal = (bwidth + bheight) * 2
    rwidth = @hp_bar.bitmap.width
    rheight = @hp_bar.bitmap.height
    if !DTP_HP::CUSTOM_BAR && DTP_HP::USE_HP_BAR
      @hp_bar.bitmap.fill_rect(0,0,rwidth,rheight,DTP_HP::COLOR_BAR_BACK)
      @hp_bar.bitmap.fill_rect(bwidth,bheight,rwidth-bwidth*2,rheight-bheight*2,DTP_HP::COLOR_BORDER_2)
      @hp_bar.bitmap.fill_rect(bwidth*2,bheight*2,width,height,DTP_HP::COLOR_BORDER_1)
    end
    hp_width = @battler.hp_rate * width
    if DTP_HP::USE_HP_BAR
      @hp_bar.bitmap.gradient_fill_rect(bwidth*2,bheight*2,hp_width,height,DTP_HP::COLOR_BAR_1,DTP_HP::COLOR_BAR_2)
    end
    if DTP_HP::CUSTOM_BAR && DTP_HP::USE_HP_BAR
      border_bitmap = Bitmap.new("Graphics/System/Custom_HP.png")
      rect = Rect.new(0,0,border_bitmap.width,border_bitmap.height)
      @hp_bar.bitmap.blt(0,0,border_bitmap,rect)
    end
    if DTP_HP::USE_MP_BAR
      @mp_bar.bitmap.clear
      if !DTP_HP::CUSTOM_BAR
        @mp_bar.bitmap.fill_rect(0,0,rwidth,rheight,DTP_HP::COLOR_BAR_BACK)
        @mp_bar.bitmap.fill_rect(bwidth,bheight,rwidth-bwidth*2,rheight-bheight*2,DTP_HP::COLOR_BORDER_2)
        @mp_bar.bitmap.fill_rect(bwidth*2,bheight*2,width,height,DTP_HP::COLOR_BORDER_1)
      end
      mp_width = @battler.mp_rate * width
      @mp_bar.bitmap.gradient_fill_rect(bwidth*2,bheight*2,mp_width,height,DTP_HP::MP_COLOR_BAR_1,DTP_HP::MP_COLOR_BAR_2)
      if DTP_HP::CUSTOM_BAR
        border_bitmap = Bitmap.new("Graphics/System/Custom_HP.png")
        rect = Rect.new(0,0,border_bitmap.width,border_bitmap.height)
        @mp_bar.bitmap.blt(0,0,border_bitmap,rect)
      end
    end
    return unless DTP_HP::USE_TEXT
    @text_display.opacity = @hp_bar.opacity if @text_display.opacity != @hp_bar.opacity
    @text_display.bitmap.clear
    text = DTP_HP::TEXT_DISPLAY.clone
    text = DTP_HP::BOSS_TEXT.clone if DTP_HP::BOSS_MONSTERS.include?(@battler.enemy_id)
    text.gsub!(/chp/) {@battler.hp}
    text.gsub!(/mhp/) {@battler.mhp}
    text.gsub!(/php/) {(@battler.hp_rate * 100).to_i}
    @text_display.bitmap.draw_text(0,0,100,@text_display.height,text)
  end
  def setup_bar
    boss = DTP_HP::BOSS_MONSTERS.include?(@battler.enemy_id)
    @hp_bar = Sprite_Base.new(self.viewport)
    if !boss
      width = DTP_HP::BAR_WIDTH + DTP_HP::BORDER_WIDTH * 4
      height = DTP_HP::BAR_HEIGHT + DTP_HP::BORDER_HEIGHT * 4
    else
      width = DTP_HP::BOSS_BAR_WIDTH + DTP_HP::BOSS_BORDER_WIDTH * 4
      height = DTP_HP::BOSS_BAR_HEIGHT + DTP_HP::BOSS_BORDER_HEIGHT * 4
    end
    if DTP_HP::CUSTOM_BAR
      tempbmp = Bitmap.new("Graphics/System/Custom_HP.png")
      width = tempbmp.width
      height = tempbmp.height
    end
    @hp_bar.bitmap = Bitmap.new(width,height)
    @hp_bar.x = self.x - @hp_bar.width / 2 + DTP_HP::BAR_OFFSET_X
    @hp_bar.y = self.y + DTP_HP::BAR_OFFSET_Y - self.bitmap.height - @hp_bar.height
    @hp_bar.y = self.y + DTP_HP::BAR_OFFSET_Y unless DTP_HP::ABOVE_MONSTER
    @hp_bar.x = 0 if @hp_bar.x < 0
    @hp_bar.y = 0 if @hp_bar.y < 0
    @hp_bar.z = 104
    if DTP_HP::USE_MP_BAR
      @mp_bar = Sprite_Base.new(self.viewport)
      @mp_bar.bitmap = Bitmap.new(@hp_bar.width,@hp_bar.height)
      @mp_bar.x = @hp_bar.x + 6
      @mp_bar.y = @hp_bar.y + @mp_bar.height - 3
      @mp_bar.z = 103
    end
  end
  def determine_visible
    if !@battler.alive?
      @hp_bar.visible = false
      @mp_bar.visible = false if @mp_bar
      @text_display.visible = false
      if DTP_HP::SCAN_ONCE and DTP_HP::SCAN_STATE == 1
        $game_party.monster_scans[@battler.enemy_id] = true
      end
      return if !@battler.alive?
    end
    @hp_bar.visible = true
    if DTP_HP::SCAN_STATE != 0
      @hp_bar.visible = false
      @hp_bar.visible = true if @battler.state?(DTP_HP::SCAN_STATE)
      if DTP_HP::SCAN_ONCE
        @hp_bar.visible = true if $game_party.monster_scans[@battler.enemy_id] == true
        $game_party.monster_scans[@battler.enemy_id] = true if @hp_bar.visible
      end
    end
    if !DTP_HP::SPECIFIC_ACTOR.empty?
      @hp_bar.visible = false unless DTP_HP::SCAN_STATE != 0
      DTP_HP::SPECIFIC_ACTOR.each do |i|
        next unless $game_party.battle_members.include?($game_actors[i])
        @hp_bar.visible = true
      end
    end
    if DTP_HP::ONLY_ON_TARGET
      return unless SceneManager.scene.is_a?(Scene_Battle)
      return unless SceneManager.scene.enemy_window
      @hp_bar.visible = SceneManager.scene.target_window_index == @battler.index
      @hp_bar.visible = false if !SceneManager.scene.enemy_window.active
    end
    @text_display.visible = false if !@hp_bar.visible
    @text_display.visible = true if @hp_bar.visible
    @mp_bar.visible = @hp_bar.visible if DTP_HP::USE_MP_BAR
  end
  def dispose
    @hp_bar.dispose if @hp_bar
    @mp_bar.dispose if @mp_bar
    @text_display.dispose if @text_display
    hpbar_dispose
  end
end
 
class Scene_Battle
  attr_reader  :enemy_window
  def target_window_index
    begin
    @enemy_window.enemy.index
    rescue
      return -1
    end
  end
end
 
class Game_Party
  alias hp_bar_init initialize
  attr_accessor  :monster_scans
  def initialize
    hp_bar_init
    @monster_scans = []
  end
end