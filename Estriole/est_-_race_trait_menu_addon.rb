$imported = {} if $imported.nil?
if $imported["YEA-StatusMenu"] == true


module YEA
  module STATUS
    BIOGRAPHY_NICKNAME_TEXT = "%s %s"   # How the nickname will appear.    
  end #end module status
end #end module yea

# AUTO INSERTING RACE BELOW CERTAIN SYMBOL
index, target = nil
for i in 0..YEA::STATUS::COMMANDS.size-1
 index = i if YEA::STATUS::COMMANDS[i] == :biography
end
target = index - YEA::STATUS::COMMANDS.size if index !=nil
YEA::STATUS::COMMANDS.insert(target,[:race, "Race Info"]) if target!=nil
YEA::STATUS::COMMANDS.insert(-1,[:race, "Race Info"])if target==nil
# END AUTO INSERTING

class Window_StatusCommand < Window_Command

  def make_command_list
    return unless @actor
    for command in YEA::STATUS::COMMANDS
      case command[0]
      #--- Default ---
      when :general, :parameters, :properties, :biography
        add_command(command[1], command[0])
      #--- Yanfly Engine Ace ---
      when :rename
        next unless $imported["YEA-RenameActor"]
        add_command(command[1], command[0], @actor.rename_allow?)
      when :retitle
        next unless $imported["YEA-RenameActor"]
        add_command(command[1], command[0], @actor.retitle_allow?)
      when :race
        next unless $imported["EST-RACE"]
        if $imported["EST-ARMY MANAGER"] == true
        next if $game_party.army_mode == 1
        end
        add_command(command[1], command[0])        
      #--- Custom Commands ---
      else
        process_custom_command(command)
      end
    end
    if !$game_temp.scene_status_index.nil?
      select($game_temp.scene_status_index)
      self.oy = $game_temp.scene_status_oy
    end
    $game_temp.scene_status_index = nil
    $game_temp.scene_status_oy = nil
  end

  
  
end#end class windowstatuscommand

class Window_StatusItem < Window_Base

  def draw_window_contents
    case @command_window.current_symbol
    when :general
      draw_actor_general
    when :parameters
      draw_parameter_graph
    when :properties
      draw_properties_list
    when :biography, :rename, :retitle
      draw_actor_biography
    when :race
      draw_race      
    else
      draw_custom
    end
  end

  def draw_race
#~     fmt = YEA::STATUS::BIOGRAPHY_NICKNAME_TEXT
#~     text = sprintf(fmt, @actor.name, @actor.nickname)
#~     contents.font.size = YEA::STATUS::BIOGRAPHY_NICKNAME_SIZE
#~     draw_text(0, 0, contents.width, line_height*2, text, 1)
    reset_font_settings
    race = @actor.get_race_name
    race = "Unknown" if !race
    racetext = "Race"
    width = (contents.width - 24)/3-24
    change_color(system_color)
    draw_text(24, 0, width, line_height*2, racetext, 0)
    change_color(normal_color)
    draw_text(178, 0, width, line_height*2, race, 0)

    change_color(system_color)
    text = "Racial Skills"
    draw_text(24, line_height, width, line_height*2, text, 0)
    
    draw_race_skill
    #draw_text_ex(24, line_height*2, @actor.description)
  end

  def draw_race_skill
    dx = 24
    dw = (contents.width - 24) / 3 - 24
    dy = 60
    abilitytext = @actor.get_ability_text
    abilitytext = ["None"] if !abilitytext
    
    for i in 0..abilitytext.size-1
    colour = Color.new(255, 0, 0, translucent_alpha/2)
    rect = Rect.new(dx+1, dy+1, dw-2, line_height-2)
    contents.fill_rect(rect, colour)
      if abilitytext[i] != "None"
      change_color(system_color)
      draw_text(dx+4, dy, dw-8, line_height, abilitytext[i][0], 0)
      change_color(normal_color)
      draw_text(dx+4+dw+8, dy, dw+300, line_height, abilitytext[i][1], 0)
      else
      nonetext = "None"
      change_color(system_color)
      draw_text(dx+4, dy, dw-8, line_height, nonetext, 0)    
      end
    dy += line_height-1
    end
    
  end

  
end #end class windowstatusitem


end #end if imported