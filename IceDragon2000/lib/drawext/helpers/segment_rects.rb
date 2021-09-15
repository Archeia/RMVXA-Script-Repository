#
# EDOS/lib/drawext/helpers/segment_rects.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc 27/03/2013
#   dm 27/03/2013
# vr 1.0.1
module DrawExt::Helper
  def self.seg_rects_zero
    return Array.new(9) do Rect.new(0, 0, 0, 0) end
  end

  # Header Seg Rects
  head = DrawExt::Helper.seg_rects_zero
  head[3].set(0, 0, 32, 14)
  head[4].set(32, 0, 32, 14)
  head[5].set(64, 0, 32, 14)

  help_rects = DrawExt::Helper.seg_rects_zero
  help_rects[3].set(0, 0, 8, 24)
  help_rects[4].set(8, 0, 80, 24)
  help_rects[5].set(88, 0, 8, 24)

  skill_border = proc do |index|
    dy = 24 * index
    rects = DrawExt::Helper.seg_rects_zero
    rects[3].set(0, dy, 40, 24)
    rects[4].set(40, dy, 42, 24)
    rects[5].set(82, dy, 30, 24)

    rects
  end

  art_rects = DrawExt::Helper.seg_rects_zero
  art_rects[3].set( 0, 0, 24, 24)
  art_rects[4].set(24, 0, 48, 24)
  art_rects[5].set(72, 0, 24, 24)

  @@default_seg_rects = {
    'art'          => art_rects,
    'default'      => seg_rects_zero,
    'header'       => head,
    'help'         => help_rects,
    'skill_border' => skill_border,
    'tail'         => head
  }

  def self.default_seg_rects(name, *args)
    obj = @@default_seg_rects[name]
    return obj.is_a?(Proc) ? obj.call(*args) : obj
  end
end
