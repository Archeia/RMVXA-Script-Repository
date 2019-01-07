=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - PHONE MENU ENGINE v1.4
 by Estriole
 Usage Level: Medium
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Support          ╒═════════════════════════════════════════════════════════╛
 While I'm flattered and I'm glad that people have been sharing and asking
 support for scripts in other RPG Maker communities, I would like to ask that
 you please avoid posting my scripts outside of where I frequent because it
 would make finding support and fixing bugs difficult for both of you and me.
   
 If you're ever looking for support, I can be reached at the following:
 ╔═════════════════════════════════════════════╗
 ║       http://www.rpgmakervxace.net/         ║
 ╚═════════════════════════════════════════════╝
 pm me : Estriole.
  
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
    This is MENU ENGINE... like yanfly's menu engine where you can customize
 the menu command. this replace the default menu to menu which look like phone...
 with animated icon. you could link everything from calling scene, calling method,
 even calling common event... THIS IS NOT PHONE SCRIPT (but if you make the add on
 or link another people script this could transform to full phone script).
 
 if you don't want to use this as menu but as other like phone system.
 set the CALL_PHONE_MENU_WHEN_PRESSING_ESC to false. 
 you must call it with SceneManager.call(Scene_Phone) though...
 
 also best if combined with Tsukihime Scene Interpreter script... (if calling common event)
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 * Menu with animated icon
 * can have unlimited command
 * can set up requirement for that command to included in menu
 * can set up requirement for that command to enabled in menu (not enabled will be greyed)
 * call scene
 * call common event
 * call method inside Scene_Phone
 * can define custom method in Scene_Phone...
 * superclass for creating ADDON easier
 * support NEW JET MOUSE SCRIPT
 * support VLUE Simple Mouse + Addon Script
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.05.29     >     Initial Release
 v1.1 2013.06.01     > Rework the documentation a little bit to make it easier 
                     to understand. 
                     > Fix the demo for missing picture (to demonstrate call common event)
                     > Add msgbox rescue when the phone script is not correct
                     instead crashing the game. but it will also do the rescue
                     if the phone script is not exist.
                     > Add Actor selection ADDON - it's to replicate default menu.
                     when we enter skill command we select actor first before go
                     to Scene_Skill. then Scene_Skill will use the actor selected
                     as first view of that scene. this ADDON replicate that.
                     > ADDON Scene and Window superclass made. so developing
                     new ADDON is lots easier.
                     See the CREATING ADDONS for detail
 v1.2 2013.06.06     > Implement bold font. command easier to read and more noticeable...
                     > Improved ADDON superclass to support using actor background.
                     just define method def use_actor_background and make it return true.
 v1.3 2013.06.06     > Added jet mouse system patch (the newer mouse system not the old one)
                     here's the link: http://www.rpgmakervxace.net/topic/14756-mouse-system/
                     modify the phone addon superclass window to support jet mouse system.
                     if you want to do something when the index is changed by mouse movement.
                     define it in:  def when_mouse_change_index
 v1.4 2013.06.18     > modify jet mouse system patch to use aliasing instead so the patch
                     also work for VM simple mouse script. (they use the same update_mouse method)
                     working on the jet mouse system bugfix since no response from jet. almost complete.
                     PUT ALL MOUSE SCRIPT ABOVE THIS SCRIPT !!!!!!!!!!!!
                     > change the superclass for addons to support VLUE mouse script.
                     > automatically set default handler to the addon window :ok and :cancel handler 
                     if the addon writer forgot adding the handler in create_addon_window method.
                     > fix some disposed so not flooding the memory
                     
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 Should be compatible with most script...
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 0) first you must copy some images from demo
     - phone.png (required. but you could modify it if you want)
     - background.png (required. but you could replace it with yours)
 put the all the images inside Graphic/System/CellPhone/
 (if you don't change the setting in module ESTRIOLE)  

 1) Set up the command name. inside module ESTRIOLE::PHONE
 search ICON_TITLES. PUT all your menu name there.
 
 2) make the icon sized 35x 35 pixel for each command you add. name it the same
 as the command name... you should also create one named 'rescue_icon' 
 (so the project still not crash when you still don't have complete graphic for the command)

 put the all the images inside Graphic/System/CellPhone/
 (if you don't change the setting in module ESTRIOLE)
 
 3) if you want to add the condition for the command to included in the menu... 
 search PHONE_INCLUDE. read the comment above it
 you need to know some ruby scripts to able to use that feature though.
 
 3) if you want to add the condition for the command to enabled in the menu... 
 search PHONE_ENABLE. read the comment above it
 you need to know some ruby scripts to able to use that feature though.
 
 4) to set what the command do when selecting it. search PHONE_SCRIPT. 
 read the comment above it.
 
 5) in PHONE_SCRIPT. you could call common  event, call scene easily since i already
 provide the sample method to work with that feature. 
 
 
 ### CREATING ADDONS ###
 ## Warning... not for someone who don't understand scripts... sorry! ##
 
 The addon created using this method will blend INSIDE phone system if made correctly.
 (see for yourself)
 
 1) to create ADDONS first you must create the window.
 simply create your window like this:
 
 class Window_YourAddonsName < Window_PhoneAddonBase
 end
 
 then create these methods inside the class
 #------------------------------------------------------------------------------
 # REQUIRED
 #------------------------------------------------------------------------------ 
  def make_command_list
    #required. basically your command here
    #format:
    # @list = any Array/Hash Object
    #example:
    # @list = $game_party.members 
  end
  def command_name(index)
    #required. but if you're not using command_name in draw_item you can skip this. ex: only draw images.
    # this... how your command name accessed. if its normal array with string inside it
    # then just use @list[index]
    # but if the array has Object inside it. then you might want to call method
    # for that object which return strings. example: $game_party.members[index]
    # will return Game_Actor object. so you must call it's method .name to return the name.
    # by example above... @list = $game_party.members
    # so we can just write like this :
    # @list[index].name
  end
  def draw_item(index)
    #required.
    # how you want your command drawn... d
  end  
 #------------------------------------------------------------------------------
 # OPTIONAL
 #------------------------------------------------------------------------------ 
  def select_last
    #optional. if you have logic to select last item chosen
    # in mine i select $game_party.menu_actor.index or 0
    # select($game_party.menu_actor.index || 0)
  end
 another optional method is:
  def item_width
  def item_height
 to adjust the content size
 #=============================================================================#
 
 2) create your scene (yes it must separate scene with Scene_Phone to avoid conflict)
 simply create your scene like this:
 
 class Scene_YourAddonsName < Phone_AddonBase
 end
 
 then create these 2 methods inside the class
 #------------------------------------------------------------------------------
 # REQUIRED
 #------------------------------------------------------------------------------ 
  def create_addon_window
    #required
    # create your window which you created using above method here
    # use the @addon_window as a name.
    # set handler for :ok to method(:on_addon_ok)
    # example:
    # @addon_window = Window_PhoneActorSelect.new
    # @addon_window.set_handler(:ok,method(:on_addon_ok))
  end
  def on_addon_ok
    #required
    # basically this what happen when you press ok on command
    # example:
    # type = $game_party.phone_command
    # $game_party.menu_actor = @addon_window.current_data
    # case type
    # when "Skills"
    # call_scene(Scene_Skill)  
    # when "Equipment"
    # call_scene(Scene_Equip)        
    # when "Status"
    # call_scene(Scene_Status)        
    # when "Talk"
    # call_common_event(5)
    # end
    # above means:
    # first i set $game_party.menu_actor to @addon_window.current_data
    # then i check what the parameter that passed by phone command 
    # i choose before entering this scene (call_scene advanced method)
    # see number 3 below for detail.
    # if 'Skills' it will call Scene_Skill (which will use actor selected as first view)
    # same with equipment and status. it will call the scene. but when the
    # parameter is 'Talk' then it will call common event 5.
  end
 #=============================================================================#
 
 3) link the scene you made to available Phone command.
 simply call the scene using phone script. (you must create the command first of course)
 
 also... call_scene INSIDE Scene_Phone have advanced function.
 it's can pass on parameter to another scene by storing it in $game_party.phone_command
 format:
 call_scene(YOURSCENENAME,YOURPARAMETERHERE)
 
 example:
 "Skills" => "call_scene(YOURSCENENAME,'Skills')",
 "Equipment" => "call_scene(YOURSCENENAME,'Equipment')",
 above means...
 selecting "Skills" => call the scene and $game_party.phone_command = 'Skills'
 selecting "Equipment" => call the scene and $game_party.phone_command = 'Equipment'

 note: call_scene method inside the addon CLASS will only call the scene. no advanced function.
 
 note2: if you understand more scripting knowledge you can basically modify another method
 inside the class...
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
   
