###--------------------------------------------------------------------------###
#  Ocarina script                                                              #
#  Version 2.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V.Alpha - 3.5.2012                                                          #
#   Wrote main script                                                          #
#  V1.0 - 3.11.2012                                                            #
#   Debbugged, polished, and documented script                                 #
#  V2.0 - 4.15.2012                                                            #
#   Added menu option for songs                                                #
#   Added 2 new script calls for the ocarina                                   #
#   Added note sprite sheet support                                            #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  New Scene entirely; should run with just about everything.                  #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is NOT plug and play and requires additional graphics and       #
#  several setting changes to work properly.  Please be sure you have          #
#  imported the required graphics before continuing.                           #
#                                                                              #
#  To use, place a script call in an event and use one of the following three  #
#  script calls:                                                               #
#    ocarina or play_oc - Calls the instrument input screen for the player.    #
#    song(x)            - Plays song "x" to teach the player a new song.       #
#    give_song(x)       - Gives the player song "x" without teaching it.       #
#                                                                              #
#  It is important to note that the player must have a song learned in order   #
#  for it to be played.  In other words, even if a player properly plays a     #
#  song, if the player has not learned the song yet it will not count as the   #
#  song played.                                                                #
#                                                                              #
###-----                                                                -----###
#      Menu Usage:                                                             #
#  A page has been added that shows a list of all songs, what songs are        #
#  unlocked, and the notes required to play the songs.  This list can be       #
#  pulled up using the commands "$scene = Scene_Songs.new(x)"  The "x" is not  #
#  required, and is the index in the menu which the cursor will return to.     #
#  In other words, by simply using "$scene = Scene_Songs.new" in a script      #
#  call, the song list will pop up and when exited will return the character   #
#  to the map, while you can use "$scene = Scene_Songs.new(7)" in the menu to  #
#  open the song list and then return to item 7 in the menu when exiting the   #
#  song list.                                                                  #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP          #  Do not edit                                              #
module OCARINA     #   these two lines                                         #
module SETTINGS    #  or this one either                                       #
#                                                                              #
###-----                                                                -----###
# The main game settings are below.  These include most of the sound effects   #
# and variable settings in the script.                                         #
#                                                                              #
# The ID number of the variable to be used by the script.  When a song is      #
# played, that song's value is sent to the variable.  When playing is          #
# cancelled, a value of 0 is returned.                                         #
VARIABLE = 2 # Default = 2                                                     #
#                                                                              #
# The settings for successful and failed song play sound effects.  When a song #
# is played successfully, the first sound is played.  When it is failed, the   #
# second is played.  Volume and pitch of both are controlled here.             #
PLAYED_SONG = "Decision2" # Default = "Decision2"                              #
PLAYED_WRONG = "Buzzer1"  # Default = "Buzzer1"                                #
PLAYED_VOLUME = 80        # Default = 80                                       #
PLAYED_PITCH = 100        # Default = 100                                      #
#                                                                              #
###-----                                                                -----###
# The sound settings are contained below.  These include the ocorina sound     #
# sound effect, beats, and certain text options.                               #
#                                                                              #
# The main name of the sound effect to be used by the script.  The script      #
# calls on 8 different sound effects defined by the name here with 8 different #
# suffixes.  By default, the lowest note in the octave should be named         #
# "Ocarina_MC".  The suffixes in order from lowest note to highest are:        #
#   _MC, _D, _E, _F, _G, _A, _B, _C.                                           #
# Name, volume, and pitch are defined here, though I don't know why you would  #
# need to change the pitch.                                                    #
OCARINA_SOUND = "Ocarina" # Default = "Ocarina"                                #
OCARINA_VOLUME = 100      # Default = 100                                      #
OCARINA_PITCH = 100       # Default = 100                                      #
#                                                                              #
# The number of beats used in a song.  Having more or less beats per song may  #
# cause bugs (it's effects have not been tested or calculated).  The player    #
# must play this number of notes for the script to continue.                   #
BEATS = 8 # Default = 8                                                        #
#                                                                              #
# The messages that display when you play or listen to a certain song.         #
PLAYED_MESSAGE = "You have played"   # Default = "You have played"             #
LEARNED_MESSAGE = "You have learned" # Default = "You have learned"            #
#                                                                              #
###-----                                                                -----###
# The song arrays are contained below.  This is the most difficult section of  #
# the settings are require a small amount of extra explaining to understand.   #
#                                                                              #
# This is the song array.  The song arrays can consist of as many "notes" as   #
# you have defined in the "BEATS" setting above, and any number of "rests".    #
# These notes and rests are defined here as numbers, from 0 to 8 where 0 is a  #
# rest and 1 through 8 are notes ranging from lowest to highest.  The rests do #
# not matter when the player is attempting to play a song and are not counted. #
# Rests only matter during playback as they rest for a single beat, or simply  #
# leave a period of silence.                                                   #
# To iterate:                                                                  #
#   0 = Rest, 1 = Middle C (_MC suffix sfx), 2 = D, 3 = E, etc.                #
# All songs must be in square brackets and must be followed by a comma (,) or  #
# you will get a syntax error.  The first song in the list has song ID 1 in    #
# order for the script to work properly, so don't worry about errors in that   #
# respect.  I've at least planned that far ahead.                              #
#                                                                              #
SONGS =[ # Do not edit this line.                                              #
                                                                               #
  [3, 0, 2, 3, 4, 3, 2, 1, 2], # This is song ID number 1                      #
  [5, 5, 0, 8, 0, 7, 0, 6, 5, 0, 4, 0, 5], # this song demonstrates rests      #
  [2, 5, 6, 2, 8, 0, 7, 6, 5], # and this is just a third song for pretties    #
                                                                               #
] # Leave this line alone.                                                     #
#                                                                              #
# This array contains song names.  The song names here are in the same order   #
# as the songs above, so order them accordingly.                               #
NAMES =[ # This line should not be touched.                                    #
                                                                               #
  "Mother Earth",   #  Kudos to you if you                                     #
  "Rigid Paradise", #   know the games any                                     #
  "Overature",      #    of these came from.                                   #
] # Don't touch this line.                                                     #
#                                                                              #
# This final array contains descriptions of the songs.  These display in the   #
# help box when the song is viewed from the menu.  Once again, they are in     #
# the same order as the songs above.                                           #
DESCS =[ # Don't edit this line....                                            #
                                                                               #
  "A song for new beginnings",                                                 #
  "A song that gives a particular feeling of a jiang-shi",                     #
  "A heroic sounding song you feel you've heard before",                       #
] # This line should not be touched.                                           #
#                                                                              #
# This is the text and description to be displayed in the menu for a song      #
# that has not been learned.                                                   #
NO_SONG = "???" # Default = "???"                                              #
NO_DESC = "This song has not been learned yet"                                 #
#                 Default = "This song has not been learned yet"               #
#                                                                              #
###-----                                                                -----###
# Graphical settings are contained below.  These are the clef that the notes   #
# go on as well as the notes themselves.                                       #
#                                                                              #
# The file for the clef and the X and Y offset of it from the middle of the    #
# screen.  Keep in mind that the dialogue box for songs displays just above    #
# the center of the screen, so you will need to move this image down.          #
STAFF_GFX = "Staff" # Default = "Staff"                                        #
STAFF_X = 0         # Default = 0                                              #
STAFF_Y = 100       # Default = 100                                            #
#                                                                              #
# The settings for the note graphics.  The X and Y settings are the location   #
# the first note assuming it is middle C from the upper left most corner of    #
# the image above.  All other note locations will be determined based on this  #
# one location.  Finally, "NOTE_STEET" determines if a sprite sheet is used.   #
# If this is set to true, the graphic file is considered a sprite sheet with   #
# a graphic for each note in it.  The notes are from middle C to high C from   #
# left to right.                                                               #
NOTE_GFX = "NoteSheet" # Default = "NoteSheet"                                 #
NOTE_X = 68            # Default = 68                                          #
NOTE_Y = 64            # Default = 64                                          #
NOTE_SHEET = true      # Default = true                                        #
#                                                                              #
# The X and Y offset of subsequent notes.  X offset defines the distance       #
# between each note played, while Y offset defines the locations of all keys   #
# played.                                                                      #
X_OFFSET = 40 # Default = 40                                                   #
Y_OFFSET = -8 # Default = -8                                                   #
#                                                                              #
end # SETTINGS   These lines are not for touching.                             #
end # OCARINA          Trust me, they bite.                                    #
end # CP                                                                       #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###

