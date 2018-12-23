#==============================================================================
#    ATS: Face Options
#    Version: 1.0.3
#    Author: modern algebra (rmrk.net)
#    Date: 20 July 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script allows you to control the face settings of a message. Not only
#   can you now give faces a talking animation and a blinking animation, but 
#   this also lets you use bigger facesets, to set the faceset based on actor 
#   ID or party ID, to encapsulate faces in their own windows, to set its 
#   position, to fade it in or scroll it in, and much more. For a complete list 
#   of features, be sure to read the Instructions starting at line 30 as well 
#   as the Editable Region starting at line 176.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  ATS Series:
#
#    This script is part of the Advanced Text System series of scripts. These
#   scripts are based off the Advanced Text System for RMVX, but since RMVX Ace
#   has a much more sensibly designed message system, it is no longer necessary
#   that it be one large script. For that reason, and responding to feedback on
#   the ATS, I have split the ATS into multiple different scripts so that you
#   only need to pick up the components for the features that you want. It is
#   therefore easier to customize and configure.
#
#    To find more scripts in the ATS Series, please visit:
#      http://rmrk.net/index.php/topic,44525.0.html
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    ~Animated Faces~
#
#    For talking animations, you need to do two things. Firstly, the 
#   :animate_faces setting must be set to true. Secondly, the name of the
#   faceset must include the following code: 
#
#        %[n]
#
#   where n is the number of poses in the animation. Ex: a faceset named 
#   "Actor1%[4]" would have 4 poses. Starting from the selected index, the 
#   face would show the first pose, then the second, then the third, then the
#   fourth, and then back to the first to repeat. You set the speed at which it
#   animates by changing the :chars_per_face setting.
#
#    To set a blinking animation, it does not matter whether :animate_faces is
#   true, and you do not need to use special filenames. Rather, you simply need 
#   to identify a blink face. This can be done in two ways. First, you can do 
#   it in a script call before the message. The important settings are 
#   :blink_face_name and :blink_face_index. Where filenames can be long, it is 
#   best to set it to a local variable first, like so:
#
#        n = "Actor1"
#        ats_next(:blink_face_name, n)
#        ats_next(:blink_face_index, 5)
#
#   Naturally, "Actor1" is the name of the faceset which houses the blinking
#   pose, and the index is 5 (so second row, second column). If the blinking 
#   pose is located within the same faceset as the normal pose, then you only
#   need to set the :blink_face_index.
#
#    The second way to do it is with the following message code, included at 
#   the very start of the message:
#
#      \fb{"Actor1", 5}
#
#   Again, change "Actor1" to whatever name you want the face to be, and 5 to
#   whatever index. Similarly, you can exclude the filename if it is the same
#   as the regular pose.
#
#    You can change the rate at which the face blinks by changing the 
#   :frames_between_blinks and :frames_to_blink message settings. Read about 
#   them at lines 185-189.
#
#    Finally, blinking also works with a talking animation, so if you are using
#   a talking animation it is a good idea to have a full set of blinking poses
#   as well. However, if you have only one, be sure that it is not in a faceset
#   identified as a talking animation (i.e. one with a %[n] code).
#
#
#    ~Large Faces~
#
#    For large faces, you can of course make a set of 8. However, if you want 
#   to save each file separately, you can just make the very first character of
#   the filename a $. In other words, an image saved as "Actor3-3" would be a 
#   regular faceset of 8 poses, while an image saved as "$Actor3-3" would be
#   an image holding only a single large face. If a file has both $ and %[n]
#   in its name, then it will treat it as a faceset with n poses, all aligned
#   horizontally. In other words, "$Actor3-3%[2]" would be a set with two 
#   faces in, the first half of the image with one pose and the second with the
#   second pose. Naturally, it will animate if used in a message, so this
#   should only be done for large face talking animations.
#
#    You set large faces just as you would a normal face. If you want the whole
#   thing to be shown, you should make sure that the :face_width and 
#   :face_height settings are both set to -1. If, on the other hand, you want
#   only to cut out the centre of the large face, you can change those values 
#   to whatever proportions you want. So, for instance, setting :face_width to
#   128 and face_height to 160 would cut out a 128x160 section of the face and
#   show that.
#
#
#    ~All Other Face Settings~
#
#    There are a lot of configuration options in this script, and I direct you 
#   to the Editable Region at line 176 for detailed comments on what each does
#   Here, I will just list them:
#
#          :animate_faces                     :face_scroll_x
#          :chars_per_face                    :face_scroll_y
#          :frames_between_blinks             :face_scroll_speed
#          :frames_to_blink                   :face_fadein
#          :blink_face_name                   :face_fade_speed
#          :blink_face_index                  :face_opacity
#          :face_x                            :face_blend_type
#          :face_x_offset                     :face_match_screen_tone
#          :face_y                            :face_tone
#          :face_y_offset                     :face_window
#          :face_width                        :face_padding
#          :face_height                       :face_win_opacity
#          :face_mirror                       :face_win_back_opacity
#          :face_overlap_allowed
#
#    As with other ATS scripts, you can change the value of these options in
#   game with the following codes in a script call:
#
#      ats_next(:message_option, x)
#      ats_all(:message_option, x)
#
#   Where :message_option is the symbol you want and x is the value you want 
#   to change it to. ats_next will only change it for the very next message, 
#   while ats_all will change it for every message to follow.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  List of Special Message Codes:
#
#    The following is a complete list of the message codes at your disposal. 
#   Simply insert them into a Display Message command.
#
# \f{"filename":n} - set face to the one in "filename" at index n.
# \f{n}  - set face to the pose at index n within the current faceset.
# \fb{"filename":n} - set blink face to the one in "filename" at index n.
# \fb{n} - set blink face to the pose at index in within the current faceset.
# \af[n] - set face to the face of the actor with ID n in the database.
# \mf[n] - set face to the face of party member in index n. 1 is the leader.
# \fa[n] - plays animation with ID n on the face.
# \fam[n] - plays a mirror of animation with ID n on the face.
# \fx[n] - sets :face_x to n, where n is: L, C, R, or an integer. See line 198.
# \fy[n] - sets :face_y to n, where n is: A, U, T, C, B, D, or an integer. See
#         line 207.
# \fw    - turns :face_window to true for this message. See line 273.
# \fm    - turns :face_mirror to true for this message. See line 255.
# \ff    - turns :face_fadein to true for this message. See line 251.
# \fsx   - turns :face_scroll_x to true for this message. See line 242.
# \fsy   - turns :face_scroll_y to true for this message. See line 245.
#==============================================================================

