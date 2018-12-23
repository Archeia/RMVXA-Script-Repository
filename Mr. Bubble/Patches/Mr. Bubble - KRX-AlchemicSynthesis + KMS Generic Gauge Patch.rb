$imported ||= {}
$kms_imported ||= {} 

module Bubs
  module GGPatch
    # * Gauge File Names
    #  Images must be placed in the "Graphics/System" folder of your project
    ALCHSYNTH_EXP_IMAGE = "GaugeHP"

    # * Gauge Position Offset [x, y]
    ALCHSYNTH_EXP_OFFSET = [-23, -2]

    # * Gauge Length Adjustment
    ALCHSYNTH_EXP_LENGTH = -40

    # * Gauge Slope
    #   Must be between -89 ~ 89 degrees
    ALCHSYNTH_EXP_SLOPE = 30
  end
end

if $imported['KRX-AlchemicSynthesis'] && $kms_imported["GenericGauge"]
class Window_FinalItem < Window_SynthesisProp
  
  def draw_gauge(x, y, width, rate, color1, color2)
    file = Bubs::GGPatch::ALCHSYNTH_EXP_IMAGE
    offset = Bubs::GGPatch::ALCHSYNTH_EXP_OFFSET
    len_offset = Bubs::GGPatch::ALCHSYNTH_EXP_LENGTH
    slope = Bubs::GGPatch::ALCHSYNTH_EXP_SLOPE
    super(file, x, y, width, rate, offset, len_offset, slope)
  end
  
end 
end # if $imported