$imported = {} if $imported == nil
$imported["CP_OCARINA"] = true

##-----
## Makes stuff work for people who aren't me.
##-----
class Game_Interpreter
  def play_oc
    ocarina
  end
  
  def ocarina
    $scene = Scene_Ocarina.new(0)    ## Calls the scene.
    @wait_count = 1                  ## Gives time for the script to process.
  end

  def song(song)
    $scene = Scene_Ocarina.new(song, true)
    @wait_count = 1
  end
  
  def give_song(song)
    song -= 1
    $data_songs[song][0] = CP::OCARINA::SETTINGS::NAMES[song]
    $data_songs[song][1] = CP::OCARINA::SETTINGS::DESCS[song]
    $data_songs[song][2] = true
  end
end

##-----
## The message box that pops up.  Hidden by default.
##-----
class Window_Ocarina_Message < Window_Base
  def initialize
    super(144, 128, 256, 80)
    self.visible = false
  end
  
  def draw_song(song, learning = false)
    dialogue = CP::OCARINA::SETTINGS::PLAYED_MESSAGE  ## Picks a message here.
    dialogue = CP::OCARINA::SETTINGS::LEARNED_MESSAGE if learning
    name = CP::OCARINA::SETTINGS::NAMES[song]  ## Name of the song.
    wd = self.width
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, wd - 32, WLH, dialogue, 1)
    self.contents.font.color = normal_color
    self.contents.draw_text(0, 24, wd - 32, WLH, name, 1)
    self.visible = true  ## Makes itself seen.
  end
