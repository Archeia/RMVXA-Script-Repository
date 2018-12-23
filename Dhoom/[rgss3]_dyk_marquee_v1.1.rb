#==============================================================================
#
# • Dhoom DYK Marquee v1.1
# -- Last Updated: 2014.10.09
# -- Level: Easy
# -- Requires: None
#
#==============================================================================

module Dhoom
  module DYKMarquee
    TEXTS = [
    #Put additional "\" before escape character
    "You can escape most battles by holding down the \\I[116] and \\I[117] keys.",
    "You can play Final Fantasy Discovery with a gamepad, and customize button input and other game options by pressing the \\I[124] key.",
    "You can dash by holding down the \\I[118] key while moving.",
    "Development on \\C[4]Final Fantasy Discovery\\C[0] began on May 1st, 2011.",
    "There is no word for \"kupo\" in Al Bhed.",
    "When starting a \\C[4]New Game Plus\\C[0] file, you'll retain most of your items, including any Al Bhed Primers you've collected.",
    "It is literally impossible to defeat an Ivalician Judge. Seriously, don't try.",
    "The Gold Saucer is the headquarters of the \\C[4]Gold Saucer Syndicate\\C[0], Gaia's largest private army.",
    "You can follow \\C[4]Final Fantasy Discovery\\C[0] on \\I[300]\\I[301]\\I[302]! Follow \\C[4]@FFDiscovery\\C[0]!",
    "Along with the development team, the RPG Maker community at large had a huge hand in developing \\C[4]Final Fantasy Discovery\\C[0].",
    "William Couillard and Paul Cheung co-developed \\C[4]Final Fantasy Discovery\\C[0] from opposite ends of the United States (New York and California)!",
    "Characters from Daniel Babineau's \\C[4]Final Fantasy Blackmoon Prophecy\\C[0] have a chance of appearing as opponents in the Gold Saucer's Battle Arena.",
    "The Al Bhed are all born with green eyes and blonde hair.",
    "Moogles and Chocobos are somehow able to verbally communicate with each other.",
    "Male moogles cannot sustain flight for longer than a few seconds, whereas a female moogle's bigger wings allow for longer periods of air travel.",
    "\\C[4]Final Fantasy Discovery\\C[0] has a soundtrack composed of over 100 remixed and arranged tracks, all made by fans.",
    "The first public build of \\C[4]Final Fantasy Discovery\\C[0] was released on October 28th, 2012.",
    "The second public build of \\C[4]Final Fantasy Discovery\\C[0] was released on May 4th, 2013 as part of RMN's \"Release Something Weekend\" community event.",
    "Counting all previous versions, \\C[4]Final Fantasy Discovery\\C[0] has been downloaded over 9,000 times.",
    "The \\C[4]Ogir-Yensa Sandsea\\C[0] is home to Gaia's reclusive Cactuar population.",
    "\\C[4]Fisherman's Horizon\\C[0] boasts the largest population of Al Bhed on Gaia.",
    "The \\C[4]Mt. Bervenia\\C[0] volcano has been dormant for the last fifty years.",
    "Rumors tell of a gifted sculptress who can make her creations come to life.",
    ]
    
    #Text scroll direction, 0 = Right to Left, 1 = Left to Right
    DIRECTION = 0
    #Scroll speed, higher numbers = faster scrolling
    SPEED = 2
    #0 = Normal Window, 1 = Dim Background, 2 = Transparent, 3 = Custom Image
    BACKGROUND = 1
    #Custom image filename, put it in Graphics/System folder
    IMAGE_FILENAME = "DYK Backdrop"
    #Dim background colors
    DIM_COLOR = [[0,0,0],[0,0,0,160]]
    #Window position [X,Y]
    POSITION = [0,360]
    #Window size [width, height]
    SIZE = [640,48]
    #Text font
    TEXT_FONT = "Prototype"
    #Text size
    TEXT_SIZE = 20
  end
end

$imported = {} if $imported.nil?
$imported["DHDYKMarquee"] = true

class Window_Marquee < Window_Base
  include Dhoom::DYKMarquee
  attr_accessor :background
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @background = BACKGROUND
    self.arrows_visible = false
    self.opacity = 0 if @background != 0
    refresh
  end
  
  def refresh
    create_back_bitmap
    create_back_sprite
    draw_dyk_text
  end
  
  def create_back_bitmap
    if @background == 3
      @back_bitmap = Cache.system(IMAGE_FILENAME)
    else
      @back_bitmap = Bitmap.new(width, height)
      rect1 = Rect.new(0, 0, width, 12)
      rect2 = Rect.new(0, 12, width, height - 24)
      rect3 = Rect.new(0, height - 12, width, 12)    
      back_color1 = Color.new(DIM_COLOR[0][0],DIM_COLOR[0][1],DIM_COLOR[0][2],!DIM_COLOR[0][3].nil? ? DIM_COLOR[0][3] : 255)
      back_color2 = Color.new(DIM_COLOR[1][0],DIM_COLOR[1][1],DIM_COLOR[1][2],!DIM_COLOR[1][3].nil? ? DIM_COLOR[1][3] : 255)
      @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
      @back_bitmap.fill_rect(rect2, back_color1)
      @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
    end
  end
  
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    update_back_sprite
  end
  
  def draw_dyk_text
    random = rand(TEXTS.size)
    text = convert_escape_characters(TEXTS[random])
    dyk_reset_font_settings
    w = contents.text_size(text)
    create_contents([w.width, contents_height])
    dyk_reset_font_settings
    draw_text_ex(0, 0, TEXTS[random])
    self.ox =  -(self.width - contents.width) if DIRECTION == 0
  end
  
  def create_contents(rect = [])    
    contents.dispose
    if rect.empty?
      if contents_width > 0 && contents_height > 0
        self.contents = Bitmap.new(contents_width, contents_height)
      else
        self.contents = Bitmap.new(1, 1)
      end
    else
      self.contents = Bitmap.new(rect[0], rect[1])
    end
    contents.sfont = $sfont[0] if $imported[:ve_sfonts] && VE_ALL_SFONT
  end
  
  def dyk_reset_font_settings
    change_color(normal_color)
    contents.font = Font.new(TEXT_FONT)
    contents.font.size = TEXT_SIZE
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
  end
  
  def process_draw_icon(icon_index, pos)
    draw_icon(icon_index, pos[:x], pos[:y]+(contents.font.size-24)/2)
    pos[:x] += 24
  end
  
  def update
    super
    update_back_sprite
    update_scroll
  end
  
  def update_back_sprite
    @back_sprite.visible = [1,3].include?(@background)
    @back_sprite.z = z - 1
    @back_sprite.x = x
    @back_sprite.y = y
  end
  
  def update_scroll
    if DIRECTION == 0
      self.ox += SPEED
      if self.ox >= contents.width
        self.ox = -self.width
      end
    else      
      self.ox -= SPEED
      if self.ox <= -self.width
        self.ox = contents.width
      end
    end
  end
  
  def dispose
    super
    @back_sprite.dispose
  end
end

class Scene_Title < Scene_Base
  include Dhoom::DYKMarquee
  alias dhoom_marquee_scntitle_start start
  def start
    dhoom_marquee_scntitle_start
    @marquee_window = Window_Marquee.new(POSITION[0], POSITION[1], SIZE[0], SIZE[1])
  end
end