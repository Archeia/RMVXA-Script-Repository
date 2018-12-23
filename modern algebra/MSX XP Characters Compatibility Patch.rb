#==============================================================================
#    Composite Graphics / Visual Equipment + MSX XP Characters on VX/Ace
#      Compatibility Patch
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: January 17, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    This script should be inserted into its own slot in the Script Editor, 
#   above Main but below the Composite Graphics script.
#
#    Note that in order for an XP sprite to show properly if composing 
#   graphics, then every graphic in the composite must have the $xp code.
#==============================================================================

if $imported[:MA_CompositeGraphics]
  module Cache
    # alias macgve_make_unique_name
    class << self
      alias macgve_msxxponacecomp_uniqname_5fr1 macgve_make_unique_name
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Make Unique Name
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.macgve_make_unique_name(cg_array = [], *args)
      # Call Original Method
      result = macgve_msxxponacecomp_uniqname_5fr1(cg_array, *args) 
      # Set If all graphics in composite have special $xp code
      result += "$xp" if cg_array.all?{|cg| cg.filename.include?("$xp") }
      result
    end
  end
else
  p "Error: Composite Graphics + MSX XP Characters on VX/VX Ace;\n
  the Compatibility Patch must be inserted below the Composite Graphics\n
  in the Script Editor. It must still be above Main though."
end