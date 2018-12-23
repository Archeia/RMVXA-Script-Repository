#==============================================================================
#    Composite Graphics / Visual Equipment + FenixFyrex's MultiFrame Sprites
#      Compatibility Patch
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: January 15, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    This script should be inserted into its own slot in the Script Editor, 
#   above Main but below the Composite Graphics script.
#
#    Note that in order for a multiframe sprite to show properly if composing
#   graphics, then every graphic in the composite must have the special code.
#==============================================================================

if $imported[:MA_CompositeGraphics]
  module Cache
    # alias macgve_make_unique_name
    class << self
      alias macgve_gencomp_mkuniqname_4df2 macgve_make_unique_name
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Make Unique Name
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.macgve_make_unique_name(cg_array = [], *args)
      result = macgve_gencomp_mkuniqname_4df2(cg_array, *args) # Call Original Method
      # If using FenixFyrex's Custom Sprites script
      if defined?(FyxA::CustomSprites::Patterns)
        FyxA::CustomSprites::Patterns.keys.each {|pattern|
          result += pattern if cg_array.all?{|cg| cg.filename.include?(pattern)} }
      end
      result
    end
  end
else
  p "Error: Composite Graphics + FenixFyrex's MultiFrame Sprites;\n
  the Compatibility Patch must be inserted below the Composite Graphics\n
  in the Script Editor. It must still be above Main though."
end