#==============================================================================
# Compatibility Patch :                                         v1.1 (8/07/12)
#   YEA System Options + KMS Generic Gauge
#==============================================================================
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below both YEA System Options and KMS Generic Gauge 
# in your script edtior.
#
# Due to the nature of both scripts, several methods in YEA System Options 
# were overwritten.
#
# All Generic Gauge images must be placed in the "Graphics/System" 
# folder of your project.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Updated for Generic Gauge version 2012/08/05. (8/07/2012)
# v1.0 : Initial release. (1/31/2012)
#==============================================================================

module Bubs
  module GenericGauge
  #--------------------------------------------------------------------------
  #   Window Tone Gauge Settings
  #--------------------------------------------------------------------------
  WINDOW_TONE_GAUGE = {  
    :window_red => "GaugeRed",    # Red Tone Gauge
    :window_grn => "GaugeGreen",  # Green Tone Gauge
    :window_blu => "GaugeBlue",   # Blue Tone Gauge
    
    # The following settings affect all Window Tone generic gauges
    :offset => [-23, -2],  # Gauge Position Offset [x, y]
    :length => -4,         # Gauge Length Adjustment
    :slope  => 30,         # Gauge Slope; Must be between -89 ~ 89 degrees
    
  } # <-- Do not delete!
  
  #--------------------------------------------------------------------------
  #   Volume Gauge Settings
  #--------------------------------------------------------------------------
  VOLUME_GAUGE = {
    :volume_bgm => "GaugeBGM",  # BGM Gauge
    :volume_bgs => "GaugeBGS",  # BGS Gauge
    :volume_sfx => "GaugeSFX",  # SFX Gauge
    
    # The following settings affect all Volume generic gauges
    :offset => [-23, -2],  # Gauge Position Offset [x, y]
    :length => -4,         # Gauge Length Adjustment
    :slope  => 30,         # Gauge Slope; Must be between -89 ~ 89 degrees
    
  } # <-- Do not delete!

  #--------------------------------------------------------------------------
  #   Custom Variable Gauge Settings
  #--------------------------------------------------------------------------
  CUSTOM_VARIABLE_GAUGE = {
    # Default gauge used if custom variable gauge is not defined
    :default_gauge => "GaugeWIN",
    :windowskin => "GaugeWIN",
    #------------------------------------------------------------------------
    # Variable index must match the same index that you defined in
    # CUSTOM_VARIABLES in YEA System Options. Otherwise, :default_gauge 
    # will be used.
    #------------------------------------------------------------------------
    1 => "GaugeMP", # Variable 1 Gauge
    2 => "GaugeTP", # Variable 2 Gauge
    
    
    # The following settings affect all Custom Variable generic gauges
    :offset => [-23, -2],  # Gauge Position Offset [x, y]
    :length => -4,         # Gauge Length Adjustment
    :slope  => 30,         # Gauge Slope; Must be between -89 ~ 89 degrees
  
  } # <-- Do not delete!
  
  end # module GenericGauge
end # module Bubs


$imported = {} if $imported.nil?
$kms_imported = {} if $kms_imported.nil?

