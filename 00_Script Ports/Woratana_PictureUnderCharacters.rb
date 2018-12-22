#===============================================================
# ● [VX] ◦ Pictures under Characters ◦ □
# * Show pictures under characters on map but above map tiles *
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Thaiware RPG Maker Community
# ◦ Released on: 22/02/2009
# ◦ Version: 1.0
#
# This works but not compatible with the other scripts
#
#--------------------------------------------------------------
# ◦ Update:
#--------------------------------------------------------------
# □ Version 1.0 (22/02/2009)
# - Unlimited numbers of picture under characters
#
#--------------------------------------------------------------
# ◦ Compatibility:
#--------------------------------------------------------------
# □ This script will rewrite 0 method(s):
#
#
# □ This script will alias 2 method(s):
#     Spriteset_Map.create_pictures
#     Sprite_Picture.update
#
# □ This script should work with most scripts
#
#--------------------------------------------------------------
# ◦ Installation:
#--------------------------------------------------------------
# 1) This script should be placed JUST AFTER ▼ Materials.
#
# □ Like this:
# ▼ Materials
# *Pictures under Characters
# ...
# ...
# ▼ Main Process
# Main
#
# 2) Setup this script in Setup Part below.
#
#--------------------------------------------------------------
# ◦ How to use:
#--------------------------------------------------------------
# □ Place this script and setup in the setup part.
#
#=================================================================

class Spriteset_Map

  #=================================================================
  # ++ Setup Part
  #-----------------------------------------------------------------
  FIRST_PICBELOW_ID = 15 # First ID of picture that will show below characters
  LAST_PICBELOW_ID = 20 # Last ID of picture that will show below characters

  #   For example, if you set FIRST to 10 and LAST to 15, picture ID 10-15
  # will show below characters on map.
  #=================================================================

  alias wora_picbelow_sprsetmap_crepic create_pictures

  #--------------------------------------------------------------------------
  # * Create Picture Sprite
  #--------------------------------------------------------------------------
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      case pic.number
      when FIRST_PICBELOW_ID..LAST_PICBELOW_ID
        #puts 'below'
        @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport1, pic)
      else
        @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      end
      @picture_sprites[pic.number].update
      ## Mithran's pic fix code ~Kread
      if pic.name == ""
        $game_map.screen.pictures.remove(pic.number)
        @picture_sprites[pic.number].dispose
        @picture_sprites[pic.number] = nil
      end
    end
  end
end

class Sprite_Picture < Sprite
  alias wora_picbelow_sprpic_upd update

  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update(*args)
    wora_picbelow_sprpic_upd(*args)
    ## Override's Mithran Picture Fix ~Kread
    if @picture.number.between?(Spriteset_Map::FIRST_PICBELOW_ID,
    Spriteset_Map::LAST_PICBELOW_ID)
      self.viewport = MA_FixPicture.send(:"spriteset_vp#{1}")
      self.z = 50
    end
  end
end