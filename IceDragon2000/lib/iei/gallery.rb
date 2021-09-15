#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Gallery"
#-define HDR_GDC :dc=>"05/17/2012"
#-define HDR_GDM :dm=>"05/17/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/gallery', '1.0.0', 'IEI Loginix'
#-include ASMxROOT . "/header/standalone_header.rb"
#-inject gen_module_header "IEI::Gallery"
module IEI
  module Gallery
    # // Do not modify
    class CG
      class << self
        alias :[] :new
      end
      FUNC_TRUE   = proc { true }
      FUNC_SWITCH = proc { switch?(@switch_id) }

      attr_accessor :id, :name, :filenames, :switch_id

      def initialize id,name,filenames,switch_id=nil,&block
        @id,@name,@filenames,@switch_id = id,name,Array(filenames),switch_id
        init_condition &block
      end

      def size
        @filenames.size
      end

      def init_condition &block
        @condition = block_given? ? block : (@switch_id ? FUNC_SWITCH : FUNC_TRUE)
      end

      def switch? id
        $game.switches[id]
      end

      def condition_met?
        instance_exec &@condition #rescue true
      end
    end
    # // Edit Here
    @sets = {}
    class << self
      attr_reader :sets
    end
    # // CG[id,"CG-Name","filename"]
    # // CG[id,"CG-Name","filename",switch_id]
    # // CG[id,"CG-Name",["filename","filename","filename"],switch_id]
  end
end
#-inject gen_class_header "IEI::Sprite::CG"
class IEI::Sprite::CG < Sprite
  def initialize viewport=nil,cg=nil
    super viewport
    self.cg = cg
  end
  attr_reader :cg
  def cg= new_cg
    @cg = new_cg
    @index = 0
    update_bitmap
  end
  def update_bitmap
    self.bitmap = @cg ? Cache.picture(@cg.filenames[@index]) : nil
  end
  def update
    last_index = index
    super
    update_handler
    Sound.play_cursor if last_index != index
  end
  def update_handler
    return unless active?
    return call_handler(:next) if Input.trigger?(:DOWN) or Input.trigger?(:RIGHT)
    return call_handler(:prev) if Input.trigger?(:UP) or Input.trigger?(:LEFT)
    return call_handler(:ok) if Input.trigger?(:C)
    return call_handler(:cancel) if Input.trigger?(:B)
  end
  # // Edits
  def index= n
    @index = n.to_i
    @index %= [item_max,1].max
    update_bitmap
  end
  def item_max
    @cg ? @cg.filenames.size : 0
  end
#-2include ASMxROOT/inc/indexing.rb
#-2include ASMxROOT/inc/passive_state.rb
#-2include ASMxROOT/inc/visibility.rb
#-2include ASMxROOT/inc/basic_handler.rb
end
#-inject gen_class_header "IEI::Window::Gallery_Set"
class IEI::Window::Gallery_Set < Window::Selectable
  def initialize x,y,w,h
    make_item_list
    super
    activate.select 0
    refresh
  end
  attr_reader :cg_window
  def cg_window= window
    @cg_window = window
    update_cg_window
  end
  def index= n
    super
    update_cg_window
  end
  def update_cg_window
    @cg_window.set = IEI::Gallery.sets[self.item] if @cg_window
  end
  def item i=self.index
    @items[i]
  end
  def make_item_list
    @items = IEI::Gallery.sets.keys.sort
  end
  def item_max
    @items.size
  end
  def draw_item index
    #rect  = item_rect(index)
    trect = item_rect_for_text index
    str   = @items[index]
    draw_text trect,str
  end
