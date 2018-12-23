#==============================================================================
# Compatibility Patch :                                          v1.1 (2/1/12)
#   YSA Battle System: Classical ATB + KMS Generic Gauge
#==============================================================================
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below both YSA Battle System: Classical ATB and 
# KMS Generic Gauge in your script edtior.
#
# ATB Generic Gauge support for enemies is not yet implemented.
#==============================================================================

module Bubs
module GGPatch
  # * Gauge File Names
  #  Images must be placed in the "Graphics/System" folder of your project
  CATB_GAUGE_IMAGE  = "GaugeCATB"        # CATB Gauge
  CATB_CHARGE_IMAGE = "GaugeCATBCharge"  # CATB Charge Gauge

  # * Gauge Position Offset [x, y]
  CATB_OFFSET = [-23, -2]

  # * Gauge Length Adjustment
  CATB_LENGTH = -4 

  # * Gauge Slope
  #   Must be between -89 ~ 89 degrees
  CATB_SLOPE = 30
end
end

#==============================================================================
# ■ Window_BattleStatus
#==============================================================================

$imported = {} if $imported.nil?
$kms_imported = {} if $kms_imported.nil?

class Window_BattleStatus < Window_Selectable
  if $imported["YSA-CATB"] && $kms_imported["GenericGauge"]
  #--------------------------------------------------------------------------
  # overwrite: draw_actor_catb
  #--------------------------------------------------------------------------
  def draw_actor_catb(actor, dx, dy, width = 124)
    width -= 4
    dy -= 5
    draw_gauge(Bubs::GGPatch::CATB_GAUGE_IMAGE, 
              dx, dy, width, actor.catb_filled_rate, 
              Bubs::GGPatch::CATB_OFFSET, 
              Bubs::GGPatch::CATB_LENGTH, 
              Bubs::GGPatch::CATB_SLOPE)
    if actor.catb_ct_filled_rate > 0
      draw_gauge(Bubs::GGPatch::CATB_CHARGE_IMAGE, 
                dx, dy, width, actor.catb_ct_filled_rate, 
                Bubs::GGPatch::CATB_OFFSET, 
                Bubs::GGPatch::CATB_LENGTH, 
                Bubs::GGPatch::CATB_SLOPE)
    end
    change_color(system_color)
    draw_text(dx, dy, 30, line_height, YSA::CATB::ATB_PHRASE)
  end
  
  end # end $imported
end