=end


$imported = {} if $imported.nil?
$imported["EST - PHONE MENU"] = true
=begin

=end

module ESTRIOLE
 module PHONE   
#===============================================================================
#
#                  CONFIGURATION SECTION
#
#===============================================================================
  #-----------------------------------------------------------------------------
  # PATH FOR IMAGES FILES FOR ICON, ETC.... better if you don't change it.
  # "CellPhone/" means you must put the image in:
  # Graphic/System/CellPhone/
  #-----------------------------------------------------------------------------
  FOLDER_PATH="CellPhone/"
  
  #-----------------------------------------------------------------------------
  # Put your phone menu command here. it's better to not have duplicate menu. 
  # Ex: ["Item","Skill","Item"]
  # since it will access the same icon, include, enable, and script. 
  # unless you really want it that way...
  # ICON TITLES is an array. it must start with [ and end with ]. and each
  # member of the array is separated with , (coma)
  #-----------------------------------------------------------------------------
  ICON_TITLES=["SMS","Calendar","Pictures","Camera",
               "Calc","Mob Data","Map","Weather",
               "Quest","Clock","Settings","E-Mail",
               "Call","Browser","Music","Web",
               "Power","Games","Notes","Almanac"]
  #-----------------------------------------------------------------------------
  # Above means the phone will have 20 command.
  # first command is "SMS", second "Calendar", third "Pictures", fourth "Camera"
  # etc....
  #-----------------------------------------------------------------------------
    
  #-----------------------------------------------------------------------------
  # Below is to set where the phone located. and the phone z level.
  #-----------------------------------------------------------------------------
  PHONE_X = 150
  PHONE_Y = 20
  PHONE_Z = 10
  
  #-----------------------------------------------------------------------------
  # if below set to true... When pressing escape in scene_map it will call 
  # scene_phone instead normal menu. if you want to change it in game... 
  # script call: $game_party.phone_menu_when_press_esc = false
  #-----------------------------------------------------------------------------
  CALL_PHONE_MENU_WHEN_PRESSING_ESC = false
  
  #-----------------------------------------------------------------------------
  # if using jet / vm mouse set this to true
  #-----------------------------------------------------------------------------
  USE_MOUSE = true
  
  #-----------------------------------------------------------------------------
  # change this to the name of image you want as phone background image
  # you could change it in game.
  # script call: $game_party.phone_bg = "imagename"
  #
  # the image must be put inside the folder for cellphone graphic.
  # by default: Graphic/System/CellPhone/
  #-----------------------------------------------------------------------------
  PHONE_BACKGROUND = "Background"
  
  #-----------------------------------------------------------------------------
  # if phone icon IMAGE didn't exist it will use this image name instead
  # when you develop the game sometimes you still don't have all the graphic.
  # so temporary you could still run the game by adding rescue image. all ICON image
  # that is not found will load rescue image.
  #-----------------------------------------------------------------------------
  RESCUE_IMG = "rescue_icon"
  
  #-----------------------------------------------------------------------------
  # if phone menu NEED condition to included. put in hash below. 
  # condition must be in STRING format!
  # any phone menu that not included in hash below will always enable
  # 
  # hash member format:
  # "COMMANDSTRING" => "CONDITIONSCRIPTINSTRING"
  # condition need to return true / false. you could use 'and', 'or', etc if you
  # have multiple condition
  # COMMANDSTRING IS CASE SENSITIVE!!
  #
  # PHONE_INCLUDE is a HASH. it must start with { and end with }. each member of
  # the hash separated with , (coma)
  #-----------------------------------------------------------------------------
  PHONE_INCLUDE={# DO NOT REMOVE THIS LINE. THIS IS THE START OF THE HASH
  "Calendar" => "$game_actors[1].name == 'Estriole'",
  "Pictures" => "$game_switches[1] == true and $game_system.save_disabled",
  "Almanac" => "$game_switches[1] == true",
  }# DO NOT REMOVE THIS LINE. THIS IS THE END OF THE HASH
  #-----------------------------------------------------------------------------
  # Above means... 
  # - command "Calendar" will only INCLUDED when actor 1 name is 'Estriole'
  # - command "Pictures" will only INCLUDED when switch 1 on and save disabled
  # - command "Almanac" will only INCLUDED when switch 1 on.
  #
  # all the command that not in the hash will ALWAYS included.
  # this function is used if you want to INCLUDE certain command only after
  # certain part of story.
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
  # if phone menu NEED condition to enabled. put in hash below.
  # condition must be in STRING format!
  # any phone menu that not included in hash below will always enable
  # 
  # hash member format:
  # "COMMANDSTRING" => "CONDITIONSCRIPTINSTRING"
  # condition need to return true / false. you could use 'and', 'or', etc if you
  # have multiple condition
  # COMMANDSTRING IS CASE SENSITIVE!!
  #
  # PHONE_ENABLE is a HASH. it must start with { and end with }. each member of
  # the hash separated with , (coma)
  #-----------------------------------------------------------------------------
  PHONE_ENABLE={# DO NOT REMOVE THIS LINE. THIS IS THE START OF THE HASH
  "Calendar" => "$game_switches[1] == true",
  "Camera"=> "!$game_system.save_disabled",
  }# DO NOT REMOVE THIS LINE. THIS IS THE END OF THE HASH
  #-----------------------------------------------------------------------------
  # Above means... 
  # - command "Calendar" IF included in menu. ONLY enabled
  # when switch 1 is on. else it will be disabled (greyed and cannot selected)
  # - command "Camera" IF included in menu. ONLU enabled when save is enabled.
  # else it will be disabled (greyed and cannot selected)
  #
  # all the command that not in the hash will ALWAYS enabled.
  # this function is used for example you want to disable save in certain places.
  # basically to prevent using that command.
  #-----------------------------------------------------------------------------
  
  #-----------------------------------------------------------------------------
  # put your script code you want to execute when you choose command.
  # that code must be in STRING format! 
  # that string will be evaled and executed. if string contain word
  # SceneManager.call or SceneManager.goto the phone img will automatically disposed
  #
  # hash member format:
  # "COMMANDSTRING" => "SCRIPTINSTRING",
  #
  # SCRIPTINSTRING is a valid rgss3 script or method name in scene_phone
  # COMMANDSTRING IS CASE SENSITIVE!! (must be exact same with what you input
  # in ICON_TITLES.
  #
  # to call scene you could use "call_scene(Scene_Name)"
  # to call common event you could use "call_common_event(id)"
  #
  # PHONE_SCRIPT is a HASH. it must start with { and end with }. each member of
  # the hash separated with , (coma)
  #-----------------------------------------------------------------------------
  PHONE_SCRIPT={# DO NOT REMOVE THIS LINE. THIS IS THE START OF THE HASH
  "SMS" => "call_common_event(1)",
  "Calendar" => "SceneManager.call(Scene_Equip)",
  "Pictures" => "pictures_feature",
  "Camera"=>"call_scene(Scene_Save)",
  }# DO NOT REMOVE THIS LINE. THIS IS THE END OF THE HASH
  #-----------------------------------------------------------------------------
  # Above means when chosen... 
  # - command "SMS" will call common event 1
  # - command "Calendar" will call Scene_Equip
  # - command "Pictures" will call pictures_feature method inside Scene_Phone or this module
  # - command "Camera" will call Scene_Save
  #-----------------------------------------------------------------------------

