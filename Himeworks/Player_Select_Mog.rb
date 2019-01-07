=begin
#===============================================================================
 Title: Player Selection - Mog Edition
 Author: Hime
 Date: Aug 18, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 18, 2013
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
 
 This is a modified version of Mog Hunter's Character Select screen.
 It allows you to choose between different players.

--------------------------------------------------------------------------------
 ** Required
 
 Script: Player Manager
 (http://himeworks.com/2013/08/19/player-manager/)
 
 Graphics:
   Background
   Char_Layout01
   Char_Layout02
   Char_Status_Layout
   Number_Char
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Player Manager and above Main.
 Add the required resources into a folder called "Player_Select" in your
 Graphics/System folder

--------------------------------------------------------------------------------
 ** Usage 
 
 To enter the player select screen, make a script call
 
   call_player_select_scene
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PlayerSelectMog"] = true
#===============================================================================
# ** Rest of script
#===============================================================================

#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # ● draw_picture_number(x,y,value,file_name,align, space, frame_max ,frame_index)     
  #--------------------------------------------------------------------------
  # X - Posicao na horizontal
  # Y - Posicao na vertical
  # VALUE - Valor Numerico
  # FILE_NAME - Nome do arquivo
  # ALIGN - Centralizar 0 - Esquerda 1- Centro 2 - Direita  
  # SPACE - Espaco entre os numeros.
  # FRAME_MAX - Quantidade de quadros(Linhas) que a imagem vai ter. 
  # FRAME_INDEX - Definicao　do quadro a ser utilizado.
  #--------------------------------------------------------------------------  
  def draw_picture_number(x,y,value, file_name,align = 0, space = 0, frame_max = 1,frame_index = 0)     
      number_image = Cache.system(file_name) 
      frame_max = 1 if frame_max < 1
      frame_index = frame_max -1 if frame_index > frame_max -1
      align = 2 if align > 2
      cw = number_image.width / 10
      ch = number_image.height / frame_max
      h = ch * frame_index
      number = value.abs.to_s.split(//)
      case align
          when 0
             plus_x = (-cw + space) * number.size 
          when 1
             plus_x = (-cw + space) * number.size 
             plus_x /= 2 
          when 2  
             plus_x = 0
      end
      for r in 0..number.size - 1       
          number_abs = number[r].to_i 
          number_rect = Rect.new(cw * number_abs, h, cw, ch)
          self.contents.blt(plus_x + x + ((cw - space) * r), y , number_image, number_rect)        
      end
      number_image.dispose  
   end
  #--------------------------------------------------------------------------
  # ● draw_char_window_status  
  #--------------------------------------------------------------------------  
  def draw_char_window_status(x,y)
      image = Cache.system("Player_Select/Char_Status_Layout")    
      cw = image.width  
      ch = image.height 
      src_rect = Rect.new(0, 0, cw, ch)    
      self.contents.blt(x , y , image, src_rect)
      image.dispose
  end     
end  

#===============================================================================
# ■ RPG_FileTest 
#===============================================================================
module RPG_FileTest
  
  #--------------------------------------------------------------------------
  # ● RPG_FileTest.system_exist?
  #--------------------------------------------------------------------------
  def RPG_FileTest.system_exist?(filename)
      return Cache.system(filename) rescue return false
  end  
  
  #--------------------------------------------------------------------------
  # ● RPG_FileTest.picture_exist?
  #--------------------------------------------------------------------------
  def RPG_FileTest.picture_exist?(filename)
      return Cache.picture(filename) rescue return false
  end   
  
end

#==============================================================================
# ** Window_Character_Status
#==============================================================================
class Window_Character_Status < Window_Base
  attr_accessor :index
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
      super(0, 0, 400, 130)
      self.opacity = 0
      actor_id = []
      @index = actor
      for i in 1...$data_actors.size 
        actor_id.push($game_actors[i])
      end
      @actor = actor_id[actor -1]
      refresh
  end
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
      self.contents.clear
      self.contents.font.bold = true
      self.contents.font.italic = true
      draw_char_window_status(0, 6)    
      draw_actor_face(@actor, 0, 0)
      draw_actor_name(@actor, 140, -5)
      draw_actor_class(@actor, 60, 70)    
      draw_picture_number(155,20,@actor.mhp, "Player_Select/Number_char",1)   
      draw_picture_number(145,48,@actor.mmp, "Player_Select/Number_char",1)    
      draw_picture_number(228,28,@actor.atk, "Player_Select/Number_char",1)   
      draw_picture_number(297,28,@actor.def, "Player_Select/Number_char",1)  
      draw_picture_number(207,68,@actor.mat, "Player_Select/Number_char",1)  
      draw_picture_number(277,68,@actor.agi, "Player_Select/Number_char",1)  
  end
end


#==============================================================================
# ■ Scene Character Select
#==============================================================================
class Scene_Character_Select
  
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------
 def initialize
     setup 
     create_layout
     create_window_status
     create_char_image
     reset_position(0)      
 end
   
 #--------------------------------------------------------------------------
 # ● Setup
 #-------------------------------------------------------------------------- 
 def setup
     @char_index = 1
     @char_max = $data_actors.size - 1
     @pw_x = 300
     @aw_x = 200     
     @nw_x = 100         
 end  
 
 #--------------------------------------------------------------------------
 # ● Main
 #--------------------------------------------------------------------------          
 def main
     Graphics.transition
     execute_loop
     execute_dispose
 end   
 
 #--------------------------------------------------------------------------
 # ● Execute Loop
 #--------------------------------------------------------------------------           
 def execute_loop
     loop do
          Graphics.update
          Input.update
          update
          if SceneManager.scene != self
              break
          end
     end
 end 
  
 #--------------------------------------------------------------------------
 # ● create_background
 #--------------------------------------------------------------------------   
 def create_layout
      @background = Plane.new  
      @background.bitmap = Cache.system("Player_Select/Background") 
      @background.z = 0
      @layout_01 = Sprite.new  
      @layout_01.bitmap = Cache.system("Player_Select/Char_Layout01") 
      @layout_01.z = 10      
      @layout_02 = Sprite.new  
      @layout_02.bitmap = Cache.system("Player_Select/Char_Layout02") 
      @layout_02.blend_type = 1
      @layout_02.z = 1  
  end  
  
  #--------------------------------------------------------------------------
  # ● create_window_status
  #--------------------------------------------------------------------------  
  def create_window_status
      @window_status = []
      for i in 1...$data_actors.size 
          @window_status[i] = Window_Character_Status.new(i)
          @window_status[i].z = 7
      end 
      check_active_window
  end  
  
  #--------------------------------------------------------------------------
  # ● create_window_status
  #--------------------------------------------------------------------------  
  def create_char_image    
      @actor_picture = []
      actor_id = []
      for i in 1...$data_actors.size 
          actor_id.push($game_actors[i])
          actor = actor_id[i - 1] 
          @actor_picture[i] = Sprite.new
          file_name = "Character" + i.to_s
          file_name = "" unless RPG_FileTest.picture_exist?(file_name)
          @actor_picture[i].bitmap = Cache.picture(file_name)
      end   
      check_active_picture 
  end
  #--------------------------------------------------------------------------
  # ● check_active_window
  #--------------------------------------------------------------------------   
  def check_active_window
    for i in 1...$data_actors.size 
      @pw = @char_index - 1
      @pw = 1 if @pw > @char_max
      @pw_y = 32
      @pw = @char_max if @pw < 1
      @aw = @char_index 
      @aw_y = 160
      @nw = @char_index + 1
      @nw = 1 if @nw > @char_max
      @nw = @char_max if @nw < 1 
      @nw_y = 288
      case @window_status[i].index
          when @pw,@aw,@nw
            @window_status[i].visible = true
          else
            @window_status[i].visible = false
      end 
    end  
  end
    
  #--------------------------------------------------------------------------
  # ● check_active_picture  
  #--------------------------------------------------------------------------   
  def check_active_picture  
      for i in 1...$data_actors.size     
        case @window_status[i].index
            when @pw,@aw,@nw
                 @actor_picture[i].visible = true
                 @actor_picture[@pw].z = 4
                 @actor_picture[@aw].z = 6   
                 @actor_picture[@nw].z = 4      
                 @actor_picture[@pw].opacity = 120
                 @actor_picture[@aw].opacity = 255
                 @actor_picture[@nw].opacity = 120            
            else
                 @actor_picture[i].visible = false
        end     
      end
  end      
  
  #--------------------------------------------------------------------------
  # ● terminate
  #--------------------------------------------------------------------------
  def execute_dispose
      RPG::BGM.fade(2500)
      Graphics.fadeout(60)
      Graphics.wait(40)
      RPG::BGM.stop      
      for i in 1...$data_actors.size 
        @window_status[i].dispose
        @actor_picture[i].bitmap.dispose
        @actor_picture[i].dispose        
      end   
      @background.bitmap.dispose
      @background.dispose
      @layout_01.bitmap.dispose    
      @layout_01.dispose
      @layout_02.bitmap.dispose    
      @layout_02.dispose    
    end
    
  #--------------------------------------------------------------------------
  # ● update
  #--------------------------------------------------------------------------
  def update
      @background.ox += 1
      update_select
      update_slide_window
      update_slide_image
  end
  
  #--------------------------------------------------------------------------
  # ● update_slide_window
  #--------------------------------------------------------------------------  
  def update_slide_window
      @window_status[@aw].x += 1 if @window_status[@aw].x < 0
      @window_status[@nw].x -= 2 if @window_status[@nw].x > -30
      @window_status[@pw].x -= 2 if @window_status[@pw].x > -30
      slide_window_y(@pw,@pw_y)
      slide_window_y(@aw,@aw_y)
      slide_window_y(@nw,@nw_y)
  end 
  
  #--------------------------------------------------------------------------
  # ● update_slide_image   
  #--------------------------------------------------------------------------  
  def update_slide_image   
      slide_picture_x(@pw,@pw_x,15)
      slide_picture_x(@aw,@aw_x,5)
      slide_picture_x(@nw,@nw_x,15)
  end
  
  #--------------------------------------------------------------------------
  # ● slide_picture_x
  #--------------------------------------------------------------------------    
  def slide_picture_x(i,x_pos,speed)
      if @actor_picture[i].x < x_pos
         @actor_picture[i].x += speed
         @actor_picture[i].x = x_pos if @actor_picture[i].x > x_pos
      end  
      if @actor_picture[i].x > x_pos
         @actor_picture[i].x -= speed
         @actor_picture[i].x = x_pos if @actor_picture[i].x < x_pos        
       end             
  end     
  
  #--------------------------------------------------------------------------
  # ● slide_window_y
  #--------------------------------------------------------------------------    
  def slide_window_y(i,y_pos)
      if @window_status[i].y < y_pos
         @window_status[i].y += 15
         @window_status[i].y = y_pos if @window_status[i].y > y_pos
      end  
      if @window_status[i].y > y_pos
         @window_status[i].y -= 15
         @window_status[i].y = y_pos if @window_status[i].y < y_pos        
       end             
  end   
  
  #--------------------------------------------------------------------------
  # ● reset_position
  #--------------------------------------------------------------------------     
  def reset_position(diretion)
      check_active_window
      check_active_picture 
      case diretion
         when 0
            @window_status[@pw].y = -64
            @actor_picture[@pw].x = 100
         when 1  
            @window_status[@nw].y = 440
            @actor_picture[@nw].x = 400
      end        
  end  
  
  #--------------------------------------------------------------------------
  # ● update_select
  #--------------------------------------------------------------------------
  def update_select
    if Input.trigger?(Input::DOWN) or Input.trigger?(Input::LEFT)
      Sound.play_cursor
      @char_index += 1
      @char_index = 1 if @char_index > @char_max
      if @char_max < 3          
         reset_position(0)
      else  
         reset_position(1)
      end   
    elsif Input.trigger?(Input::UP) or Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @char_index -= 1
      @char_index = @char_max if @char_index < 1
      reset_position(0)
    elsif Input.trigger?(Input::C)     
      Sound.play_ok
      $game_party.add_actor(@char_index)
      SceneManager.return
    end
  end
end  

#===============================================================================
# Custom code
#===============================================================================

class Window_Character_Status < Window_Base
  def initialize(player)
    super(0, 0, 400, 130)
    self.opacity = 0
    @index = player.id
    @actor = player.party.leader
    refresh
  end
end

class Scene_Character_Select
  
  def setup
    @char_index = 1
    @char_max = $game_players.size
    @pw_x = 300
    @aw_x = 200     
    @nw_x = 100         
  end  
  
  def create_window_status
    @window_status = []
    $game_players.each_with_index do |player, i|
      @window_status[i+1] = Window_Character_Status.new(player)
      @window_status[i+1].z = 7
    end 
    check_active_window
  end  
  
  def check_active_picture
    for i in 1..$game_players.size
      case @window_status[i].index
        when @pw,@aw,@nw
          @actor_picture[i].visible = true
          @actor_picture[@pw].z = 4
          @actor_picture[@aw].z = 6   
          @actor_picture[@nw].z = 4      
          @actor_picture[@pw].opacity = 120
          @actor_picture[@aw].opacity = 255
          @actor_picture[@nw].opacity = 120            
        else
          @actor_picture[i].visible = false
      end     
    end
  end
  
  def check_active_window
    for i in 1..$game_players.size
      @pw = @char_index - 1
      @pw = 1 if @pw > @char_max
      @pw_y = 32
      @pw = @char_max if @pw < 1
      @aw = @char_index 
      @aw_y = 160
      @nw = @char_index + 1
      @nw = 1 if @nw > @char_max
      @nw = @char_max if @nw < 1 
      @nw_y = 288
      case @window_status[i].index
        when @pw,@aw,@nw
          @window_status[i].visible = true
        else
          @window_status[i].visible = false
      end
    end  
  end
  
  def reset_position(diretion)
    check_active_window
    check_active_picture 
    case diretion
      when 0
        @window_status[@pw].y = -64
        @actor_picture[@pw].x = 100
      when 1  
        @window_status[@nw].y = 440
        @actor_picture[@nw].x = 400
    end        
  end
  
  # create players, not actors
  def create_char_image    
    @actor_picture = []
    for i in 1..$game_players.size
      actor = $game_players[i].party.leader
      @actor_picture[i] = Sprite.new
      #file_name = "Character" + i.to_s
      
      file_name = "#{actor.face_name}-#{actor.face_index + 1}"
      file_name = "" unless RPG_FileTest.picture_exist?(file_name)
      @actor_picture[i].bitmap = Cache.picture(file_name)
    end   
    check_active_picture 
  end
  
  # change char select behavior to switch active player
  def update_select
    if Input.repeat?(Input::DOWN) or Input.repeat?(Input::LEFT)
      Sound.play_cursor
      @char_index += 1
      @char_index = 1 if @char_index > @char_max
      if @char_max < 3          
         reset_position(0)
      else  
         reset_position(1)
      end   
    elsif Input.repeat?(Input::UP) or Input.repeat?(Input::RIGHT)
      Sound.play_cursor
      @char_index -= 1
      @char_index = @char_max if @char_index < 1
      reset_position(0)
    elsif Input.trigger?(Input::C)     
      Sound.play_ok
      choose_character
      SceneManager.return
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      SceneManager.return
    end
  end
  
  def execute_dispose
    RPG::BGM.fade(2500)
    Graphics.fadeout(60)
    Graphics.wait(40)
    RPG::BGM.stop      
    for i in 1..$game_players.size 
      @window_status[i].dispose
      @actor_picture[i].bitmap.dispose
      @actor_picture[i].dispose        
    end   
    @background.bitmap.dispose
    @background.dispose
    @layout_01.bitmap.dispose    
    @layout_01.dispose
    @layout_02.bitmap.dispose    
    @layout_02.dispose    
  end
  
  def choose_character
    $game_players.switch_player(@char_index)
  end
end

class Game_Interpreter
  
  def call_player_select_scene
    SceneManager.call(Scene_Character_Select)
  end
end