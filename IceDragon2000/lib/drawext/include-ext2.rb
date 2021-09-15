module DrawExt::Include
  def self.repeat_header_bmp_vert( info )
    bitmap        = info[:bitmap]
    dbmp          = info[:draw_bmp]
    x, y          = info[:x] || 0, info[:y] || 0
    width         = info[:width] || (bitmap ? bitmap.width : 24)
    height        = info[:height] || (bitmap ? bitmap.height : 48)
    startrect     = info[:startrect] || Rect.new( 0, 0, width, 32 )
    endrect       = info[:endrect] || Rect.new( 0, dbmp.height-32, width, 32 )
    midrect       = info[:midrect] || Rect.new( 0, 32, width, 32 )
    opacity       = info[:opacity] || 255
    bitmap.blt( x, y, dbmp, startrect, opacity )
    bitmap.blt( x, y+(height-endrect.height), dbmp, endrect, opacity )
    dx, dy = x, y+startrect.height
    dh = height - (startrect.height + endrect.height)
    bitmap.ext_repeat_bmp_vert(
      :x => dx, :y => dy, :length => dh,
      :draw_bmp => dbmp, :rect => midrect, :opacity => opacity
    )
  end

  def self.repeat_header_bmp_horz( info )
    bitmap        = info[:bitmap]
    dbmp          = info[:draw_bmp]
    x, y          = info[:x] || 0, info[:y] || 0
    width         = info[:width] || (bitmap ? bitmap.width : 48)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    startrect     = info[:startrect] || Rect.new( 0 , 0, 32, height )
    endrect       = info[:endrect] || Rect.new( dbmp.width-32,  0, 32, height )
    midrect       = info[:midrect] || Rect.new( 32, 0, 32, height )
    opacity       = info[:opacity] || 255
    bitmap.blt( x, y, dbmp, startrect, opacity )
    bitmap.blt( x+(width-endrect.width), y, dbmp, endrect, opacity )
    dx, dy = x+startrect.width, y
    dw = width - (startrect.width + endrect.width)
    bitmap.ext_repeat_bmp_horz(
      :x => dx, :y => dy, :length => dw,
      :draw_bmp => dbmp, :rect => midrect, :opacity => opacity
    )
  end

  def self.draw_slider_base_vert( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 24)
    height        = info[:height] || (bitmap ? bitmap.height : 48)
    base_bmp      = info[:base_bmp] || Cache.system("gui_slider1")
    height = 8 if height < 8
    hg = height <= 48 ? height / 2 : 24
    repeat_header_bmp_vert(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp,
      :startrect => Rect.new( 0,  0, width, hg ),
      :endrect   => Rect.new( 0, 72-hg, width, hg ),
      :midrect   => Rect.new( 0, 24, width, 24 )
    )
  end

  def self.draw_slider_base_horz( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 48)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    base_bmp      = info[:base_bmp] || Cache.system("gui_slider2")
    width = 8 if width < 8
    wd = width <= 48 ? width / 2 : 24
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp,
      :startrect => Rect.new( 0 , 0, wd, height ),
      :endrect   => Rect.new( 72-wd,  0, wd, height ),
      :midrect   => Rect.new( 24, 0, 24, height )
    )
  end

  def self.draw_header_base( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 128)
    height        = info[:height] || (bitmap ? bitmap.height : 14)
    base_bmp      = info[:base_bmp] || Cache.system("header_base(window)")
    height = height.min(base_bmp.height)
    width  = base_bmp.width if width < base_bmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp
    )
  end

  def self.draw_equip_header_base( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 128)
    height        = info[:height] || (bitmap ? bitmap.height : 38)
    base_bmp      = info[:base_bmp] || Cache.system("equipment_tab(window)")
    height = height.min(base_bmp.height)
    width  = base_bmp.width if width < base_bmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp
    )
  end

  # // 02/03/2012
  def self.draw_help_header( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 128)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    base_bmp      = info[:base_bmp] || Cache.system("header_help(sprite)")
    height = height.min(base_bmp.height)
    #width  = guibmp.width if width < guibmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :startrect => Rect.new( 0, 0, 8,base_bmp.height),
      :midrect   => Rect.new( 8, 0,80,base_bmp.height),
      :endrect   => Rect.new(96-8,0,8,base_bmp.height),
      :draw_bmp  => base_bmp
    )
  end

  # // 02/06/2012
  def self.draw_option_header( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 172)
    height        = info[:height] || (bitmap ? bitmap.height : 14)
    base_bmp      = info[:base_bmp] || Cache.system("header_options(window)")
    height = height.min(base_bmp.height)
    #width  = guibmp.width if width < guibmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :startrect => Rect.new( 0, 0,32,base_bmp.height),
      :midrect   => Rect.new(32, 0,32,base_bmp.height),
      :endrect   => Rect.new(64, 0,64,base_bmp.height),
      :draw_bmp  => base_bmp
    )
  end

  def self.draw_tab( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 96)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    base_bmp      = info[:base_bmp] || Cache.system("header_tab(sprite)")
    height = height.min(base_bmp.height)
    #width  = guibmp.width if width < guibmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp
    )
  end

  def self.draw_tail_base( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 128)
    height        = info[:height] || (bitmap ? bitmap.height : 14)
    base_bmp      = info[:base_bmp] || Cache.system("tail_Base(window)")
    height = height.min(base_bmp.height)
    width  = base_bmp.width if width < base_bmp.width
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :draw_bmp  => base_bmp
    )
  end

  # // 02/18/2012
  def self.draw_skill_border( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 172)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    base_bmp      = info[:base_bmp] || Cache.system("skill_borders(window)")
    height = height.min(24)
    #width  = guibmp.width if width < guibmp.width
    dy = 24 * (info[:index] || 0)
    dh = 24
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :startrect => Rect.new( 0, dy,40,dh),
      :midrect   => Rect.new(40, dy,42,dh),
      :endrect   => Rect.new(82, dy,30,dh),
      :draw_bmp  => base_bmp,
      :opacity   => info[:opacity] || 255
    )
  end

  # // 02/25/2012
  def self.draw_art_border( info )
    bitmap        = info[:bitmap]
    width         = info[:width] || (bitmap ? bitmap.width : 96)
    height        = info[:height] || (bitmap ? bitmap.height : 24)
    base_bmp      = info[:base_bmp] || Cache.system("art_border(window)")
    height = height.min(24)
    #width  = guibmp.width if width < guibmp.width
    dy = 0
    dh = 24
    repeat_header_bmp_horz(
      :bitmap    => bitmap,
      :x => info[:x], :y => info[:y],
      :width     => width,
      :height    => height,
      :startrect => Rect.new( 0, dy,24,dh),
      :midrect   => Rect.new(24, dy,48,dh),
      :endrect   => Rect.new(72, dy,24,dh),
      :draw_bmp  => base_bmp,
      :opacity   => info[:opacity] || 255
    )
  end
end
