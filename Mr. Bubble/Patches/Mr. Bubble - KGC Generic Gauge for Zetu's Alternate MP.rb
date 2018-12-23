# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# KGC Generic Gauge for Zetu's Alternate MP X
# v1.0
# By Mr. Bubble
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Installation:
#   Install this script below Alternate MP X in your script editor.
# - - - -                                                               - - - -
# Requirements:
#   - Requires KGC_GenericGauge installed in your script editor.
#   - Requires Zetu's Alternate MP X installed in your script editor.
#   - Gauge images must follow the designated format for KGC Generic Gauge
#   - Gauge images must be place in the .\Graphics\System folder.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This script aliases class Window_Base#draw_actor_ampx_gauge in AMPX.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

module Bubs
module AMPX_GG
  
  # Enable/Disable AMPX + KGC_GG
  #   true  : Enable use of Generic Gauges for AMPX
  #   false : Disable use of Generic Gauges for AMPX
  USE_AMPX_GG = true
  
  # AMPX Generic Gauge Settings  
  AMPX_GG_SETTINGS = {
  
  :mana     => ["GaugeMana",  # Gauge file name
                         -4,  # Length Offset
                         30,  # Gauge Slope (Must be between -89 ~ 89 degrees)
                  [-23, -2]   # Gauge Position Offset [x,y]
                          ],  # Closing bracket and comma
                       
  :rage     => ["GaugeRage",  # Gauge file name
                         -4,  # Length Offset
                         30,  # Gauge Slope (Must be between -89 ~ 89 degrees)
                  [-23, -2]   # Gauge Position Offset [x,y]
                          ],  # Closing bracket and comma
                
  :energy => ["GaugeEnergy",  # Gauge file name
                         -4,  # Length Offset
                         30,  # Gauge Slope (Must be between -89 ~ 89 degrees)
                  [-23, -2]   # Gauge Position Offset [x,y]
                          ],  # Closing bracket and comma
                
  :focus   => ["GaugeFocus",  # Gauge file name
                         -4,  # Length Offset
                         30,  # Gauge Slope (Must be between -89 ~ 89 degrees)
                  [-23, -2]   # Gauge Position Offset [x,y]
                          ],  # Closing bracket and comma
                
  # - - - - - - - - You can add more settings in here - - - - - - - - - - - -
                
  
  
  
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  } # <-- Do not delete this.
  
  # AMPX Generic Gauge Default Settings
  #   Gauges will use the following default settings if the specific gauge
  #   settings in AMPX_GG_SETTINGS are not found.
  AMPX_DEFAULT_FILE = "GaugeMana"
  AMPX_LENGTH  = -4         # Length Adjustment
  AMPX_SLOPE   = 30         # Gauge Slope (Must be between -89 ~ 89 degrees)
  AMPX_OFFSET  = [-23, -2]  # Gauge Position Offset

end
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#  -  Do not edit anything below here unless you know what you're doing. - - -  
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

$zsys = {} if $zsys.nil?
$imported = {} if $imported == nil

if $zsys[:ampx] && $imported["GenericGauge"]

class Window_Base < Window
  include Bubs::AMPX_GG
  alias draw_actor_ampx_gauge_kgc_genericgauge draw_actor_ampx_gauge unless $@
  def draw_actor_ampx_gauge(actor, x, y, resource, width = 120)
    if USE_AMPX_GG && AMPX_GG_SETTINGS[resource]
      value = actor.ampx(resource)
      limit = [actor.maxampx(resource), 1].max
      file = AMPX_GG_SETTINGS[resource][0]
      len_offset = AMPX_GG_SETTINGS[resource][1]
      slope = AMPX_GG_SETTINGS[resource][2]
      offset = AMPX_GG_SETTINGS[resource][3]
    elsif USE_AMPX_GG && !AMPX_GG_SETTINGS[resource]
      value = actor.ampx(resource)
      limit = [actor.maxampx(resource), 1].max
      file = AMPX_DEFAULT_FILE
      len_offset = AMPX_LENGTH
      slope = AMPX_SLOPE
      offset = AMPX_OFFSET
    else
      return draw_actor_ampx_gauge_kgc_genericgauge(actor, x, y, resource, width = 120) # alias
    end
    return draw_gauge(file, x, y, width, value, limit, offset, len_offset, slope)
  end
end

end # if $zsys[:ampx] && $imported["GenericGauge"]