#===============================================================================
#
#                  CUSTOM METHOD SECTION
#
#===============================================================================
  #-----------------------------------------------------------------------------
  # you could also create your function in this module. it will included in scene
  # below is three example. some_random method, call_scene method and call_common_event method.
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # 1) random method. define here and it will included in scene. need scripting knowledge
  #    also you must assume this method executed inside scene_phone. so use variable
  #    which exist inside scene_phone.
  #----------------------------------------------------------------------------
  def pictures_feature
    $game_variables[2] += 1
    msgbox("entering pictures feature method. now variable 2 = #{$game_variables[2]}")
    @phone_command.activate
  end

  #-----------------------------------------------------------------------------
  # 2)call scene method.
  #-----------------------------------------------------------------------------
  def call_scene(scene,phone_command = nil)
    $game_party.phone_command = phone_command if phone_command
    SceneManager.call(scene)
  end

  #-----------------------------------------------------------------------------
  # 3)call common event method.
  #-----------------------------------------------------------------------------
    def call_common_event(id)
      if $imported["TH_SceneInterpreter"] == true
      @interpreter.setup($data_common_events[id].list)
      @phone_command.activate
      else
      dispose_phone_background
      @phone_command.dispose
      $game_temp.reserve_common_event(id)
      SceneManager.return
      end
    end
 #------------------------------------------------------------------------------
 # note: if not using tsukihime scene interpreter it will exit the phone scene
 # and execute common event in scene_map
 #------------------------------------------------------------------------------
 # if combined with tsukihime scene interpreter script it will run common
 # event directly in phone scene. but be warned. some certain event command will
 # break the common event. and will execute after exiting phone and become weird. 
 # since some show message after that event command will be deleted.
 # list of known common event commands that WORKS:
 #------------------------------------------------------------------------------
 # PAGE 1
 # 1) Message - all working Except scrolling text
 # 2) Game Progression(variable, switch, etc) - all working
 # 3) Flow Control (label, gotolabel, conditional) - all working
 # 4) Party - all working
 # 5) Actor - all working
 #------------------------------------------------------------------------------
 # PAGE 2
 # 1) Movement - NOT working (will break common event. execute after exit scene)
 # 2) Character - NOT working (same as above)
 # 3) Screen Effect - all working
 # 4) Timing - all working 
 # 5) Picture and Weather Effect - all working
 # 6) Music and Sound Effect - all working
 #------------------------------------------------------------------------------
 # PAGE 3
 # 1) Screen Processing - Work but end common event (better put at end of common event)
 # 2) System Config - all working
 # 3) Movie - all working
 # 4) Map - all working
 # 5) Battle - not working i think... since not in scene battle.
 # 6) Advanced - Script - work but some might have not working error or end common event
 #------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
