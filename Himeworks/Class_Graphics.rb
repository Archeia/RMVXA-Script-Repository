=begin
#===============================================================================
 Title: Class Graphics
 Author: Hime
 Date: Aug 12, 2013
--------------------------------------------------------------------------------
 ** Change log
 Aug 12, 2013
   - Does not refresh graphics if actor is not finished initializing
 Aug 6, 2013
   - supports symbols in the filename now
 Jul 8, 2013
   - fixed bug where character wasn't refreshing when using the same char sheet
 Jun 21, 2013
   - fixed bug where player graphic doesn't change
   - initial release
--------------------------------------------------------------------------------  
 ** Terms of Use
 * Free to use in commercial/non-commercial projects
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description

 This script allows you to change an actor's face and character graphics
 depending on the actor's current class. Each class that your actor can change
 to can potentially have its own set of faces and character graphics.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Note-tag actors with
 
   <class face: class_id face_name face_index>
   <class char: class_id char_name char_index>
   
 Where
   `class_id` is the ID of the class you are assigning the face/char to
   `face_name` is the name of the face graphic to use
   `face_index is the index of the specific face on the face graphic
   `char_name` is the name of the character graphic to use
   `char_index` is the index of the specific character on the graphic
   
 You can setup note-tags for each class that the character can change to.
 For example, you might have the following setup:
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ClassGraphics"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Class_Graphics
    
    Face_Regex = /<class[-_ ]face: (\d+) (.+) (\d+)>/i
    Char_Regex = /<class[-_ ]char: (\d+) (.+) (\d+)>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Actor < BaseItem
    
    def class_face(class_id)
      return @class_faces[class_id] unless @class_faces.nil?
      load_notetag_class_graphics
      return @class_faces[class_id]
    end
    
    def class_character(class_id)
      return @class_characters[class_id] unless @class_characters.nil?
      load_notetag_class_graphics
      return @class_characters[class_id]
    end
    
    def load_notetag_class_graphics
      @class_faces = {}
      @class_characters = {}
      
      results = self.note.scan(TH::Class_Graphics::Face_Regex)
      results.each do |res|
        class_id = res[0].to_i
        face_name = res[1]
        face_index = res[2].to_i - 1
        @class_faces[class_id] = [face_name, face_index]
      end
      
      results = self.note.scan(TH::Class_Graphics::Char_Regex)
      results.each do |res|
        class_id = res[0].to_i
        char_name = res[1]
        char_index = res[2].to_i - 1
        @class_characters[class_id] = [char_name, char_index]
      end
    end
  end
end

class Game_Actor < Game_Battler  
  
  alias :th_class_graphics_initialize :initialize
  def initialize(actor_id)
    @initialized = false
    th_class_graphics_initialize(actor_id)
    @initialized = true
  end
  
  alias :th_class_graphics_refresh :refresh
  def refresh
    change_class_graphics
    th_class_graphics_refresh
  end

  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def change_class_graphics
    change_class_face
    change_class_character
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def change_class_face
    new_face = actor.class_face(@class_id)
    if new_face
      @face_name = new_face[0]
      @face_index = new_face[1]
    else
      @face_name = actor.face_name
      @face_index = actor.face_index
    end
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def change_class_character
    old_name = @character_name
    old_index = @character_index
    new_char = actor.class_character(class_id)
    if new_char
      @character_name = new_char[0]
      @character_index = new_char[1]
      
    else
      @character_name = actor.character_name
      @character_index = actor.character_index
    end
    $game_player.refresh if @initialized && (old_name != @character_name || old_index != @character_index)
  end
end