end
#-inject gen_class_header "IEI::Window::Gallery_CGs"
class IEI::Window::Gallery_CGs < Window::Selectable
  def initialize x,y,w,h
    @set = []
    make_item_list
    super
    select 0
    refresh
  end
  attr_reader :set
  def set= set
    @set = set
    make_item_list
    refresh
  end
  def cg i=index
    @set[i]
  end
  def make_item_list
    @items = @set.sort_by{|cg|cg.id}.map{|cg|
      [cg.filenames,cg.condition_met?]
    }
  end
  def item_max
    @items.size
  end
  def item_width
    self.width / col_max - spacing
  end
  def item_height
    (item_width * 0.75).to_i
  end
  def spacing
    2
  end
  def col_max
    4
  end
  BLANK_BMP = Bitmap.new 128,96
  def draw_item index
    rect   = item_rect index
    item_a = @items[index]
    bmp_fn,valid = item_a[0].first, item_a[1]
    bmp    = Cache.picture bmp_fn rescue BLANK_BMP
    unless valid
      contents.fill_rect rect, Color.new(48,48,48,128)
    else
      source, target = bmp.rect, rect
      w,h = source.width, source.height
      if w > h ; scale = target.width.to_f / w
      else     ; scale = target.height.to_f / h
      end
      srect = source.dup;r.width,r.height=(w*scale).to_i,(h*scale).to_i;r
      srect.x += (rect.width - srect.width) / 2
      srect.y += (rect.height - srect.height) / 2
      contents.stretch_blt srect, bmp, bmp.rect
    end
  end
  def current_item_enabled?
    return false unless @items[self.index]
    @items[self.index][1]
  end
end
#-inject gen_class_header "IEI::Scene::Gallery"
class IEI::Scene::Gallery < Scene::Base
  # // Scene::Base
  def start
    super
    #create_background if respond_to? :create_background
    create_all_windows
    create_sprites
    auto_window_manager.adds if $imported["EDOS::Data"]
  end
  def terminate
    super
    #dispose_background if respond_to? :dispose_background
    @cg_sprite.dispose unless @cg_sprite
  end
  def update
    super
    #update_background if respond_to? :update_background
    @cg_sprite.update
  end
  # // Create
  def create_all_windows
    create_set_window
    create_cg_window
  end
  def create_sprites
    @cg_sprite = IEI::Sprite::CG.new @viewport
    @cg_sprite.set_handler :next  , method(:next_cg_image)
    @cg_sprite.set_handler :prev  , method(:prev_cg_image)
    @cg_sprite.set_handler :ok    , method(:end_cg_view)
    @cg_sprite.set_handler :cancel, method(:end_cg_view)
    @cg_sprite.hide
    @cg_sprite.z = 201
  end
  # // Windows
  def create_set_window
    @set_window = IEI::Window::Gallery_Set.new(0,0,(Graphics.width*0.25).to_i,Graphics.height)
    @set_window.set_handler :cancel, method(:return_scene)
    @set_window.set_handler :ok    , method(:start_cg_selection)
    #window_manager.add @set_window
  end
  def create_cg_window
    x = @set_window.x + @set_window.width
    w = Graphics.width - x
    h = @set_window.height
    @cg_window = IEI::Window::Gallery_CGs.new(x,0,w,h)
    @cg_window.set_handler :ok    , method(:start_cg_view)
    @cg_window.set_handler :cancel, method(:start_set_selection)
    @set_window.cg_window = @cg_window
    #window_manager.add @cg_window
  end
  # // Sprites
  # // Nothing here but us whitespace
  # // Commands
  def start_set_selection
    @set_window.activate
  end
  def start_cg_selection
    @cg_window.activate
  end
  def end_cg_selection
    @set_window.activate
  end
  def start_cg_view
    @cg_sprite.activate.show
    @cg_sprite.cg = @cg_window.cg
    @cg_sprite.x = (Graphics.width - @cg_sprite.width) / 2
    @cg_sprite.y = (Graphics.height - @cg_sprite.height) / 2
    @cg_window.deactivate.close
    @set_window.deactivate.close
  end
  def end_cg_view
    @cg_sprite.deactivate.hide
    @cg_window.activate.open
    @set_window.deactivate.open
  end
  def next_cg_image
    if @cg_sprite.index < @cg_sprite.item_max
      @cg_sprite.next
    else
      Sound.play_buzzer
    end
  end
  def prev_cg_image
    if @cg_sprite.index > 0
      @cg_sprite.prev
    else
      Sound.play_buzzer
    end
  end
end
Scene_Gallery = IEI::Scene::Gallery
#-inject gen_script_footer