$imported = {} unless $imported
$imported[:MA_ATS_FaceOptions] = true

#==============================================================================
# ** Game_ATS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - animate_faces; chars_per_face; 
#      frames_between_blinks; frames_to_blink; face_x; face_y; face_x_offset;
#      face_y_offset; face_width; face_height; face_scroll_x; face_scroll_y;
#      face_scroll_speed; face_fadein; face_fade_speed; face_mirror; 
#      face_opacity; face_blend_type; face_tone; face_window; face_padding; 
#      face_win_opacity; face_win_back_opacity; face_overlap_allowed; 
#      blink_face_name; blink_face_index
#==============================================================================

class Game_ATS
  CONFIG ||= {}
  CONFIG[:ats_face_options] = {
	  ats_face_options: true, 
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #  EDITABLE REGION
	  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #    ~Face Animation Settings~
    # 
    #  :animate_faces - true or false. Set this to true if you want faces to 
    # animate. Set it to false if you don't, but that should be rare since only 
    # faces with a %[n] code will animate, where n is the number of frames in 
    # the animation. No other faceset will animate. As such, this option should
    # only ever be set to false if you only want a single pose from a faceset
    # which with a %[n] code.
    animate_faces:         true,
    #  :chars_per_face - integer. When animating a face, this sets how many 
    # letters should be drawn before switching to the next frame.
    chars_per_face:        8,
    #  :frames_between_blinks - x...y; x & y both integers. If using a blink 
    # face, the time between blinks in frames. There are 60 frames in 1 second.
    frames_between_blinks: 180..300,
    #  :frames_to_blink - integer. Number of frames to show the blinking face.
    frames_to_blink:       12,
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #    ~Face Position and Size~
    #
    #  :face_x - integer, :L, :C, or :R. The X coordinate of the face. If an
    # integer, the face's x-coordinate is set directly to that position. You
    # can also set it so that it is automatically positioned according to the
    # position of the message window. If you set it to :L, it will be at the 
    # left end of the message window, and if you set it to :R it will be at the 
    # right end of the message window. If you set it to :C, it will be centred,
    # but naturally that setting should only ever be used if the Y position of
    # the face does not overlap with the message window.
    face_x:                :L,
    #  :face_y - integer, :A, :U, :T, :C, :B, or :D. The Y coordinate of the 
    # face. If an integer, the face's y-coordinate is set directly to that 
    # position. You can also set it so that it is automatically positioned 
    # according to the position of the message window. If you set it to :U (Up), 
    # the bottom of the face will be flush with the top border of the message 
    # window. If you set it to :T (Top), then the top of the face will be flush 
    # with the top border of the message window. If you set it to :C (Centre), 
    # then the centre of the face will match the centre of the message window. 
    # If you set it to :B (Bottom), then the bottom border of the face will be
    # flush with the bottom border of the message window. If you set it to 
    # :D (Down), then the top of the face will be flush with the bottom border
    # of the message window. Finally, if you set it to :A (Automatic), then it
    # will be :C if the face is smaller than the message window, and otherwise
    # it will be :T if the message window is in the upper portion of the screen
    # or :B if the message window is in the lower portion of the screen. The 
    # recommended value is :C if you are using regular facesets or :A if you
    # are using large facesets.
    face_y:                :A,
    #  :face_x_offset - integer. If using an automatic setting for :face_x, 
    # this is added or subtracted from the x placement, as appropriate.
    face_x_offset:         0,
    #  :face_y_offset - integer. If using an automatic setting for :face_y, 
    # this is added or subtracted from the y placement, as appropriate.
    face_y_offset:         0,
    #  :face_width - integer. The horizontal size of the face. If -1, it will
    # be set to the width of the face used. If less than the width of the face
    # used, it will take as much of the centre of the face as possible
    face_width:            -1,
    #  :face_height - integer. The vertical size of the face. If -1, it will be 
    # set to the height of the face used. If less than the height of the face 
    # used, it will take as much of the centre of the face as possible
    face_height:           -1,
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #    ~Face Settings~
    #
    #  :face_scroll_x - true or false. Whether the face should scroll in to
    # place horizontally
    face_scroll_x:         false,
    #  :face_scroll_y - true or false. Whether the face should scroll in to
    # place vertically
    face_scroll_y:         false,
    #  :face_scroll_speed - integer. The number of frames it takes to scroll 
    # into position.
    face_scroll_speed:     15,
    #  :face_fadein - true or false. Whether face should fade in gradually.
    face_fadein:           false,
    #  :face_fade_speed - integer. The number of frames it takes to fade in.
    face_fade_speed:       15,
    #  :face_mirror - true or false. Whether the face should be flipped to face
    # the opposite direction. 
    face_mirror:           false,
    #  :face_opacity - 0-255. The degree of transparancy of the face.
    face_opacity:          255,
    #  :face_blend_type - 0-2. 0 => Normal; 1 => Add; 2 => Subtract. This 
    # should almost always be set to 0 as either other option changes the face
    # dramatically. However, it can be used for a ghost or darkness effect.
    face_blend_type:       0,
    #  :face_match_screen_tone - true or false. If true, the tone of the face
    # will be the same as that of the screen unless you set :face_tone to 
    # something other than nil. Otherwise there will be no automatic setting.
    face_match_screen_tone: false,
    #  :face_tone - Tone.new(-255 - 255, -225 - 255, -255 - 255, -255 - 255) - 
    # This allows you to blend a tone with the face. The values are 
    # (red, green, blue, gray). It should usually be set to nil, but might be 
    # useful for flashbacks or lighting effects, etc...
    face_tone:             nil,
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #    ~Face Window Settings~
    #
    #  :face_window - true or false. If true, face shown in its own window
    face_window:           false,
    #  :face_padding - integer. If using window, the size of the border.
    face_padding:          6,
    #  :face_win_opacity - 0-255. The total opacity of the face window
    face_win_opacity:      255,
    #  :face_win_back_opacity - 0-255. The back opacity of the face window
    face_win_back_opacity: 192,
    #  :face_overlap_allowed - true or false. If false, this will not permit
    # any overlap between the face's window and the regular window, and it 
    # will resize the message window to avoid it. It should not be used unless 
    # you are using either a flush left or flush right placement for the face
    # window. Recommended value is true.
    face_overlap_allowed:  true,
	  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #  END EDITABLE REGION
    #////////////////////////////////////////////////////////////////////////
    blink_face_name:       "",
    blink_face_index:      -1,
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  CONFIG[:ats_face_options].keys.each { |key| attr_accessor key }
end

#==============================================================================
#  Initialize Common ATS Data if no other ATS script interpreted first
#==============================================================================

if !$imported[:AdvancedTextSystem]
  #============================================================================
  # *** DataManager
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - create_game_objects; make_save_contents;
  #      extract_save_contents
  #============================================================================
  module DataManager
    class << self
      alias modb_ats_crtgmobj_6yh7 create_game_objects
      alias mlba_ats_mksave_5tg9 make_save_contents
      alias ma_ats_extrcsvcon_8uj2 extract_save_contents
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Create Game Objects
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.create_game_objects(*args, &block)
      modb_ats_crtgmobj_6yh7(*args, &block)
      $game_ats = Game_ATS.new
      $game_ats.init_new_installs
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Make Save Contents
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.make_save_contents(*args, &block)
      contents = mlba_ats_mksave_5tg9(*args, &block)
      contents[:ats] = $game_ats
      contents
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Extract Save Contents
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.extract_save_contents(contents, *args, &block)
      ma_ats_extrcsvcon_8uj2(contents, *args, &block)
      $game_ats = contents[:ats] ? contents[:ats] : Game_ATS.new
      $game_ats.init_new_installs
    end
  end
  
  #============================================================================
  # ** Game_ATS
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This class holds the default data for all scripts in the ATS series
  #============================================================================
  
  class Game_ATS
    def initialize; reset; end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Reset any or all installed ATS scripts
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def reset(script_name = nil)
      if script_name.is_a? (Symbol) # If script to reset specified
        CONFIG[script_name].each_pair { |key, value| 
          self.send("#{key}=".to_sym, value) 
          $game_message.send("#{key}=".to_sym, value)
        }
      else                          # Reset all ATS scripts
        CONFIG.keys.each { |script| reset(script) }
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Initialize any newly installed ATS scripts
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def init_new_installs
      CONFIG.keys.each { |script| reset(script) unless self.send(script) }
    end
  end
  
  #============================================================================
  # ** Game_Message
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    aliased method - clear
  #============================================================================
  
  class Game_Message
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Clear
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias mlb_ats_clrats_5tv1 clear
    def clear(*args, &block)
      mlb_ats_clrats_5tv1(*args, &block) # Run Original Method
      return if !$game_ats
      Game_ATS::CONFIG.values.each { |installed|
        installed.keys.each { |key| self.send("#{key}=".to_sym, $game_ats.send(key)) }
      }
    end
  end
  
  #============================================================================
  # ** Game_Interpreter
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    new methods - ats_all; ats_next
  #============================================================================
  
  class Game_Interpreter
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * ATS All
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def ats_all(sym, *args, &block)
      $game_ats.send("#{sym}=".to_sym, *args, &block)
      ats_next(sym, *args, &block)
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * ATS Next
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def ats_next(sym, *args, &block)
      $game_message.send("#{sym}=".to_sym, *args, &block)
    end
  end

  $imported[:AdvancedTextSystem] = true
end

#==============================================================================
# ** Game_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - animate_faces; chars_per_face; 
#      frames_between_blinks; frames_to_blink; face_x; face_y; face_x_offset;
#      face_y_offset; face_width; face_height; face_scroll_x; face_scroll_y;
#      face_scroll_speed; face_fadein; face_fade_speed; face_mirror; 
#      face_opacity; face_blend_type; face_tone; face_window; face_padding; 
#      face_win_opacity; face_win_back_opacity; face_overlap_allowed; 
#      blink_face_name; blink_face_index
#==============================================================================

class Game_Message
  Game_ATS::CONFIG[:ats_face_options].keys.each { |key| attr_accessor key }
end

#==============================================================================
# ** Sprite_ATS_Face
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This sprite shows a face graphic for messages.
#==============================================================================

class Sprite_ATS_Face < Sprite_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variable
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :num_frames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(96, 96)
    @num_frames = 1
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Free
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose(*args)
    bitmap.dispose if bitmap && !bitmap.disposed?
    super(*args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup(faces, blink_faces = [])
    if faces.empty? # No Face
      bitmap.clear   
      @num_frames = 1                                        # Clear Bitmap
    else
      bitmap.dispose if bitmap && !bitmap.disposed?          # Dispose old bitmap
      rect = Rect.new(0, 0, faces[0].width, faces[0].height) # Set Rect
      # Create Bitmap
      h = blink_faces.empty? ? rect.height : rect.height*2
      self.bitmap = Bitmap.new(rect.width*faces.size, h)
      @num_frames = faces.size
      # Draw all faces onto the bitmap
      for i in 0...@num_frames
        x = i*rect.width
        bitmap.blt(x, 0, faces[i], rect)
        bitmap.blt(x, rect.height, blink_faces[i % blink_faces.size], rect) if !blink_faces.empty?
      end
      src_rect.set(rect) # Set Source Rect
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Face Frame
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_column(index = 0)
    src_rect.x = index*src_rect.width
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Face Frame
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_row(index = 0)
    src_rect.y = index*src_rect.height
  end
end

#==============================================================================
# ** Window_ATS_Face
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This window displays a face graphic for messages.
#==============================================================================

class Window_ATS_Face < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def create_face(face_name, face_index)
    contents.clear
    draw_face(face_name, face_index, 0, 0)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Face Graphic
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_face(face_name, face_index, x, y, enabled = true, *args)
    bmp = Cache.face(face_name)
    fw, fh = bmp.width, bmp.height
    if face_name[/\A\$/] != nil # SINGLE
      if face_name[/\%\[\s*(\d+)\s*\]/] != nil
        fw /= $1.to_i
      else
        face_index = 0
      end
      cw, ch = contents.width - x, contents.height - y
      rect = Rect.new((face_index*fw) + ((fw - cw) / 2), (fh - ch) / 2, cw, ch)
      contents.blt(x, y, bmp, rect, enabled ? 255 : translucent_alpha)
    else
      fw /= 4
      fh /= 2
      rect = Rect.new(face_index % 4 * fw, face_index / 4 * fh, fw, fh)
      contents.blt(x, y, bmp, rect, enabled ? 255 : translucent_alpha)
    end
    bmp.dispose
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Resize Window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def resize(w, h)
    self.width = w + (standard_padding*2)
    self.height = h + (standard_padding*2)
    create_contents
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Standard Padding
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def standard_padding
    $game_message.face_padding
  end
end

#==============================================================================
# ** Spriteset_ATS_Face
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This class creates and control the window and sprite for showing faces
#==============================================================================

class Spriteset_ATS_Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :face_window
  attr_reader   :face_sprite
  attr_reader   :x
  attr_reader   :y
  attr_reader   :z
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize(message_window, viewport = nil)
    @message_window = message_window
    @face_window = Window_ATS_Face.new(0, 0, 120, 120)
    @face_sprite = Sprite_ATS_Face.new(viewport)
    self.x, self.y, @dest_x, @dest_y = 0, 0, 0, 0
    @dest_scroll_x_speed, @dest_scroll_y_speed = 0, 0
    @dest_sprite_opacity, @dest_window_opacity = 255, 255
    @dest_s_fade_speed, @dest_w_fade_speed = 0, 0
    self.z = message_window.z + 1
    clear
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Free
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def dispose
    @face_window.dispose
    @face_sprite.dispose
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    @face_sprite.update
    @face_window.update
    @face_window.visible = !empty? && $game_message.face_window
    @face_sprite.visible = @face_window.open? if @face_window.visible
    update_scroll
    update_fade
    update_blink
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Scroll
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_scroll
    # Scroll X
    if @dest_x > self.x
      self.x = [self.x + @dest_scroll_x_speed, @dest_x].min
    elsif @dest_x < self.x
      self.x = [self.x + @dest_scroll_x_speed, @dest_x].max
    end
    # Scroll Y
    if @dest_y > self.y
      self.y = [self.y + @dest_scroll_y_speed, @dest_y].min
    elsif @dest_y < self.y
      self.y = [self.y + @dest_scroll_y_speed, @dest_y].max
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update fade
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_fade
    if @dest_sprite_opacity != face_sprite.opacity
      face_sprite.opacity += @dest_s_fade_speed
      face_sprite.opacity = @dest_sprite_opacity if face_sprite.opacity > @dest_sprite_opacity
    end
    if @dest_window_opacity != face_window.opacity
      face_window.opacity += @dest_w_fade_speed
      face_window.opacity = @dest_window_opacity if face_window.opacity > @dest_window_opacity
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Blink
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_blink
    if blinking?
      @blink_timer -= 1
      if @blink_timer <= 0
        @blink_status = (@blink_status + 1) % 2
        @face_sprite.set_row(@blink_status)
        @blink_timer = case @blink_status
        when 0
          fbb = $game_message.frames_between_blinks
          fbb.first + rand(fbb.last - fbb.first)
        when 1 then $game_message.frames_to_blink
        end
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def clear
    @face_name, @face_index, @blink_face_name, @blink_face_index = "", 0, "", 0
    @face_width, @face_height = 0, 0
    @active_face = -1
    @blink_status, @blink_timer = 0, 0
    @face_sprite.setup([])
    hide
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh(face_name = @face_name, face_index = @face_index)
    @face_name, @face_index = face_name, face_index
    @blink_face_name, @blink_face_index = $game_message.blink_face_name, $game_message.blink_face_index
    return if empty?
    # If blink face partially set, set the other aspect.
    if $game_message.blink_face_index >= 0 && $game_message.blink_face_name.empty?
      $game_message.blink_face_name = face_name
    elsif !$game_message.blink_face_name.empty? && $game_message.blink_face_index < 0
      $game_message.blink_face_index = 0
    end
    @face_width = $game_message.face_width + $game_message.face_padding
    @face_height = $game_message.face_height + $game_message.face_padding
    resize_face(face_name, face_index)
    @face_sprite.setup(collect_faces, collect_faces($game_message.blink_face_name, $game_message.blink_face_index))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup(face_name = $game_message.face_name, face_index = $game_message.face_index)
    need_refresh = (@face_name != face_name || @face_index != face_index ||
      @blink_face_name != $game_message.blink_face_name || 
      @blink_face_index != $game_message.blink_face_index || 
      @face_width != ($game_message.face_width + $game_message.face_padding) || 
      @face_height != ($game_message.face_height + $game_message.face_padding))
    refresh(face_name, face_index) if need_refresh
    unless empty?
      @message_window.restore_overlap_width
      update_placement
      @message_window.adjust_placement_for_face
      @face_sprite.opacity = $game_message.face_opacity
      @face_window.opacity = $game_message.face_win_opacity
      # Only Scroll and Fade if a new face
      if need_refresh
        setup_scroll
        setup_fade
      end
      @face_sprite.mirror = $game_message.face_mirror
      @face_sprite.blend_type = $game_message.face_blend_type
      # Set Tone
      case $game_message.face_tone
      when Tone then @face_sprite.tone.set($game_message.face_tone)
      when Array then @face_sprite.tone.set(*$game_message.face_tone)
      else 
        ($game_message.face_match_screen_tone ? 
          @face_sprite.tone.set($game_map.screen.tone) : 
          @face_sprite.tone.set(0, 0, 0, 0))
      end
      @face_window.back_opacity = $game_message.face_win_back_opacity
      fbb = $game_message.frames_between_blinks
      @blink_status = 0
      @blink_timer = fbb.first + rand(fbb.last - fbb.first)  
      show
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Scroll
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_scroll
    if $game_message.face_scroll_x
      self.x = (self.x + @face_window.width) > (Graphics.width - self.x) ? 
        Graphics.width : -@face_window.width
      @dest_scroll_x_speed = (@dest_x - self.x) / $game_message.face_scroll_speed
    end
    if $game_message.face_scroll_y
      self.y = (self.y + @face_window.height) > (Graphics.height - self.y) ? 
        Graphics.height : -@face_window.height
      @dest_scroll_y_speed = (@dest_y - self.y) / $game_message.face_scroll_speed
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Fade
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_fade
    if $game_message.face_fadein
      @face_sprite.opacity = 0
      @face_window.opacity = 0
      @dest_sprite_opacity = $game_message.face_opacity
      @dest_window_opacity = $game_message.face_win_opacity
      @dest_s_fade_speed = @dest_sprite_opacity / $game_message.face_fade_speed
      @dest_w_fade_speed = @dest_window_opacity / $game_message.face_fade_speed
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Collect Faces
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def collect_faces(face_name = @face_name, face_index = @face_index)
    return [] if !face_name || face_name.empty?
    faces = []
    # If face_file has animation code, add each frame
    num = $game_message.animate_faces && face_name[/\%\[\s*(\d+)\s*\]/] ? $1.to_i : 1
    for i in face_index...(face_index + num)
      @face_window.create_face(face_name, i)
      faces.push(@face_window.contents.dup)
    end
    @face_window.contents.clear
    return faces.compact
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Resize Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def resize_face(face_name, face_index = 0)
    # Get set size
    wdth, hght = $game_message.face_width, $game_message.face_height
    face = Cache.face(face_name)
    fw, fh = face.width, face.height
    face.dispose
    # Adjust face width and height if faceset not single
    if face_name[/\A\$/] == nil
      fw /= 4
      fh /= 2
    else
      fw /= $1.to_i if face_name[/\%\[\s*(\d+)\s*\]/]
    end
    wdth = wdth <= 0 ? fw : [fw, wdth].min
    hght = hght <= 0 ? fh : [fh, hght].min
    @face_window.resize([wdth, $game_message.face_width].max, [hght, $game_message.face_height].max)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_placement
    set_x_placement
    set_y_placement
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set X Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_x_placement
    # Update X
    side_offset = $game_message.face_x_offset
    side_offset += (@message_window.padding - $game_message.face_padding)
    @dest_x = case $game_message.face_x
    when Integer then $game_message.face_x - ($game_message.face_window ? 0 : $game_message.face_padding)
    when :l, :L then @message_window.x + side_offset
    when :c, :C then @message_window.x + ((@message_window.width - 
      @face_window.width) / 2) + $game_message.face_x_offset
    when :r, :R then @message_window.x + @message_window.width - 
      @face_window.width - side_offset
    end
    self.x = @dest_x unless $game_message.face_scroll_x
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Y Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_y_placement
    # Update Y
    fy = $game_message.face_y
    fy = fy.to_s.upcase.to_sym if fy.is_a?(Symbol)
    # Automatic Set
    if fy == :A
      if @face_window.height <= @message_window.height
        fy = :C # Centre if face smaller than message window
      elsif @message_window.y < (Graphics.height - @message_window.height) / 2 
        fy = :T # Align with Top if message window above mid-screen
      else
        fy = :B # Align with Bottom otherwise
      end
    end
    w_pad = ($game_message.face_window ? 0 : $game_message.face_padding)
    @dest_y = case fy
    when Integer then fy - w_pad
    when :U, :AT then @message_window.y - @face_window.height + 
      $game_message.face_y_offset + w_pad
    when :T, :BT then @message_window.y + $game_message.face_y_offset - w_pad
    when :C then @message_window.y + ((@message_window.height - 
      @face_window.height) / 2) + $game_message.face_y_offset
    when :B, :AB then @message_window.y + @message_window.height - 
      @face_window.height - $game_message.face_y_offset + w_pad
    when :D, :BB then @message_window.y + @message_window.height - 
      $game_message.face_y_offset - w_pad
    end
    self.y = @dest_y unless $game_message.face_scroll_y
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Empty?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def empty?
    @face_name.empty?
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Animate Face?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def animate_face?
    !empty? && ($game_message.animate_faces && @face_sprite.src_rect.width < @face_sprite.bitmap.width)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Blinking?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def blinking?
    !empty? && ($game_message.blink_face_name && !$game_message.blink_face_name.empty?)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Scrolling?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def scrolling?
    !empty? && ((@dest_x != self.x) || (@dest_y != self.y))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Fading
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fading?
    !empty? && ((@dest_sprite_opacity != face_sprite.opacity) || (@dest_window_opacity != face_window.opacity))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Next Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_next_face(direct = nil)
    return if @active_face == direct
    @active_face = direct ? direct : (@active_face + 1) % @face_sprite.num_frames
    @face_sprite.set_column(@active_face)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Screen Ranges
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def screen_ranges
    fx, fw = @dest_x, @face_window.width
    fy, fh = @dest_y, @face_window.height
    unless  $game_message.face_window
      fx += @face_window.padding
      fy += @face_window.padding
      fw -= 2*@face_window.padding
      fh -= 2*@face_window.padding
    end
    return (fx...(fx + fw)), (fy...(fy + fh))
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show / Hide
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def show
    @face_sprite.visible = true
    @face_window.visible = $game_message.face_window
    if !@message_window.open?
      @face_window.openness = 0
      @face_window.open
    end
  end
  def hide
    @face_sprite.visible = false
    @face_window.visible = false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check if Visible?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def visible?
    @face_sprite.visible || @face_window.visible
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set X, Y
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:x, :y].each { |writer|
    define_method(:"#{writer}=") do |val|
      instance_variable_set(:"@#{writer}", val)
      @face_window.send(:"#{writer}=", val)
      @face_sprite.send(:"#{writer}=", val + $game_message.face_padding)
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Z
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def z=(val)
    @z = val + 1
    @face_window.z = val
    @face_sprite.z = val + 1
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Method Missing
  #    If method missing, call it on either sprite or window
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def method_missing(meth, *args, &block)
    # Face Sprite Check
    if @face_sprite && @face_sprite.respond_to?(meth)
      return @face_sprite.send(meth, *args, &block)
    # Face Window
    elsif @face_window && @face_window.respond_to?(meth)
      return @face_window.send(meth, *args, &block)
    else
      super
    end
  end
end

#==============================================================================
# ** Window_ChoiceList
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - update_placement
#    new method - screen_ranges
#==============================================================================

class Window_ChoiceList
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Placement
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_updplacm_6yh2 update_placement
  def update_placement(*args)
    maatsfo_updplacm_6yh2(*args)
    @message_window.adjust_choice_placement_for_face
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Screen Ranges
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  unless method_defined?(:screen_ranges)
    def screen_ranges
      return ((self.x + self.padding)...(self.x + self.width - self.padding)), 
        ((self.y + self.padding)...(self.y + self.height - self.padding))
    end
  end
end

#==============================================================================
# ** Window_ATS_Name (compatibility with ATS: Message Options)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - screen_ranges
#==============================================================================

class Window_ATS_Name < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Screen Ranges
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  unless method_defined?(:screen_ranges)
    def screen_ranges
      return ((self.x + self.padding)...(self.x + self.width - self.padding)), 
        ((self.y + self.padding)...(self.y + self.height - self.padding))
    end
  end
end

#==============================================================================
# ** Window_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - create_all_windows; new_page; process_escape_character
#    overwritten method - draw_face
#==============================================================================

class Window_Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_creatwins_3hn6 create_all_windows
  def create_all_windows(*args, &block)
    maatsfo_creatwins_3hn6(*args, &block) # Call Original Method
    @atsfo_face = Spriteset_ATS_Face.new(self)
    @atsmo_all_windows.push(@atsfo_face.face_window) if $imported[:ATS_MessageOptions]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_updatewins_8jv3 update_all_windows
  def update_all_windows(*args, &block)
    maatsfo_updatewins_8jv3(*args, &block)
    @atsfo_face.update
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Dispose All Windows
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_disposallwins_6xq1 dispose_all_windows
  def dispose_all_windows(*args, &block)
    maatsfo_disposallwins_6xq1(*args, &block)
    @atsfo_face.dispose
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Placement
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_update_placement update_placement
  def update_placement(*args)
    restore_overlap_width
    maatsfo_update_placement(*args) # Call Original Method
    # Remove AF or PF code and process it
    text = $game_message.all_text.dup
    process_face_setting_codes(text)
    while text.slice!(/\A\\([AM]?FB?)(\[\d+\]|{\s*['"]?.*?['"]?[\s,;:]*\d*\s*})/i) != nil
      process_face_code($1, $2)
    end
    @atsfo_face.setup
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Restore Overlap Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def restore_overlap_width
    if @overlap_width_adjust
      self.x = @overlap_width_adjust[0]
      resize(@overlap_width_adjust[1], height)
      @overlap_width_adjust = nil
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Face Setting Codes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def process_face_setting_codes(text)
    text.gsub!(/[\\\e]FX\[(\d+|[RLC])\]/i) {
      process_face_setting_code('FX', "[#{$1}]")
      ""
    }
    text.gsub!(/[\\\e]FY\[(\d+|[AUTCBD])\]/i) {
      process_face_setting_code('FY', "[#{$1}]")
      ""
    }
    text.gsub!(/[\\\e](FF|FSX|FSY|FW|FM)/i) {
      process_face_setting_code($1, "")
      ""
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Close
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if instance_methods(false).include?(:close)
    alias maatsfo_close_4hn6 close
    def close(*args)
      @atsfo_face.clear
      maatsfo_close_4hn6(*args) # Call Original Method
    end
  else
    def close(*args)
      @atsfo_face.clear
      super(*args) # Call Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * New Page
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_newpag_7uj2 new_page
  def new_page(text, pos, *args)
    process_face_setting_codes(text)
    while text[/\A\e[AM]?FB?(\[\d+\]|{\s*['"]?.*?['"]?[\s,;:]*\d*\s*})/i] != nil
      text.slice!(/\A\e([AM]?FB?)/i)
      process_face_code($1, text)
    end
    maatsfo_newpag_7uj2(text, pos, *args)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Face (overwritten super method)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_face(face_name, face_index, *args)
    atsfo_change_face(face_name, face_index)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Change Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def atsfo_change_face(face_name, face_index, blink = false)
    return if @atsf_testing
    @atsfo_face_count = 0
    if blink
      $game_message.blink_face_name = face_name
      $game_message.blink_face_index = face_index
      @atsfo_face.refresh($game_message.face_name, $game_message.face_index)
    else
      $game_message.face_name = face_name
      $game_message.face_index = face_index
      @atsfo_face.setup($game_message.face_name, $game_message.face_index)
    end
    @atsfo_face.empty? ? @atsfo_face.hide : @atsfo_face.show
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * New Line X
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_nwlinex_4jn6 new_line_x
  def new_line_x(*args)
    if @atsfo_face.visible?
      return 0 if !$game_message.face_overlap_allowed
      rfx, rfy = @atsfo_face.screen_ranges
      rmx, rmy = screen_ranges
      # If face window overlaps left side & overlaps some of the window
      if !(rfy === rmy.first || rmy === rfy.first)
        return 0
      # If more room on the right side of the face than the left
      elsif (rfx.first - rmx.first) < (rmx.last - rfx.last)
        return [rfx.last - rmx.first + 16, 0].max
      else # Left-aligned Text
        return 0
      end
    else
      maatsfo_nwlinex_4jn6(*args)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Face Animation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_face_animation
    if @show_fast || @line_show_fast
      @atsfo_face.draw_next_face(0)
    else
      @atsfo_face_count = (@atsfo_face_count + 1) % $game_message.chars_per_face
      @atsfo_face.draw_next_face if @atsfo_face_count == 0
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Normal Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_procsnormchar_8zj6 process_normal_character
  def process_normal_character(*args)
    update_face_animation if @atsfo_face.animate_face?
    maatsfo_procsnormchar_8zj6(*args) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_procescchar_6ca8 process_escape_character
  def process_escape_character(code, text, *args, &block)
    result = process_face_setting_code(code, text) || process_face_code(code, text)
    if code[/FA(M?)/]
      mirror = !$1.empty?
      anim_id = obtain_escape_param(text)
      @atsfo_face.face_sprite.start_animation($data_animations[anim_id], mirror) unless @atsf_testing
      result = true
    end
    # Call Original Method
    maatsfo_procescchar_6ca8(code, text, *args, &block) unless result 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Face Code
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def process_face_code(code, text)
    code.upcase!
    blink = (code.slice!(/B\Z/) != nil)
    if code[/([AM])F/] != nil # AF (Actor Face) or PF (Party Face)
      type = ($1 == 'A')
      param = obtain_escape_param(text)
      actor = type ? $game_actors[param] : $game_party.members[[param - 1, 0].max]
      # Change Face to chosen Actor
      atsfo_change_face(actor.face_name, actor.face_index, blink) if actor
    elsif code == 'F' # F (Face)
      if text.slice!(/^{\s*['"]?(.*?)['"]?[\s,;:]*(\d*)\s*}/)
        atsfo_change_face($1.empty? ? $game_message.face_name : $1, $2.to_i, blink)
      end
    else
      return false
    end
    return true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Face Setting Code
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def process_face_setting_code(code, text)
    return false if code.nil? || code.empty?
    case code.upcase
    when 'FF' then $game_message.face_fadein = true
    when 'FSX' then $game_message.face_scroll_x = true
    when 'FSY' then $game_message.face_scroll_y = true
    when 'FW' then $game_message.face_window = true
    when 'FM' then $game_message.face_mirror = true
    when 'FX'
      $game_message.face_x = text.slice!(/\A\[([LCR])\]/i) != nil ? $1.to_sym :
        obtain_escape_param(text)
    when 'FY'
      $game_message.face_y = text.slice!(/\A\[([AUTCBD])\]/i) != nil ? $1.to_sym :
        obtain_escape_param(text)
    else 
      return false
    end
    return true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Wait / Input Pause / Input Choice / Input Number / Input Item
  #``````````````````````````````````````````````````````````````````````````
  # Change Face to Idle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:wait, :input_pause, :input_choice, :input_number, :input_item].each { |meth|
    alias_method(:"maatsfo_#{meth}_7uj1", meth)
    define_method(meth) do |*args|
      @atsfo_face.draw_next_face(0)
      send(:"maatsfo_#{meth}_7uj1", *args)
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Settings Changed?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maatsfo_setngchn_5ov6 settings_changed?
  def settings_changed?(*args)
    return true if @overlap_width_adjust
    maatsfo_setngchn_5ov6(*args) # Call Original Method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Message Window Position
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def adjust_placement_for_face
    rfx, rfy = @atsfo_face.screen_ranges
    # Unless user allows face overlap with message window
    unless $game_message.face_overlap_allowed
      rmx, rmy = screen_ranges
      # If face window overlaps vertically
      if (rfy === rmy.first || rmy === rfy.first)
        # If more space on right than left
        if (rfx.first - rmx.first) < (rmx.last - rfx.last)
          # Don't resize if it makes message window too small
          if (rmx.last - rfx.last) > padding + 32
            @overlap_width_adjust = [x, width]
            # Resize and move message window to right of face
            w = x + width - rfx.last
            resize(w, height)
            self.x = rfx.last
          end
        else
          # Don't resize if it makes message window too small
          if (rfx.first - rmx.first) > padding + 32
            @overlap_width_adjust = [x, width]
            # Resize so message window all to left of face
            w = rfx.first - x
            resize(w, height)
          end
        end
      end
    end
    # Move Name Window if necessary
    if $imported[:ATS_MessageOptions] && $game_message.message_name
      @atsmo_name_window.z = self.z + 4
      rnx, rny = @atsmo_name_window.screen_ranges
      # If name overlaps with face window
      if (rny === rfy.first || rfy === rny.first) && (rnx === rfx.first || 
        rfx === rnx.first)
        # if message window to left
        if rfx.first - @atsmo_name_window.width > x
          # Move name window to left of face
          @atsmo_name_window.x = rfx.first - @atsmo_name_window.width
        else
          @atsmo_name_window.x = rfx.last
        end
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Adjust Choice Window Placement
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def adjust_choice_placement_for_face
    rcx, rcy = @choice_window.screen_ranges
    rfx, rfy = @atsfo_face.screen_ranges
    # If face window overlaps with choice window
    if (rfy === rcy.first || rcy === rfy.first) && (rfx === rcx.first || 
      rcx === rfx.first)
      # if message window to left
      if rfx.first - @choice_window.width > x 
        # Move name window to left of face
        @choice_window.x = rfx.first - @choice_window.width
      else
        @choice_window.x = rfx.last
      end
      # Adjust to make sure not over a name
      if $imported[:ATS_MessageOptions] && $game_message.message_name
        rnx, rny = @atsmo_name_window.screen_ranges
        rcx, rcy = @choice_window.screen_ranges
        # If overlaps name window
        if (rny === rcy.first || rcy === rny.first) && (rnx === rcx.first || 
          rcx === rnx.first)
          # Try to Centre
          if rnx.first - @choice_window.width > x
            @choice_window.x = rnx.first - @choice_window.width
          else
            @choice_window.x = rnx.last
          end
        end
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Resize
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def resize(w, h)
    if w != self.width || h != self.height
      self.width = w
      self.height = h
      create_contents
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Screen Ranges
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def screen_ranges
    rmx = (self.x + self.padding)...(self.x + self.width - self.padding)
    rmy = (self.y + self.padding)...(self.y + self.height - self.padding)
    return rmx, rmy
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Total Line Width
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maatsfo_line_width(y = 0)
    nlx = new_line_x
    w = contents_width
    if @atsfo_face.visible?
      rfx, rfy = @atsfo_face.screen_ranges
      rmx, rmy = screen_ranges
      if (rfy === rmy.first || rmy === rfy.first) && nlx < rfx.first && 
        (rfx.first < (x + width - padding))
        w = rfx.first - (x + padding)
      end
    end
    w - nlx
  end
  if $imported[:ATS_Formatting]
    def maatsf_total_line_width(y = 0); maatsfo_line_width(y); end
  end
end