# ★ Screenshot taker
# ★★★★★★★★★★★★★★★★★★★★★★★
#
# Author/s : cremno
# RGSS ver : 3.0.0, 3.0.1

module Screenshot
    # ↓ OPTIONS
    # key symbol or constant (help file -> (Index ->) Input -> Constants)
    KEY = :F5
    # SE filename (Sound Test ♬) (is played after the image has been saved)
    SE = 'Sheep'
    # image file format (:bmp, :jpg, :gif, :tiff or :png)
    FORMAT = :png
    # directory name
    DIRECTORY = 'Screenshots'
    # file name
    FILENAME = 'Screenshot'
    # ↑ OPTIONS
  
    def self.play_se
      RPG::SE.new(Screenshot::SE).play
    end
  
    def self.filename
      Dir.exist?(DIRECTORY) || Dir.mkdir(DIRECTORY)
      sprintf('%s/%s (%f).%s', DIRECTORY, FILENAME, Time.now.to_f, FORMAT)
    end
  
  end
  
  class Bitmap
  
    def save(filename)
      ext = File.extname(filename)[1..-1]
      if ext.empty?
        warn "Bitmap#save: filename doesn't have an extension (fallback to PNG)"
        ext = :png
        filename << '.png'
      else
        ext = ext.to_sym
      end
      retval = false
      bitmap = Gdiplus::Bitmap.new(:scan0, width, height, scan0)
      if bitmap
        retval = bitmap.save(:file, filename, ext)
        bitmap.dispose
      end
      retval
    end
  
    private
  
    def _data_struct(offset = 0)
      @_data_struct ||= (DL::CPtr.new((object_id << 1) + 16).ptr + 8).ptr
      (@_data_struct + offset).ptr.to_i
    end
  
    def gdidib
      @gdidib ||= [_data_struct(8), _data_struct(16)]
    end
  
    def hbitmap
      @hbitmap ||= _data_struct(44)
    end
  
    def scan0
      @scan0 ||= _data_struct(12)
    end
  
  end
  
  class << Graphics
  
    alias_method :update_wo_screenshot, :update
  
    def update
      Input.trigger?(Screenshot::KEY) &&
        Graphics.snap_to_bitmap.save(Screenshot.filename) &&
          Screenshot.play_se
      update_wo_screenshot
    end
  
  end
  
  # ★ Windows Wide Char Management
  # ★★★★★★★★★★★★★★★★★★★★★★★
  #
  # Author/s : cremno
  # RGSS ver : 3.0.0, 3.0.1
  
  class Encoding
  
    UTF_8 ||= find('UTF-8')
  
    UTF_16LE ||= find('UTF-16LE')
  
  end
  
  class String
  
    unless method_defined?(:widen)
      def widen
        (self + "\0").encode(Encoding::UTF_16LE)
      end
    end
  
    unless method_defined?(:widen!)
      def widen!
        self << "\0"
        encode!(Encoding::UTF_16LE)
      end
    end
  
    unless method_defined?(:narrow)
      def narrow
        chomp("\0").encode(Encoding::UTF_8)
      end
    end
  
    unless method_defined?(:narrow!)
      def narrow!
        chomp!("\0")
        encode!(Encoding::UTF_8)
      end
    end
  
  end
  
  # ★ GDI+ interface
  # ★★★★★★★★★★★★★★★★★★★★★★★
  #
  # Author/s : cremno
  # RGSS ver : 3.0.0, 3.0.1
  
  module Gdiplus
  
    class GdiplusError < StandardError
    end
  
    DLL = DL.dlopen('gdiplus')
  
    FUNCTIONS = {}
    {
      'GdiplusStartup' => DL::TYPE_INT,
      'GdiplusShutdown' => DL::TYPE_VOID,
      'GdipDisposeImage' => DL::TYPE_INT,
      'GdipSaveImageToFile' => DL::TYPE_INT,
      'GdipCreateBitmapFromGdiDib' => DL::TYPE_INT,
      'GdipCreateBitmapFromHBITMAP' => DL::TYPE_INT,
      'GdipCreateBitmapFromScan0' => DL::TYPE_INT
    }.each do |name, type|
      FUNCTIONS[name.to_sym] = DL::CFunc.new(DLL[name], type, name, :stdcall)
    end
  
    CLSIDS = {}
    dll = DL.dlopen('ole32')
    name = 'CLSIDFromString'
    func = DL::CFunc.new(dll[name], DL::TYPE_LONG, name, :stdcall)
    {
      bmp: '{557cf400-1a04-11d3-9a73-0000f81ef32e}'.widen!,
      jpg: '{557cf401-1a04-11d3-9a73-0000f81ef32e}'.widen!,
      gif: '{557cf402-1a04-11d3-9a73-0000f81ef32e}'.widen!,
      tif: '{557cf405-1a04-11d3-9a73-0000f81ef32e}'.widen!,
      png: '{557cf406-1a04-11d3-9a73-0000f81ef32e}'.widen!
    }.each do |format, string|
      clsid = "\0" * 16
      func.call([DL::CPtr[string].to_i, DL::CPtr[clsid].to_i])
      CLSIDS[format] = clsid
    end
    CLSIDS[:jpeg] = CLSIDS[:jpg]
    CLSIDS[:tiff] = CLSIDS[:tif]
  
    @token = "\0" * DL::SIZEOF_VOIDP
  
    def self.token
      @token
    end
  
    # TODO: prepend prefix (Gdip or Gdiplus) automatically
    def self.call(*args)
      name = args.shift
      args.map! { |e| DL::CPtr[e].to_i }
      r = FUNCTIONS[name].call(args)
      if r && r != 0
        fail GdiplusError,
          "Status: #{v}\nFunction: #{name}\nArguments: #{args.inspect}"
      end
      true
    end
  
    def self.startup
      input = [1].pack('L')             # GdiplusVersion
      input << "\0" * DL::SIZEOF_VOIDP  # DebugEventCallback
      input << "\0" * DL::SIZEOF_INT    # SuppressBackgroundThread
      input << "\0" * DL::SIZEOF_INT    # SuppressExternalCodecs
      call(:GdiplusStartup, @token, input, 0)
    end
  
    def self.shutdown
      call(:GdiplusShutdown, @token)
    end
  
    class Image
  
      attr_reader :instance
  
      def initialize
        @instance = 0
        true
      end
  
      def save(destination, *args)
        case destination
        when :file
          filename = args.shift.widen!
          argv = [:GdipSaveImageToFile, filename, Gdiplus::CLSIDS[args.shift], 0]
        else
          fail ArgumentError, "unknown GDI+ image destination: #{source}"
        end
        argv.insert(1, @instance)
        Gdiplus.call(*argv)
      end
  
      def dispose
        Gdiplus.call(:GdipDisposeImage, @instance)
      end
  
    end
  
    class Bitmap < Image
  
      def initialize(source, *args)
        case source
        when :gdidib
          argv = [:GdipCreateBitmapFromGdiDib, args.shift, args.shift]
        when :hbitmap
          argv = [:GdipCreateBitmapFromHBITMAP, args.shift, 0]
        when :scan0
          w = args.shift
          h = args.shift
          stride = w * -4    # BGRA, mirrored
          format = 0x26200A  # PixelFormat32bppARGB
          scan0 = args.shift
          argv = [:GdipCreateBitmapFromScan0, w, h, stride, format, scan0]
        else
          fail ArgumentError, "unknown GDI+ bitmap source: #{source}"
        end
        argv << "\0" * DL::SIZEOF_VOIDP
        r = Gdiplus.call(*argv)
        @instance = r ? argv[-1].unpack(DL::SIZEOF_VOIDP == 4 ? 'L' : 'Q')[0] : 0
        r
      end
  
    end
  
  end
  
  Gdiplus.startup
  class << SceneManager
    alias_method :exit_wo_gdip_shutdown, :exit
    def exit
      exit_wo_gdip_shutdown
      Gdiplus.shutdown
    end
  end