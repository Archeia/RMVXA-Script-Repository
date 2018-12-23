#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                              *Hurt Faces*
#│                              Version: 1.2
#│                            Author: Euphoria
#│                            Date: 8/15/2014
#│                        Euphoria337.wordpress.com
#│                        
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: 1.1) Added option to change health percentage need to be "hurt" 
#│           1.2) Added Death Faces for face change when actors die(optional)
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For Commercial use contact 
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                          
#│■ Instructions: Go to the editable region and create new entries or edit the
#│                existing entries for each actor. The format should be:
#│
#│                Actor_ID => ["Hurt_Face_Name", Hurt_Face_Index],
#│
#│                Actor_ID = the actors ID number
#│                "Hurt_Face_Name" = the filename for the hurt face
#│                Hurt_Face_Index = the picture index (0-7) of the hurt face
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaHurtFaces"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Hurtface
    
    HURT_NUM   = 0.25 #The percentage of health you must be at or below to be 
                      #considered "hurt". Default = 0.25.
    
    HURT_FACES = { #DO NOT REMOVE
    #Actor ID => [Face Name When Hurt, Face Index When Hurt],
    1 => ["actor4", 3],
    2 => ["actor4", 2],
    3 => ["actor4", 7],
    4 => ["actor4", 1],
    #ADD HERE
    }#DO NOT REMOVE
    
    DEATH_FACES_ON = true
    
    DEATH_FACES = { #DO NOT REMOVE
    #Actor ID => [Face Name When Dead, Face Index When Dead],
    1 => ["actor4", 5],
    2 => ["actor4", 3],
    3 => ["actor4", 6],
    4 => ["actor4", 5],
    #ADD HERE
    }#DO NOT REMOVE
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ RPG::Actor
#└──────────────────────────────────────────────────────────────────────────────
class RPG::Actor < RPG::BaseItem
  attr_accessor :hurt_face
  attr_accessor :hurt_index
  attr_accessor :death_face
  attr_accessor :death_index
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Window_Base
#└──────────────────────────────────────────────────────────────────────────────
class Window_Base < Window
  
  #ALIAS - DRAW_ACTOR_FACE
  alias euphoria_hurtface_windowbase_drawactorface_16 draw_actor_face
  def draw_actor_face(actor, x, y, enabled = true)
    if Euphoria::Hurtface::DEATH_FACES_ON == true
      if actor.hp >= actor.mhp * Euphoria::Hurtface::HURT_NUM
        euphoria_hurtface_windowbase_drawactorface_16(actor, x, y, enabled = true)
      elsif actor.hp <= actor.mhp * Euphoria::Hurtface::HURT_NUM && actor.hp != 0
        draw_face(actor.hurt_face, actor.hurt_index, x, y, enabled)
      elsif actor.hp == 0
        draw_face(actor.death_face, actor.death_index, x, y, enabled)
      end
    else
      if actor.hp >= actor.mhp * Euphoria::Hurtface::HURT_NUM
        euphoria_hurtface_windowbase_drawactorface_16(actor, x, y, enabled = true)
      elsif actor.hp <= actor.mhp * Euphoria::Hurtface::HURT_NUM
        draw_face(actor.hurt_face, actor.hurt_index, x, y, enabled)
      end
    end
  end
  
  #ALIAS - HP_COLOR
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp <= actor.mhp * Euphoria::Hurtface::HURT_NUM
    return normal_color
  end
  
  #ALIAS - MP_COLOR
  def mp_color(actor)
    return crisis_color if actor.mp <= actor.mmp * Euphoria::Hurtface::HURT_NUM
    return normal_color
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Game_Actor
#└──────────────────────────────────────────────────────────────────────────────
class Game_Actor < Game_Battler
  attr_accessor :hurt_face
  attr_accessor :hurt_index
  attr_accessor :death_face
  attr_accessor :death_index
  
  
  #ALIAS - INIT_GRAPHICS
  alias euphoria_hurtface_gameactor_initgraphics_16 init_graphics
  def init_graphics
    euphoria_hurtface_gameactor_initgraphics_16
    @hurt_face = actor.hurt_face
    @hurt_index = actor.hurt_index
    @death_face = actor.death_face
    @death_index = actor.death_index
  end

  #NEW - HURT_FACE
  def hurt_face
    return Euphoria::Hurtface::HURT_FACES[actor.id][0] if Euphoria::Hurtface::HURT_FACES[actor.id]
    return face_name
  end
 
  #NEW - HURT_INDEX
  def hurt_index
    return Euphoria::Hurtface::HURT_FACES[actor.id][1] if Euphoria::Hurtface::HURT_FACES[actor.id]
    return face_index
  end
  
  #NEW - DEATH_FACE
  def death_face
    return Euphoria::Hurtface::DEATH_FACES[actor.id][0] if Euphoria::Hurtface::DEATH_FACES[actor.id]
    return face_name
  end
  
  #NEW - DEATH_INDEX
  def death_index
    return Euphoria::Hurtface::DEATH_FACES[actor.id][1] if Euphoria::Hurtface::DEATH_FACES[actor.id]
    return face_index
  end
    
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────  