=begin
#==============================================================================
 Title: Party-based Graphics
 Author: Hime
 Date: Sep 15, 2012
--------------------------------------------------------------------------------
 ** Change log
 Sep 15
   - initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to setup event graphics based on party member
 formation. This is useful for setting up cut-scenes based on who is
 in your party.
 
--------------------------------------------------------------------------------
 ** Usage
 
 This script uses placeholder images.
 The name of the images follow this format:
 
    party#
    
 Where # is an integer that represents in the party. For example,
 
 "party1" would be the graphic of the first member in the party,
 "party2" would be the graphic of the second member in the party.
 
 Face images should be placed in the "Faces" folder, while character images
 should be placed in the "Characters" folder.
 
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_PartyGraphics"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module Party_Graphic
    
    # format of the character spritesheet name.
    Char_Regex = /.*party(\d+)/i
    Face_Regex = /.*party(\d+)/i
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================
class Game_Event
  
  alias :th_party_graphic_refresh :refresh
  def refresh
    th_party_graphic_refresh
    setup_page_graphic if @page
  end
   
  def setup_page_graphic
    res = Tsuki::Party_Graphic::Char_Regex.match(@page.graphic.character_name)
    if res
      index = res[1].to_i - 1
      if $game_party.members.size > index && $game_party.members[index]
        @character_name = $game_party.members[index].character_name 
        @character_index = $game_party.members[index].character_index
      end
    end
  end
end

class Game_Message
  
  def check_name
    res = Tsuki::Party_Graphic::Face_Regex.match(@orig_face_name)
    if res
      index = res[1].to_i - 1
      if $game_party.members.size > index && $game_party.members[index]
        @face_name = $game_party.members[index].face_name
        @face_index = $game_party.members[index].face_index
      end
    else
      @face_name = @orig_face_name
    end
  end
  
  def face_name=(name)
    @orig_face_name = name
    check_name
  end
  
  # this is actually redundant, but I don't want to change too much logic
  def face_index=(index)
    @face_index = index
    check_name
  end
end
    