############     put your CUSTOM method below    ###############################







################################################################################
 end #END MODULE PHONE
end #END MODULE ESTRIOLE

class Game_Temp
  attr_accessor :phone_last_icon
  attr_accessor :phone_last_page
end

class Game_Party < Game_Unit
  attr_accessor :phone_bg
  attr_accessor :phone_menu_when_press_esc
  attr_accessor :phone_command
  attr_accessor :stored_bg
  
  def phone_menu(page = 0)
    list = []
    for i in 0..ESTRIOLE::PHONE::ICON_TITLES.size-1
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if !ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]]
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]] && 
                                             eval(ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]])      
    end
    listpage = list[(0+page*16),16]                                       
    return listpage                                       
  end
  def full_phone_menu(page = 0)
    list = []
    for i in 0..ESTRIOLE::PHONE::ICON_TITLES.size-1
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if !ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]]
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]] && 
                                             eval(ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]])      
    end
    return list
  end
  def phone_page_max
    list = []
    for i in 0..ESTRIOLE::PHONE::ICON_TITLES.size-1
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if !ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]]
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]] && 
                                             eval(ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]])      
    end
    pagemax = list.size / 16
    return pagemax                                           
  end
  def full_phone_page_max
    list = []
    for i in 0..ESTRIOLE::PHONE::ICON_TITLES.size-1
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if !ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]]
      list.push(ESTRIOLE::PHONE::ICON_TITLES[i]) if ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]] && 
                                             eval(ESTRIOLE::PHONE::PHONE_INCLUDE[ESTRIOLE::PHONE::ICON_TITLES[i]])      
    end
    return pagemax                                           
  end
  def phone_bg
    @phone_bg = "background.png" if !@phone_bg
    return @phone_bg
  end
  def phone_menu_when_press_esc
    @phone_menu_when_press_esc = ESTRIOLE::PHONE::CALL_PHONE_MENU_WHEN_PRESSING_ESC if !@phone_menu_when_press_esc
    return @phone_menu_when_press_esc
  end

