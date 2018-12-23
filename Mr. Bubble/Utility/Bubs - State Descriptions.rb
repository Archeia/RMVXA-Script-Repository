# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ State Descriptions                                    │ v1.0 │ (8/09/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script allows users to define state description text within 
# Noteboxes. This script is a developer's script and does nothing by 
# itself.
#
# I plan on using this with other scripts I plan to make, but other
# scripters may use it as well.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (8/09/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetag is for States only:
#
# <description>
# string
# string
# <description>
#   This tag defines the state's description where string can be any text.
#   Description text is generally displayed in the help window.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsStateDescriptions"] = true

#==========================================================================
# ++ This script contains no customization module ++
#==========================================================================


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    STATE_DESCRIPTION_START = /<DESCRIPTION>/i
    STATE_DESCRIPTION_END = /<\/DESCRIPTION>/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_state_desc load_database; end
  def self.load_database
    load_database_bubs_state_desc # alias
    load_notetags_bubs_state_desc
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_state_desc
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_state_desc
    for obj in $data_states
      next if obj.nil?
      obj.load_notetags_bubs_state_desc
    end # for obj
  end # def
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_state_desc
  #--------------------------------------------------------------------------
  def load_notetags_bubs_state_desc
    @description = ""

    description_tag = false
    
    self.note.each_line { |line|
      case line
      when Bubs::Regexp::STATE_DESCRIPTION_START
        description_tag = true
      when Bubs::Regexp::STATE_DESCRIPTION_END
        description_tag = false
      else
        @description += line if description_tag
      end # case
    } # self.note.split
  end

end # class RPG::BaseItem