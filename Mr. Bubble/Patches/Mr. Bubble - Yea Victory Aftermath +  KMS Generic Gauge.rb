#==============================================================================
# Compatibility Patch :                                         v1.1 (8/07/12)
#   YEA Victory Aftermath + KMS Generic Gauge
#==============================================================================
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below both YEA Victory Aftermath and KMS Generic Gauge 
# in your script edtior.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Updated for Generic Gauge version 2012/08/05. (8/07/2012)
# v1.0 : Initial release. (1/24/2012)
#==============================================================================

module Bubs
  module GenericGauge
  #--------------------------------------------------------------------------
  #   Gauge Filenames
  #--------------------------------------------------------------------------
  #  Images must be placed in the "Graphics/System" folder of your project
  VA_EXP_IMAGE = "GaugeEXP"       # Normal EXP Gauge Image
  VA_MAX_LEVEL_IMAGE = "GaugeEXP" # MAX Level EXP Gauge Image,
                                  # MAX Level filename is for when the actor 
                                  # is at MAX level
  #--------------------------------------------------------------------------
  #   Gauge Position Offset 
  #--------------------------------------------------------------------------
  VA_EXP_OFFSET = [-23, -2]  # [x, y]
  #--------------------------------------------------------------------------
  #   Gauge Length Adjustment
  #--------------------------------------------------------------------------
  VA_EXP_LENGTH = -4  # Victory Aftermath EXP
  #--------------------------------------------------------------------------
  #   Gauge Slope
  #--------------------------------------------------------------------------
  #   Must be between -89 ~ 89 degrees
  VA_EXP_SLOPE = 30  # Victory Aftermath EXP
  
  end # module GenericGauge
end # module Bubs


$imported ||= {}
$kms_imported ||= {}


if $imported["YEA-VictoryAftermath"] && $kms_imported["GenericGauge"]
#==============================================================================
# ++ Window_VictoryEXP_Front
#==============================================================================
class Window_VictoryEXP_Front < Window_VictoryEXP_Back
  #--------------------------------------------------------------------------
  # overwrite : draw_gauge
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    normal_image = Bubs::GenericGauge::VA_EXP_IMAGE
    max_image    = Bubs::GenericGauge::VA_MAX_LEVEL_IMAGE
    image        = rate >= 1.0 ? max_image : normal_image
    offset       = Bubs::GenericGauge::VA_EXP_OFFSET
    len_offset   = Bubs::GenericGauge::VA_EXP_LENGTH
    slope        = Bubs::GenericGauge::VA_EXP_SLOPE
    draw_generic_gauge(image, x, y, width, rate, offset, len_offset, slope)
  end
  
end # class Window_VictoryEXP_Front

end # end $imported