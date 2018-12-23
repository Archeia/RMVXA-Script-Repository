#==============================================================================
# Compatibility Patch :                                         v1.0 (6/29/12)
#   YEA Status Menu + KMS Generic Gauge
#==============================================================================
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below both YEA Status Menu and KMS Generic Gauge 
# in your script edtior.
#
#  !! IMPORTANT - READ THIS FIRST !!
#
# Due to a strange drawing abnormality that I have been unable to address 
# when trying to make YEA Status Menu compatibility with Generic Gauge images,
# this "patch" will have to do. It will not allow you to use custom gauges 
# within YEA Status Menu, but it will avoid the error that occurs when
# KMS Generic Gauge is also installed in the same project.
#==============================================================================

$imported = {} if $imported.nil?
$kms_imported = {} if $kms_imported.nil?

#==============================================================================
# ■ Window_StatusItem
#==============================================================================

if $imported["YEA-StatusMenu"] && $kms_imported["GenericGauge"]
class Window_StatusItem < Window_Base
  #--------------------------------------------------------------------------
  # * Draw Gauge
  #     rate   : Rate (full at 1.0)
  #     color1 : Left side gradation
  #     color2 : Right side gradation
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
end
end # if $imported["YEA-StatusMenu"]