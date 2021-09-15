#
# EDOS/lib/drawext/const.rb
#
module DrawExt
  enum = Enumerator.new do |yielder|
    n = 0
    loop do
      yielder.yield n
      n += 1
    end
  end

  STYLE_HARSH = enum.next
  STYLE_SOFT  = enum.next
  STYLE_HARD  = enum.next
  STYLE_5P    = enum.next
  STYLE_10P   = enum.next
  STYLE_15P   = enum.next
  STYLE_25P   = enum.next
  STYLE_33P   = enum.next
  STYLE_50P   = enum.next
  STYLE_66P   = enum.next
  STYLE_75P   = enum.next
  STYLE_80P   = enum.next
  STYLE_100P  = enum.next
  STYLE_RK    = enum.next
  STYLE_RK4   = enum.next

  STYLE_FALLBACK = STYLE_HARSH
  STYLE_DEFAULT  = STYLE_SOFT

  self_add = ->(c, ps, _) { c.blend.self_add(*ps) }
  self_sub = ->(c, ps, _) { c.blend.self_subtract(*ps) }

  STYLER_HARSH = Styler.new(STYLE_HARSH, [self_add, [0.33]],
                                         [self_sub, [0.25]],
                                         nil,
                                         [self_sub, [0.42]])

  STYLER_SOFT  = Styler.new(STYLE_SOFT , [self_add, [0.13]],
                                         [self_sub, [0.05]],
                                         nil,
                                         [self_sub, [0.16]])

  STYLER_HARD  = Styler.new(STYLE_HARD , [self_add, [0.53]],
                                         [self_sub, [0.45]],
                                         nil,
                                         [self_sub, [0.62]])

  [5, 10, 15, 25, 33, 50, 66, 75, 80, 100].each do |num|
    flt = num / 100.0
    const_set("STYLER_#{num}P", Styler.new(STYLE_25P , [self_add, [flt ]],
                                                       nil,
                                                       [self_sub, [flt * 0.5]],
                                                       [self_sub, [flt ]]))
  end

  STYLER_RK = Styler.new(STYLE_RK) do |c0, *args|
    stack, delta = *args
    stack ||= Styler.styler(STYLE_FALLBACK).stack.dup
    delta ||= 0.5

    enum = stack.to_enum
    c1 = (n = enum.next) ? n[0].(c0, [n[1][0] * delta], nil) : c0
    c2 = (n = enum.next) ? n[0].(c1, [n[1][0] * delta], nil) : c1
    c3 = (n = enum.next) ? n[0].(c2, [n[1][0] * delta], nil) : c2
    c4 = (n = enum.next) ? n[0].(c3, [n[1][0] * delta], nil) : c3

    [c1, c2, c3, c4]
  end

  STYLER_RK4 = Styler.new(STYLE_RK4) do |c0, *args|
    stack, delta = *args
    stack ||= Styler.styler(STYLE_FALLBACK).stack.dup
    delta ||= 0.5

    enum = stack.to_enum
    c1 = (n = enum.next) ? n[0].(c0, [n[1][0]],               nil) : c0 #c0.send(n[0],               n[1][0]) : c0
    c2 = (n = enum.next) ? n[0].(c1, [n[1][0] * delta * 0.5], nil) : c1 #c1.send(n[0], n[1][0] * delta * 0.5) : c1
    c3 = (n = enum.next) ? n[0].(c2, [n[1][0] * delta * 0.5], nil) : c2 #c2.send(n[0], n[1][0] * delta * 0.5) : c2
    c4 = (n = enum.next) ? n[0].(c3, [n[1][0] * delta],       nil) : c3 #c3.send(n[0],       n[1][0] * delta) : c3

    [c1, c2, c3, c4]
  end

  ### depreceated
  DEF_BAR_COLORS = {
    base_outline1:  Color.new(  28,  28,  28, 255 ),
    base_outline2:  Color.new(  28,  28,  28, 255 ),
    base_inline1:   Color.new(  71,  71,  71, 255 ),
    base_inline2:   Color.new(  61,  61,  61, 255 ),

    bar_outline1:   Color.new( 117, 205,  85, 255 ).blend.median!,
    bar_outline2:   Color.new(  66, 154,  34, 255 ).blend.median!,
    bar_inline1:    Color.new(  91, 179,  59, 255 ).blend.median!,
    bar_inline2:    Color.new(  42, 130,  10, 255 ).blend.median!,

    bar_highlight:  Color.new( 255, 255, 255,  51 )
  }

  DEF_BAR_COLORS.merge!({
    base_outline1:  Color.new(0x5C, 0x41, 0x28),
    base_outline2:  Color.new(0x5C, 0x41, 0x28),
    base_inline1:   Color.new(0x81, 0x66, 0x4F),
    base_inline2:   Color.new(0x81, 0x66, 0x4F)
  })

  DEF_BAR_COLORS.merge!({
    base_outline1:  Color.new(0x22, 0x22, 0x22),
    base_outline2:  Color.new(0x22, 0x22, 0x22),
    base_inline1:   Color.new(0x33, 0x33, 0x33, 0xFF * 0.6),
    base_inline2:   Color.new(0x33, 0x33, 0x33, 0xFF * 0.6),
  })

  RED_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1: Color.new( 248,  98,  96, 255 ),
    bar_outline2: Color.new( 199,  52,  50, 255 ),
    bar_inline1:  Color.new( 224,  73,  71, 255 ),
    bar_inline2:  Color.new( 176,  34,  32, 255 ),
  })

  GREEN_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1: Color.new( 117, 205,  85, 255 ),
    bar_outline2: Color.new(  66, 154,  34, 255 ),
    bar_inline1:  Color.new(  91, 179,  59, 255 ),
    bar_inline2:  Color.new(  42, 130,  10, 255 ),
  })

  BLUE_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1: Color.new( 123, 176, 222, 255 ),
    bar_outline2: Color.new(  79, 122, 166, 255 ),
    bar_inline1:  Color.new(  95, 149, 208, 255 ),
    bar_inline2:  Color.new(  58,  97, 140, 255 ),
  })

  YELLOW_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1: Color.new( 246, 187,   3, 255 ),
    bar_outline2: Color.new( 194, 150,   3, 255 ),
    bar_inline1:  Color.new( 221, 169,   3, 255 ),
    bar_inline2:  Color.new( 168, 131,   3, 255 ),
  })

  ORANGE_BAR_COLORS = quick_bar_colors(Color.new(221, 72, 20), 0)

  DARK_PURPLE_BAR_COLORS = quick_bar_colors(Color.new(44, 0, 30), 0)

  KEYBOARD_BAR_COLORS = quick_bar_colors(Color.new(174, 167, 159), 0)
  KEYBOARD_BAR_COLORS.merge!(quick_base_colors_abs(Color.new( 70,  70,  70, 255), 1))

  RUBY_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1: Color.new( 253, 131, 113, 255 ).blend.self_subtract(0.2),
    bar_outline2: Color.new( 202,  62,  70, 255 ).blend.self_subtract(0.1),
    bar_inline1:  Color.new( 194,  55,  65, 255 ),
    bar_inline2:  Color.new( 107,  19,  43, 255 ),
  })

  METAL1_BAR_COLORS = DEF_BAR_COLORS.merge({
    #base_outline1:  Color.new(  36,  34,  30, 255 ),
    #base_outline2:  Color.new(  16,  15,  14, 255 ),
    #base_inline1:  Color.new(  95,  86,  69, 255 ).blend.self_subtract( 0.3 ),
    #base_inline2:  Color.new(  81,  71,  52, 255 ).blend.self_subtract( 0.3 ),
    bar_outline1:  Color.new( 158, 142, 104, 255 ).blend.self_add(0.1),
    bar_outline2:  Color.new( 108,  97,  72, 255 ).blend.self_subtract(0.2),
    bar_inline1:   Color.new( 255, 210, 129, 255 ).blend.self_subtract(0.2),
    bar_inline2:   Color.new( 176, 149,  99, 255 ).blend.self_subtract(0.5),
  })

  METAL2_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1:  Color.new(  89,  88,  83, 255 ).blend.self_add(0.7),
    bar_outline2:  Color.new(  48,  47,  43, 255 ).blend.self_add(0.7),
    bar_inline1:   Color.new( 225, 223, 212, 255 ),
    bar_inline2:   Color.new( 111, 108,  98, 255 ),
  })

  TRANS_BAR_COLORS = DEF_BAR_COLORS.dup
  #TRANS_BAR_COLORS.merge!(quick_base_colors_abs(Color.new( 70,  70,  70, 255), 1))
  TRANS_BAR_COLORS.merge!(
    base_inline1:  Color.new(  0,   0,   0,  25),
    base_inline2:  Color.new(  0,   0,   0,  25),
    bar_outline1:  Color.new( 70,  70,  70, 128),
    bar_outline2:  Color.new( 17,  17,  17, 128),
    bar_inline1:   Color.new(112, 112, 112,  96),
    bar_inline2:   Color.new( 70,  70,  70, 128),
  )

  BLACK_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1:  Color.new( 70,  70,  70, 255),
    bar_outline2:  Color.new( 17,  17,  17, 255),
    bar_inline1:   Color.new(112, 112, 112, 255),
    bar_inline2:   Color.new( 70,  70,  70, 255),
  })

  BLACK2_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1:  Color.new( 70,  70,  70, 255),
    bar_outline2:  Color.new( 54,  54,  54, 255),
    bar_inline1:   Color.new( 85,  85,  85, 255),
    bar_inline2:   Color.new( 70,  70,  70, 255),
    bar_highlight: Color.new(255, 255, 255,   0),
  })

  WHITE_BAR_COLORS = DEF_BAR_COLORS.merge({
    bar_outline1:  Color.new(194, 194, 194, 255),
    bar_outline2:  Color.new(161, 161, 161, 255),
    bar_inline1:   Color.new(226, 226, 226, 255),
    bar_inline2:   Color.new(194, 194, 194, 255)
  })

  #green_asparagus = Color.rgb24(0x87A96B)
  #green_forest = Color.rgb24(0x228B22)

  #blue_cataline = Color.rgb24(0x062A78)
  #blue_aqua = Color.rgb24(0x0087BD)

  EXP_BAR_COLORS = RUBY_BAR_COLORS
  HP1_BAR_COLORS = GREEN_BAR_COLORS
  HP2_BAR_COLORS = YELLOW_BAR_COLORS
  HP3_BAR_COLORS = RED_BAR_COLORS

  MP_BAR_COLORS  = BLUE_BAR_COLORS
  AP_BAR_COLORS  = quick_bar_colors(Color.new(153,   51,  204, 255), 2)
  WT_BAR_COLORS  = BLACK_BAR_COLORS

  if STYLE_FALLBACK == STYLE_DEFAULT
    raise 'STYLE_FALLBACK must not be the same as STYLE_DEFAULT'
  end
end