if $imported["YEA-SystemOptions"] && $kms_imported["GenericGauge"]
#==============================================================================
# ++ Window_SystemOptions
#==============================================================================
class Window_SystemOptions < Window_Command
  #--------------------------------------------------------------------------
  # overwrite : draw_window_tone
  #--------------------------------------------------------------------------
  def draw_window_tone(rect, index, symbol)
    name = @list[index][:name]
    draw_text(0, rect.y, contents.width/2, line_height, name, 1)
    #---
    dx = contents.width / 2
    tone = $game_system.window_tone
    case symbol
    when :window_red
      rate = (tone.red + 255.0) / 510.0
      colour1 = Color.new(128, 0, 0)
      colour2 = Color.new(255, 0, 0)
      value = tone.red.to_i
    when :window_grn
      rate = (tone.green + 255.0) / 510.0
      colour1 = Color.new(0, 128, 0)
      colour2 = Color.new(0, 255, 0)
      value = tone.green.to_i
    when :window_blu
      rate = (tone.blue + 255.0) / 510.0
      colour1 = Color.new(0, 0, 128)
      colour2 = Color.new(0, 0, 255)
      value = tone.blue.to_i
    end
    #---
    
    image      = Bubs::GenericGauge::WINDOW_TONE_GAUGE[symbol]
    width      = contents.width - dx - 48
    offset     = Bubs::GenericGauge::WINDOW_TONE_GAUGE[:offset]
    len_offset = Bubs::GenericGauge::WINDOW_TONE_GAUGE[:length]
    slope      = Bubs::GenericGauge::WINDOW_TONE_GAUGE[:slope]

    draw_generic_gauge(image, dx, rect.y, width, rate, offset, len_offset, slope)
    #---
    draw_text(dx, rect.y, contents.width - dx - 48, line_height, value, 2)
  end
  
  #--------------------------------------------------------------------------
  # overwrite : draw_volume
  #--------------------------------------------------------------------------
  def draw_volume(rect, index, symbol)
    name = @list[index][:name]
    draw_text(0, rect.y, contents.width/2, line_height, name, 1)
    #---
    dx = contents.width / 2
    case symbol
    when :volume_bgm
      rate = $game_system.volume(:bgm)
    when :volume_bgs
      rate = $game_system.volume(:bgs)
    when :volume_sfx
      rate = $game_system.volume(:sfx)
    end
    colour1 = text_color(YEA::SYSTEM::COMMAND_VOCAB[symbol][1])
    colour2 = text_color(YEA::SYSTEM::COMMAND_VOCAB[symbol][2])
    value = sprintf("%d%%", rate)
    rate *= 0.01
    #---
    
    image      = Bubs::GenericGauge::VOLUME_GAUGE[symbol]
    width      = contents.width - dx - 48
    offset     = Bubs::GenericGauge::VOLUME_GAUGE[:offset]
    len_offset = Bubs::GenericGauge::VOLUME_GAUGE[:length]
    slope      = Bubs::GenericGauge::VOLUME_GAUGE[:slope]

    draw_generic_gauge(image, dx, rect.y, width, rate, offset, len_offset, slope)
    #---
    draw_text(dx, rect.y, contents.width - dx - 48, line_height, value, 2)
  end

  #--------------------------------------------------------------------------
  # overwrite : draw_custom_variable
  #--------------------------------------------------------------------------
  def draw_custom_variable(rect, index, ext)
    name = @list[index][:name]
    draw_text(0, rect.y, contents.width/2, line_height, name, 1)
    #---
    dx = contents.width / 2
    value = $game_variables[YEA::SYSTEM::CUSTOM_VARIABLES[ext][0]]
    colour1 = text_color(YEA::SYSTEM::CUSTOM_VARIABLES[ext][2])
    colour2 = text_color(YEA::SYSTEM::CUSTOM_VARIABLES[ext][3])
    minimum = YEA::SYSTEM::CUSTOM_VARIABLES[ext][4]
    maximum = YEA::SYSTEM::CUSTOM_VARIABLES[ext][5]
    rate = (value - minimum).to_f / [(maximum - minimum).to_f, 0.01].max
    dx = contents.width/2
    #---
    var_index = YEA::SYSTEM::CUSTOM_VARIABLES[ext][0]
    
    if Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE.include?(var_index)
      image = Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE[var_index]
    else
      image = Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE[:default_gauge]
    end
    
    offset     = Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE[:offset]
    len_offset = Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE[:length]
    slope      = Bubs::GenericGauge::CUSTOM_VARIABLE_GAUGE[:slope]
    width      = contents.width - dx - 48
    draw_generic_gauge(image, dx, rect.y, width, rate, offset, len_offset, slope)
             
    #---
    draw_text(dx, rect.y, contents.width - dx - 48, line_height, value, 2)
  end

end # class Window_SystemOptions

end # $imported