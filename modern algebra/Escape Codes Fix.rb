#==============================================================================
#    Escape Codes Fix
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Date: April 23, 2012
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    By default, the game would crash if you neglected to put any code between
#   a \ and [ when using message codes. This fix makes the error less
#   catastrophic by simply printing a message in the console.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Simply paste this script into its own slot in the Script Editor, above 
#   Main but below Materials.
#==============================================================================

$imported ||= {}
unless $imported[:MA_EscapeCodesFix]
  #============================================================================
  # ** Window_Base
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - obtain_escape_code
  #============================================================================

  class Window_Base
    alias maatspf_obtainesccode_2jk3 obtain_escape_code
    def obtain_escape_code(*args, &block)
      code = maatspf_obtainesccode_2jk3(*args, &block)
      if code.nil?
        p "ERROR in #{self}:\nThere is no escaped code between \ and [ in your text."
        ""
      else
        code
      end
    end
  end
  $imported[:MA_EscapeCodesFix] = true
end