end

##-----
## The bread and butter of the script.
##-----
class Scene_Ocarina < Scene_Base
  def initialize(song, teach = false)
    @play_song = song -1  ## -1 here so it calls the proper song.
    @max_note = CP::OCARINA::SETTINGS::BEATS
    @note = teach ? @max_note : 0
    @play_notes = []
    @teach = teach
    @t_song = song - 1
    @taught = false
  end

  def start
    super
    create_menu_background
    @message_window = Window_Ocarina_Message.new
    create_clef
    note_sprite
  end
  
  def terminate
    super
    dispose_menu_background
    @message_window.dispose
    @clef_sprite.dispose
    @note_sprites.dispose
  end
  
  def update
    super
    if @teach     ## Several checks here for it to run properly.
      play_song if @note == @max_note
      update_note_input
      compare_songs if @note == @max_note
    else
      update_note_input
      compare_songs if @note == @max_note
      play_song if @note == @max_note
    end
  end
  
##-----
## Draws the clef for later use.
##-----
  def create_clef
    @clef_sprite = Sprite.new(@viewport1)
    @clef_sprite.bitmap = Cache.picture(CP::OCARINA::SETTINGS::STAFF_GFX)
    @clef_sprite.ox = @clef_sprite.width/2
    @clef_sprite.oy = @clef_sprite.height/2
    @clef_sprite.x = Graphics.width/2 + CP::OCARINA::SETTINGS::STAFF_X
    @clef_sprite.y = Graphics.height/2 + CP::OCARINA::SETTINGS::STAFF_Y
    @clef_sprite.z = 1
  end

##-----
## Misleading name.  Only makes the bitmap notes will be drawn on.
##-----
  def note_sprite
    @note_sprites = Sprite.new(@viewport1)
    @note_sprites.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    xo = CP::OCARINA::SETTINGS::NOTE_X + CP::OCARINA::SETTINGS::STAFF_X
    yo = CP::OCARINA::SETTINGS::NOTE_Y + CP::OCARINA::SETTINGS::STAFF_Y
    @first_note_x = Graphics.width/2 - @clef_sprite.width/2 + xo
    @first_note_y = Graphics.height/2 - @clef_sprite.height/2 + yo
    @note_sprites.z = 3
    unless @t_song == -1
      tn = @note
      @note = 0
      for i in 0...CP::OCARINA::SETTINGS::SONGS[@t_song].size
        note = CP::OCARINA::SETTINGS::SONGS[@t_song][i]
        unless note == 0
          add_note(note, true)
          @note += 1
        end
      end
      @note = tn
    end
  end

##-----
## Makes wait work.
##-----
  def update_basic
    Graphics.update
    Input.update
  end
  def wait(dur)
    for i in 0...dur
      update_basic
    end
  end
  
##-----
## Adds a note to the already drawn bitmap.
##-----
  def add_note(note, back = false)
    temp_note = Cache.picture(CP::OCARINA::SETTINGS::NOTE_GFX)
    nwi = temp_note.width
    nhe = temp_note.height
    if CP::OCARINA::SETTINGS::NOTE_SHEET
      rect = Rect.new(nwi / 8 * (note - 1), 0, nwi / 8, nhe)
    else
      rect = Rect.new(0, 0, nwi, nhe)
    end
    xa = CP::OCARINA::SETTINGS::X_OFFSET * @note
    ya = CP::OCARINA::SETTINGS::Y_OFFSET * (note - 1)
    xa -= rect.width/2
    ya -= rect.height/2
    xn = @first_note_x + xa
    yn = @first_note_y + ya
    unless back
      @note_sprites.bitmap.blt(xn, yn, temp_note, rect)
    else
      @note_sprites.bitmap.blt(xn, yn, temp_note, rect, 128)
    end
  end  

