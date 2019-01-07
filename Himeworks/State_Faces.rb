=begin
#===============================================================================
 Title: State Faces
 Author: Hime
 Date: Sep 6, 2015
--------------------------------------------------------------------------------
 ** Change log
 Sep 6, 2015
   - supports class note-tag
 Mar 30, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to setup "state faces" for each actor.
 
 A state face is just a face picture that will be used when a certain state has
 been applied.
 
 When the state is removed, the face picture also reverts to the original (or
 maybe another state face, depending on how many states are applied).
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag your actors or classes with
 
   <state face: id name index>
   
 Where
   `id` is the state ID that this face will apply to
   `name` is the name of the face, in the Graphics/Faces folder
   `index` is the index of the face.
   
 You will need to index the face sheet appropriately.
 
 0 1 2 3
 4 5 6 7
 
 If you are using one face per sheet, it is just 0.
 
 Note that state priority determines which face will be shown if multiple
 states are applied. States with higher priorities will be shown over states
 with lower priorities. In the case of a tie, the state that was first applied
 will be used.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StateFaces"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module State_Faces
    
    # state ID, face name, face index
    Regex = /<state face:\s*(\d+)\s*(\w+)\s*(\d+)>/i
  end
end

module RPG
  class BaseItem
    
    def state_faces
      return @state_faces unless @state_faces.nil?
      load_notetag_state_faces
      return @state_faces
    end
    
    def state_face_list
      return @state_face_list unless @state_face_list.nil?
      load_notetag_state_faces
      return @state_face_list
    end
    
    def load_notetag_state_faces
      @state_faces = {}
      res = self.note.scan(TH::State_Faces::Regex)      
      unless res.empty?
        res.each do |(state_id, face_name, face_index)|
          @state_faces[state_id.to_i] = [face_name, face_index.to_i]
        end
      end
      @state_face_list = @state_faces.keys
    end
  end
end

class Game_Actor < Game_Battler
  
  alias :th_state_faces_face_name :face_name
  def face_name
    @state_actor_face = nil
    @state_class_face = nil
    name = states.detect {|state| actor.state_face_list.include?(state.id)}
    if name
      @state_actor_face = name
      return actor.state_faces[@state_actor_face.id][0]
    else
      name = states.detect {|state| self.class.state_face_list.include?(state.id)}            
      if name
        @state_class_face = name
        return self.class.state_faces[@state_class_face.id][0]
      else        
        return th_state_faces_face_name
      end
    end
  end
  
  alias :th_state_faces_face_index :face_index
  def face_index
    if @state_actor_face
      return actor.state_faces[@state_actor_face.id][1]
    elsif @state_class_face
      return self.class.state_faces[@state_class_face.id][1]
    else
      return th_state_faces_face_index
    end
  end
end