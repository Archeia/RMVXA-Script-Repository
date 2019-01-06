# Bitmap Export v5.4 for XP, VX and VXace by Zeus81
# Free for commercial use
# Licence : http://creativecommons.org/licenses/by/4.0/
# Contact : zeusex81@gmail.com
# How to Use :
#   - exporting bitmap :
#       bitmap.export(filename)
#    or bitmap.save(filename)
#
#   - serialize bitmap :
#       open(filename, 'wb') {|file| Marshal.dump(bitmap, file)}
#       bitmap = open(filename, 'rb') {|file| Marshal.load(file)}
#   or
#       save_data(bitmap, filename)
#       bitmap = load_data(filename)
#
#  - snapshot :
#      Graphics.export(filename)
#   or Graphics.save(filename)
#   or Graphics.snapshot(filename)
#   Here filename is optional, and will be replaced by datetime if omitted. 

$imported ||= {}
$imported[:Zeus_Bitmap_Export] = __FILE__

def xp?() false end; alias vx? xp?; alias vxace? xp?
RUBY_VERSION == '1.8.1' ? defined?(Hangup) ?
def xp?() true  end : def vx?() true  end : def vxace?() true  end

class String
  alias getbyte  []
  alias setbyte  []=
  alias bytesize size
end unless vxace?

class Font
  def marshal_dump()     end
  def marshal_load(dump) end
end

class Bitmap
  RtlMoveMemory = Win32API.new('kernel32', 'RtlMoveMemory', 'ppi', 'i')
  def last_row_address
    return 0 if disposed?
    RtlMoveMemory.call(buf=[0].pack('L'), __id__*2+16, 4)
    RtlMoveMemory.call(buf, buf.unpack('L')[0]+8 , 4)
    RtlMoveMemory.call(buf, buf.unpack('L')[0]+16, 4)
    buf.unpack('L')[0]
  end
  def bytesize
    width * height * 4
  end
  def get_data
    data = [].pack('x') * bytesize
    RtlMoveMemory.call(data, last_row_address, data.bytesize)
    data
  end
  def set_data(data)
    RtlMoveMemory.call(last_row_address, data, data.bytesize)
  end
  def get_data_ptr
    data = String.new
    RtlMoveMemory.call(data.__id__*2, [vxace? ? 0x6005 : 0x2007].pack('L'), 4)
    RtlMoveMemory.call(data.__id__*2+8, [bytesize,last_row_address].pack('L2'), 8)
    def data.free() RtlMoveMemory.call(__id__*2, String.new, 16) end
    return data unless block_given?
    yield data ensure data.free
  end
  def _dump(level)
    get_data_ptr do |data|
      dump = Marshal.dump([width, height, Zlib::Deflate.deflate(data, 9)])
      dump.force_encoding('UTF-8') if vxace?
      dump
    end
  end
  def self._load(dump)
    width, height, data = *Marshal.load(dump)
    data.replace(Zlib::Inflate.inflate(data))
    bitmap = new(width, height)
    bitmap.set_data(data)
    bitmap
  end
  def export(filename)
    case format=File.extname(filename)
    when '.bmp'; export_bmp(filename)
    when '.png'; export_png(filename)
    when ''    ; export_png("#{filename}.png")
    else         print("Export format '#{format}' not supported.")
    end
  end
  alias save export
  def export_bmp(filename)
    get_data_ptr do |data|
      File.open(filename, 'wb') do |file|
        file.write(['BM',data.bytesize+54,0,54,40,width,height,
                    1,32,0,data.bytesize,0,0,0,0].pack('a2L6S2L6'))
        file.write(data)
      end
    end
  end
  def export_png(filename)
    data, i = get_data, 0
    if vxace?
      (0).step(data.bytesize-4, 4) do |i|
        byte2 = data.getbyte(i)
        data.setbyte(i, data.getbyte(i+2))
        data.setbyte(i+2, byte2)
      end
    else
      (0).step(data.bytesize-4, 4) do |i|
        data[i,3] = data[i,3].reverse!
      end
    end
    deflate = Zlib::Deflate.new(9)
      null_char, w4 = [].pack('x'), width*4
      (data.bytesize-w4).step(0, -w4) {|i| deflate << null_char << data[i,w4]}
      data.replace(deflate.finish)
    deflate.close
    File.open(filename, 'wb') do |file|
      def file.write_chunk(chunk)
        write([chunk.bytesize-4].pack('N'))
        write(chunk)
        write([Zlib.crc32(chunk)].pack('N'))
      end
      file.write("\211PNG\r\n\32\n")
      file.write_chunk(['IHDR',width,height,8,6,0,0,0].pack('a4N2C5'))
      file.write_chunk(data.insert(0, 'IDAT'))
      file.write_chunk('IEND')
    end
  end
end

module Graphics
  if xp?
    FindWindow             = Win32API.new('user32', 'FindWindow'            , 'pp'       , 'i')
    GetDC                  = Win32API.new('user32', 'GetDC'                 , 'i'        , 'i')
    ReleaseDC              = Win32API.new('user32', 'ReleaseDC'             , 'ii'       , 'i')
    BitBlt                 = Win32API.new('gdi32' , 'BitBlt'                , 'iiiiiiiii', 'i')
    CreateCompatibleBitmap = Win32API.new('gdi32' , 'CreateCompatibleBitmap', 'iii'      , 'i')
    CreateCompatibleDC     = Win32API.new('gdi32' , 'CreateCompatibleDC'    , 'i'        , 'i')
    DeleteDC               = Win32API.new('gdi32' , 'DeleteDC'              , 'i'        , 'i')
    DeleteObject           = Win32API.new('gdi32' , 'DeleteObject'          , 'i'        , 'i')
    GetDIBits              = Win32API.new('gdi32' , 'GetDIBits'             , 'iiiiipi'  , 'i')
    SelectObject           = Win32API.new('gdi32' , 'SelectObject'          , 'ii'       , 'i')
    def self.snap_to_bitmap
      bitmap  = Bitmap.new(width, height)
      info    = [40,width,height,1,32,0,0,0,0,0,0].pack('LllSSLLllLL')
      hDC     = GetDC.call(hwnd)
      bmp_hDC = CreateCompatibleDC.call(hDC)
      bmp_hBM = CreateCompatibleBitmap.call(hDC, width, height)
      bmp_obj = SelectObject.call(bmp_hDC, bmp_hBM)
      BitBlt.call(bmp_hDC, 0, 0, width, height, hDC, 0, 0, 0xCC0020)
      GetDIBits.call(bmp_hDC, bmp_hBM, 0, height, bitmap.last_row_address, info, 0)
      SelectObject.call(bmp_hDC, bmp_obj)
      DeleteObject.call(bmp_hBM)
      DeleteDC.call(bmp_hDC)
      ReleaseDC.call(hwnd, hDC)
      bitmap
    end
  end
  class << self
    def hwnd() @hwnd ||= FindWindow.call('RGSS Player', nil) end
    def width()  640 end unless method_defined?(:width)
    def height() 480 end unless method_defined?(:height)
    def export(filename=Time.now.strftime("snapshot %Y-%m-%d %Hh%Mm%Ss #{frame_count}"))
      bitmap = snap_to_bitmap
      bitmap.export(filename)
      bitmap.dispose
    end
    alias save     export
    alias snapshot export
  end
end