##-----
## Plays the sound effects of the instrument.
##-----
  def play_sound(note)
    se = CP::OCARINA::SETTINGS::OCARINA_SOUND
    sv = CP::OCARINA::SETTINGS::OCARINA_VOLUME
    sp = CP::OCARINA::SETTINGS::OCARINA_PITCH
    ss = "_MC" if note == 1
    ss = "_D" if note == 2
    ss = "_E" if note == 3
    ss = "_F" if note == 4
    ss = "_G" if note == 5
    ss = "_A" if note == 6
    ss = "_B" if note == 7
    ss = "_C" if note == 8
    note_se = RPG::SE.new(se + ss, sv, sp)
    note_se.play
  end

##-----
## The input section.  Probably could have made this easier.
##-----
  def update_note_input
    if Input.trigger?(Input::DOWN)
      note = 1
    elsif Input.trigger?(Input::LEFT)
      note = 2
    elsif Input.trigger?(Input::UP)
      note = 3
    elsif Input.trigger?(Input::RIGHT)
      note = 4
    elsif Input.trigger?(Input::C)
      note = 5
    elsif Input.trigger?(Input::B)
      note = 6
    elsif Input.trigger?(Input::X)
      note = 7
    elsif Input.trigger?(Input::Y)
      note = 8
    elsif Input.trigger?(Input::A) and @teach == false
      Sound.play_cancel
      quit
    end
    unless note == nil
      play_sound(note)
      add_note(note)
      @play_notes.push note
      @note += 1
    end
  end
  
  def quit
    variable = CP::OCARINA::SETTINGS::VARIABLE
    $game_variables[variable] = @play_song + 1
    ocarina_end
  end
  
  def ocarina_end
    $scene = Scene_Map.new
  end

##-----
## This plays the song if you input a correct song or if you are teaching
## a new song to the player.  Should be cleaned up later.
##-----
  def play_song
    wait(5)
    se = CP::OCARINA::SETTINGS::PLAYED_SONG
    se = CP::OCARINA::SETTINGS::PLAYED_WRONG if @play_song == -1
    sv = CP::OCARINA::SETTINGS::PLAYED_VOLUME
    sp = CP::OCARINA::SETTINGS::PLAYED_PITCH
    song_play = RPG::SE.new(se, sv, sp) unless se == nil
    song_play.play
    @message_window.draw_song(@play_song, @teach) unless @play_song == -1 or (@teach != @taught)
    wait(30)
    @note_sprites.dispose
    note_sprite
    @note = 0
    @play_notes = []
    return if @play_song == -1
    for i in 0...CP::OCARINA::SETTINGS::SONGS[@play_song].size
      note = CP::OCARINA::SETTINGS::SONGS[@play_song][i]
      unless note == 0
        play_sound(note)
        add_note(note)
        @note += 1
      end
      wait(20)
    end
    wait(60)
    quit if (@teach == @taught)
    @note = 0
    @play_song = -1
    @note_sprites.dispose
    note_sprite
  end

##-----
## Compares the song played to songs from the array.  There's probably an
## easier way to do this, but I prefer to show my work in this case.
##-----
  def compare_songs
    for i1 in 0...CP::OCARINA::SETTINGS::SONGS.size
      cur_note = 0
      note_same = 0
      for i2 in 0...CP::OCARINA::SETTINGS::SONGS[i1].size
        unless CP::OCARINA::SETTINGS::SONGS[i1][i2] == 0
          note_same += 1 if CP::OCARINA::SETTINGS::SONGS[i1][i2] == @play_notes[cur_note]
          cur_note += 1
        end
      end
      @play_song = i1 if note_same == @max_note and ($data_songs[i1][2] or @teach)
      @taught = true if @play_song == @t_song and @teach
    end
    @play_song = -1 if @teach and @taught == false
    if @taught
      $data_songs[@t_song][0] = CP::OCARINA::SETTINGS::NAMES[@t_song]
      $data_songs[@t_song][1] = CP::OCARINA::SETTINGS::DESCS[@t_song]
      $data_songs[@t_song][2] = true
    end
  end
  
end