end#end game_party

class Scene_Phone < Scene_Base
  include ESTRIOLE::PHONE
  def start
    super
    @map = Spriteset_Map.new    
    create_phone_background
    @page = 0
    @page = $game_temp.phone_last_page if $game_temp.phone_last_page
    create_icons
  end
      
  def create_phone_background
    @phone = Sprite.new
    @phone.bitmap = Cache.system(FOLDER_PATH+"phone.png")
    @phone.x=PHONE_X
    @phone.y=PHONE_Y
    @phone.z=PHONE_Z
    @background = Sprite.new
    @background.bitmap = Cache.system(FOLDER_PATH+$game_party.phone_bg)
    @background.x=PHONE_X+38
    @background.y=PHONE_Y+78
    @background.z=PHONE_Z+10
  end
  def dispose_phone_background
    @phone.bitmap.dispose if @phone
    @phone=nil
    @background.bitmap.dispose if @background
    @background=nil
  end

  def redraw_phone_command
    @phone_command.dispose
    create_icons
    @phone_need_redraw = false
  end
  
  def update
    super
    $game_map.update
    @map.update
    update_input
    redraw_phone_command if @phone_need_redraw
  end
  
  def update_input
    if Input.trigger?(:B)
      return @phone_command.activate if $imported["TH_SceneInterpreter"] == true && @interpreter.running?
      Sound.play_cancel      
      dispose_phone_background
      @map.dispose
      $game_temp.phone_last_icon = nil
      $game_temp.phone_last_page = nil
      return_scene
    end
  end

  def terminate
    dispose_phone_background
    @phone_command.dispose
    dispose_all_windows
    dispose_main_viewport
    @map.dispose
  end
  
  def create_icons
    wx= @background.x
    wy= @background.y
    ww= @background.width
    wh= @background.height
    @phone_command = Window_PhoneCommand.new(wx,wy,ww,wh,@page)
    @phone_command.set_handler(:ok,method(:on_phone_menu_ok))
    @phone_command.set_handler(:cancel,method(:return_scene))
    @phone_command.select($game_temp.phone_last_icon) if $game_temp.phone_last_icon    
  end
  
  def wait_for_interpreter    
  update
  end
  
  def on_phone_menu_ok
    $game_temp.phone_last_icon = @phone_command.index
    $game_temp.phone_last_page = @page = @phone_command.page
    chk = eval(PHONE_SCRIPT[@phone_command.current_data]) rescue nil if PHONE_SCRIPT[@phone_command.current_data]
    msgbox("this command script error OR this command didn't have script") if chk == nil
    @phone_command.activate if !PHONE_SCRIPT[@phone_command.current_data]
    if $imported["TH_SceneInterpreter"] == true
    wait_for_interpreter while @interpreter.running?
    @phone_need_redraw = true
    @phone_command.need_redraw = true
    end
  end
      