##-----
## Handles the clef section of the song window in the menu.
##-----
class Window_SongClef < Window_Base
  def initialize
    super(0, WLH + 16, Graphics.width, WLH + 32)
    refresh
    self.opacity = 0
  end
  
  def refresh(song = -1)
    self.contents.clear
    bitmap = Cache.picture(CP::OCARINA::SETTINGS::STAFF_GFX)
    bw = bitmap.width
    bh = bitmap.height
    self.height = bh + WLH + 64
    create_contents
    bx = (self.contents.width - bw) / 2
    self.contents.blt(bx, WLH / 2 + 16, bitmap, bitmap.rect)
    unless song == -1
      @note = 0
      for i in 0...CP::OCARINA::SETTINGS::SONGS[song].size
        note = CP::OCARINA::SETTINGS::SONGS[song][i]
        unless note == 0
          add_note(bx, note)
          @note += 1
        end
      end
    end
  end
  
  def add_note(x, note)
    temp_note = Cache.picture(CP::OCARINA::SETTINGS::NOTE_GFX)
    nwi = temp_note.width
    nhe = temp_note.height
    if CP::OCARINA::SETTINGS::NOTE_SHEET
      rect = Rect.new(nwi / 8 * (note - 1), 0, nwi / 8, nhe)
    else
      rect = Rect.new(0, 0, nwi, nhe)
    end
    xa = CP::OCARINA::SETTINGS::NOTE_X + CP::OCARINA::SETTINGS::X_OFFSET * @note
    ya = CP::OCARINA::SETTINGS::NOTE_Y + CP::OCARINA::SETTINGS::Y_OFFSET * (note - 1)
    xa -= rect.width/2
    ya -= rect.height/2
    xn = x + xa
    yn = WLH / 2 + ya + 16
    self.contents.blt(xn, yn, temp_note, rect)
  end
end

##-----
## Handles the song list in the song menu.
##-----
class Window_Songs < Window_Selectable
  attr_reader   :clef_window
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 2
    self.index = 0
    refresh
  end
  
  def songs
    return @data[self.index]
  end
  
  def refresh
    @data = []
    for song in $data_songs
      @data.push(song)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    song = @data[index]
    if song != nil
      rect.width -= 4
      enabled = song[2]
      draw_song_name(song[0], rect.x, rect.y, enabled)
    end
  end
  
  def draw_song_name(item, x, y, enabled = true)
    if item != nil
      self.contents.font.color = normal_color
      self.contents.font.color.alpha = enabled ? 255 : 128
      self.contents.draw_text(x, y, 172, WLH, item)
    end
  end
  
  def clef_window=(cw)
    @clef_window = cw
    call_update_clef
  end
  
  def update_help
    @help_window.set_text(songs == nil ? "" : songs[1])
    call_update_clef
  end
  
  def call_update_clef
    if self.active and @clef_window != nil
       update_clef
    end
  end
  
  def update_clef
    @clef_window.refresh(songs[2] ? self.index : -1)
  end
end

##-----
## The scene that shows the songs and info on them in the menu.
##-----
class Scene_Songs < Scene_Base
  def initialize(goback = nil)
    @goback = goback
  end
  
  def start
    super
    create_menu_background
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @help_window = Window_Help.new
    @clef_window = Window_SongClef.new
    sy = @clef_window.height + @help_window.height - 32
    @song_window = Window_Songs.new(0, sy, Graphics.width, Graphics.height - sy)
    @song_window.help_window = @help_window
    @song_window.clef_window = @clef_window
  end

  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @clef_window.dispose
    @song_window.dispose
  end

  def return_scene
    return $scene = Scene_Menu.new(@goback) unless @goback == nil
    return $scene = Scene_Map.new
  end

  def update
    super
    update_menu_background
    @help_window.update
    @clef_window.update
    @song_window.update
    update_song_selection
  end

  def update_song_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
  
end

class Scene_Title < Scene_Base
  alias cp_oc_create_game_objects create_game_objects unless $@
  def create_game_objects
    cp_oc_create_game_objects
    create_song_list
  end
  
  def create_song_list
    $data_songs = []
    no_song = CP::OCARINA::SETTINGS::NO_SONG
    no_desc = CP::OCARINA::SETTINGS::NO_DESC
    for i in 0...CP::OCARINA::SETTINGS::SONGS.size
      $data_songs.push [no_song, no_desc, false]
    end
  end
end

##----------------------------------------------------------------------------##
##  END OF SCRIPT                                                             ##
##----------------------------------------------------------------------------##