end#end scene_phone

class Game_Interpreter
  attr_accessor :params
end #end game_interpreter

class Scene_Base
  def interpreter
    @interpreter
  end
end# end scene_base

class Window_PhoneCommand < Window_Command
  attr_accessor :need_redraw
  attr_reader :page
  include ESTRIOLE::PHONE
  def initialize(dx,dy,dw,dh,page)
    @height = dh
    @width = dw
    @dx = dx
    @dy = dy
    @page = page
    super(dx,dy)
    self.opacity = 0
    self.z = PHONE_Z+30
    create_phone_icons 
  end
  
  def create_phone_icons(dispose = false)
    dispose_phone_icons if dispose
    @icons = {}
    @icons_posx = {}
    @icons_posy = {}
    for i in 0..$game_party.phone_menu(@page).size-1
      @icons[i] = Sprite.new
      @icons[i].bitmap = Cache.system(FOLDER_PATH+$game_party.phone_menu(@page)[i]+".png") rescue Cache.system(FOLDER_PATH+"#{RESCUE_IMG}.png")
      @icons[i].x = @dx + item_rect(i).x + standard_padding
      @icons[i].y = @dy + item_rect(i).y + standard_padding
      @icons[i].z = PHONE_Z+31
      @icons_posx[i] = @icons[i].x
      @icons_posy[i] = @icons[i].y
      @icons[i].color = Color.new(0, 0, 0, 100) if !command_enabled?(i)
      @icons[i].color = Color.new(0, 0, 0, 0) if command_enabled?(i)
    end
    @move_icon = 0    
  end
  def update
    super
    update_icon_animation if self.active == true
  end
  def dispose
    super
    dispose_phone_icons
  end
  def dispose_phone_icons
    for i in 0..@icons.size-1
      @icons[i].bitmap.dispose if @icons[i] && @icons[i].bitmap
      @icons[i].dispose if @icons[i]
      @icons[i]=nil
    end    
  end
  def update_icon_animation
    if @need_redraw == true
    for i in 0..@icons.size-1
      @icons[i].color = Color.new(0, 0, 0, 100) if !command_enabled?(i)
      @icons[i].color = Color.new(0, 0, 0, 0) if command_enabled?(i) && @icons[i]
    end    
    @need_redraw = false
    end
    return if !@icons[@index]
    @icons[@index].y=@icons[@index].y-1 if(@move_icon>=0&&@move_icon<=7)
    @icons[@index].y=@icons[@index].y+1 if(@move_icon>=8&&@move_icon<=15)
    @move_icon += 1
    @move_icon=0 if @move_icon > 15
  end
  def reset_icon_pos
    i = 0
    @icons.each do |icon|
      @icons[i].x = @icons_posx[i]
      @icons[i].y = @icons_posy[i]
      i += 1
    end
    @move_icon = 0
  end
  alias est_phone_process_cursor_move process_cursor_move
  def process_cursor_move
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?      
    est_phone_process_cursor_move
  end
  alias est_phone_process_handling process_handling
  def process_handling
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?      
    est_phone_process_handling
  end

#jet and vm mouse addon. but to change page still need use arrow keys....  
  alias est_jet_vm_update_mouse update_mouse rescue nil
  def update_mouse
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?          
    orig_index = @index
    est_jet_vm_update_mouse
    reset_icon_pos if @icons && @index != orig_index
  end
  
  def cursor_left(wrap = false)
    old_page = @page
    chk_index = @index
    chk_page = true if (chk_index % 16) ==0 && @page != 0
    @page -= 1 if (chk_index % 16) ==0 && @page != 0
    super(wrap = false)
    reset_icon_pos
    make_command_list if old_page !=@page
    refresh if old_page !=@page
    create_phone_icons(true) if old_page !=@page
    return unless chk_page
    select(15)
  end
  def cursor_right(wrap = false)
    old_page = @page
    chk_index = @index
    chk_page = true if (chk_index % 16) == 15 && @page != $game_party.phone_page_max
    @page += 1 if (chk_index % 16) == 15 && @page != $game_party.phone_page_max
    super(wrap = false)
    reset_icon_pos
    make_command_list if old_page !=@page
    refresh if old_page !=@page
    create_phone_icons(true) if old_page !=@page
    return unless chk_page
    select(0)
  end
  def cursor_up(wrap = false)
    old_page = @page
    chk_index = @index
    chk_page = true if (chk_index % 16) >= 0 && (chk_index % 16) <= 3 && @page != 0
    @page -= 1 if (chk_index % 16) >= 0 && (chk_index % 16) <= 3 && @page != 0
    super(wrap = false)
    reset_icon_pos
    make_command_list if old_page !=@page
    refresh if old_page !=@page
    create_phone_icons(true) if old_page !=@page
    return unless chk_page
    select(chk_index % 16 + 12) if chk_index % 16 >=0 && chk_index % 16 <= 3
  end
  def cursor_down(wrap = false)
    old_page = @page
    chk_index = @index
    chk_page = true if (chk_index % 16) >= 12 && (chk_index % 16) <= 15 && @page != $game_party.phone_page_max
    @page += 1 if (chk_index % 16) >= 12 && (chk_index % 16) <= 15 && @page != $game_party.phone_page_max
    super(wrap = false)
    reset_icon_pos
    make_command_list if old_page !=@page
    refresh if old_page !=@page
    create_phone_icons(true) if old_page !=@page
    return unless chk_page
    select([chk_index % 16 - 12,@list.size-1].min) if chk_index % 16 >=12 && chk_index % 16 <= 15
  end
  def make_command_list
    @list = $game_party.phone_menu(@page)
    @need_redraw = true
  end  
  def command_name(index); @list[index]; end  
  def item_width
    (window_width- 2 * standard_padding) / 4
  end
  def item_height
    (window_height - 2 * standard_padding) / 4
  end
  def window_width; return @width ;end
  def window_height; return @height;end  
  def col_max
    4
  end
  def spacing
    return 0
  end  
  def standard_padding
    return 4
  end  
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    bitmap = Cache.system(FOLDER_PATH+$game_party.phone_menu(@page)[index]+".png") rescue Cache.system(FOLDER_PATH+"#{RESCUE_IMG}.png")
    rect_text = item_rect(index)
    rect_text.y += bitmap.height - 14
    contents.font.size = 15
    contents.font.bold = true
    draw_text(rect_text, command_name(index), 1)
    reset_font_settings
    bitmap.dispose
  end
  def current_item_enabled?
    return command_enabled?(index) 
  end  
  def command_enabled?(index) 
    return true if !PHONE_ENABLE[@list[index]]
    return true if eval(PHONE_ENABLE[@list[index]])
    return false
  end
  def ok_enabled?
    handle?(:ok)
  end
  def call_ok_handler;call_handler(:ok);end    
end#end class window phone command
  
class Scene_Map < Scene_Base
  alias est_phone_menu_call_menu call_menu
  def call_menu
    if $game_party.phone_menu_when_press_esc
      Sound.play_ok
      SceneManager.call(Scene_Phone)
    else
      est_phone_menu_call_menu
    end
  end
end #end scene_map
class Game_Interpreter
  alias est_phone_menu_command_351 command_351
  def command_351
    if $game_party.phone_menu_when_press_esc
      return if $game_party.in_battle
      SceneManager.call(Scene_Phone)
      Fiber.yield
    else
      est_phone_menu_command_351
    end
  end
end #end class game interpreter

#### SUPERCLASS FOR PHONE ADDON ################################################
class Phone_AddonBase < Scene_Base
  def start
    super
    @map = Spriteset_Map.new
    set_actor_background
    create_phone_background
    create_addon_window
    set_addon_window_ok_handler if !@addon_window.handler[:ok]
    set_addon_window_cancel_handler if !@addon_window.handler[:cancel]
  end
  def update
    super
    $game_map.update
    @map.update
    update_input
  end
  def use_actor_background
    false
  end
  def set_actor_background
    return if !use_actor_background
    $game_party.stored_bg = $game_party.phone_bg
    $game_party.phone_bg = "Actor_#{$game_party.menu_actor.id}" rescue $game_party.stored_bg    
  end  
  def wait_for_interpreter    
  update
  end  
  def create_phone_background
    @phone = Sprite.new
    @phone.bitmap = Cache.system(ESTRIOLE::PHONE::FOLDER_PATH+"phone.png")
    @phone.x=ESTRIOLE::PHONE::PHONE_X
    @phone.y=ESTRIOLE::PHONE::PHONE_Y
    @phone.z=ESTRIOLE::PHONE::PHONE_Z
    @background = Sprite.new
    @background.bitmap = Cache.system(ESTRIOLE::PHONE::FOLDER_PATH+$game_party.phone_bg) rescue rescue_background
    @background.x=ESTRIOLE::PHONE::PHONE_X+38
    @background.y=ESTRIOLE::PHONE::PHONE_Y+78
    @background.z=ESTRIOLE::PHONE::PHONE_Z+10
  end
  def rescue_background
    Cache.system(ESTRIOLE::PHONE::FOLDER_PATH+$game_party.stored_bg) 
  end
  def dispose_phone_background
    @phone.bitmap.dispose if @phone
    @phone=nil
    @background.bitmap.dispose if @background
    @background=nil
  end
  def update_input
    if Input.trigger?(:B)
      return @addon_window.activate if $imported["TH_SceneInterpreter"] == true && @interpreter.running?
      Sound.play_cancel      
      dispose_phone_background
      @map.dispose
      return_scene
    end
  end
  def terminate
    $game_party.phone_bg = $game_party.stored_bg if use_actor_background
    dispose_phone_background
    @addon_window.dispose
    dispose_all_windows
    dispose_main_viewport
    @map.dispose
  end
  def call_scene(scene)
    SceneManager.call(scene)
  end
  def call_common_event(id)
    if $imported["TH_SceneInterpreter"] == true
      @interpreter.setup($data_common_events[id].list)
      @addon_window.activate
    else
      dispose_phone_background
      @addon_window.dispose
      $game_temp.reserve_common_event(id)
      SceneManager.return
    end
  end 
  def recreate_background
    @background.bitmap.dispose if @background
    @background=nil
    @background = Sprite.new
    @background.bitmap = Cache.system(ESTRIOLE::PHONE::FOLDER_PATH+$game_party.phone_bg) rescue rescue_background
    @background.x=ESTRIOLE::PHONE::PHONE_X+38
    @background.y=ESTRIOLE::PHONE::PHONE_Y+78
    @background.z=ESTRIOLE::PHONE::PHONE_Z+10    
  end
  
  def create_addon_window
    @addon_window = Window_PhoneAddonBase.new
  end
  def set_addon_window_ok_handler
    @addon_window.set_handler(:ok,method(:on_addon_ok))
  end
  def set_addon_window_cancel_handler
    @addon_window.set_handler(:cancel,method(:return_scene))
  end
  def on_addon_ok
  end
end

class Window_PhoneAddonBase < Window_Command
  attr_reader :list
  attr_reader :handler
  def initialize
    dx = ESTRIOLE::PHONE::PHONE_X+38
    dy = ESTRIOLE::PHONE::PHONE_Y+78
    dw = 163
    dh = 230
    @window_width = dw
    @window_height = dh
    super(dx,dy)
    self.opacity = 0
    select_last
  end  
  def window_width; return @window_width ;end
  def window_height; return @window_height ;end
  def current_item_enabled?; true; end
  def command_enabled?(index); true; end
  def ok_enabled?; true; end  
  def call_ok_handler;call_handler(:ok);end    
  alias est_phone_process_cursor_move process_cursor_move
  def process_cursor_move
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?      
    est_phone_process_cursor_move
  end
  alias est_phone_process_handling process_handling
  def process_handling
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?      
    est_phone_process_handling
  end
  def select_last
    select(0)
  end
  
  #jet / vm mouse system patch
  alias est_jet_vm_update_mouse update_mouse rescue nil
  def update_mouse
    return if $imported["TH_SceneInterpreter"] == true && SceneManager.scene.interpreter.running?          
    orig_index = @index
    est_jet_vm_update_mouse
    when_mouse_change_index if @index != orig_index
  end
  
  def when_mouse_change_index
  end    
  def command_name(index)
  end
  def make_command_list
  end
  def draw_item(index)
  end
end
#### SUPERCLASS FOR PHONE ADDON ################################################