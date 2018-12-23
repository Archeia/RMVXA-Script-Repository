#==============================================================================
# Compatibility Patch :                                         v1.1 (7/19/12)
#   Victor Engine - Pixel Movement + KMS Minimap
#   Sapphire Action System IV + KMS Minimap
#--------------------------------------------------------------------------
# Script by:
#     Mr. Bubble
#--------------------------------------------------------------------------
# Place this script below KMS Mini Map in your script edtior.
#==============================================================================

class Game_MiniMap
  #--------------------------------------------------------------------------
  # ○ 通行可否テーブルの探索
  #     x, y : 探索位置
  #--------------------------------------------------------------------------
  def scan_passage(x, y)
    dx = x / @draw_grid_num.x
    dy = y / @draw_grid_num.y

    # 探索済み
    return if @passage_scan_table[dx, dy] == 1

    # マップ範囲外
    return unless dx.between?(0, @passage_scan_table.xsize - 1)
    return unless dy.between?(0, @passage_scan_table.ysize - 1)

    rx = (dx.to_i * @draw_grid_num.x.to_i)...((dx.to_i + 1) * @draw_grid_num.x.to_i)
    ry = (dy.to_i * @draw_grid_num.y.to_i)...((dy.to_i + 1) * @draw_grid_num.y.to_i)
    mw = $game_map.width  - 1
    mh = $game_map.height - 1

    # 探索範囲内の通行テーブルを生成
    rx.each { |x|
      next unless x.between?(0, mw)
      ry.each { |y|
        next unless y.between?(0, mh)

        # 通行方向フラグ作成
        # (↓、←、→、↑ の順に 1, 2, 4, 8 が対応)
        flag = 0
        [2, 4, 6, 8].each{ |d|
          flag |= 1 << (d / 2 - 1) if $game_map.passable?(x, y, d)
        }
        @passage_table[x, y] = flag
      }
    }
    @passage_scan_table[dx, dy] = 1
  end
  #--------------------------------------------------------------------------
  # ○ 通行可能領域の描画
  #--------------------------------------------------------------------------
  def draw_map_foreground(bitmap)
    range_x = (@draw_range_begin.x.to_i)..(@draw_range_end.x.to_i)
    range_y = (@draw_range_begin.y.to_i)..(@draw_range_end.y.to_i)
    map_w   = $game_map.width  - 1
    map_h   = $game_map.height - 1
    rect    = Rect.new(0, 0, @grid_size, @grid_size)
    
    range_x.each { |x|
      next unless x.between?(0, map_w)
      range_y.each { |y|

        next unless y.between?(0, map_h)
        next if @passage_table[x, y] == 0
        next if @wall_events.find { |e| e.x == x && e.y == y }  # 壁
        # グリッド描画サイズ算出
        rect.set(0, 0, @grid_size, @grid_size)
        rect.x = (x - @draw_range_begin.x) * @grid_size
        rect.y = (y - @draw_range_begin.y) * @grid_size
        flag = @passage_table[x, y]
        if flag & 0x01 == 0  # 下通行不能
          rect.height -= 1
        end
        if flag & 0x02 == 0  # 左通行不能
          rect.x     += 1
          rect.width -= 1
        end
        if flag & 0x04 == 0  # 右通行不能
          rect.width -= 1
        end
        if flag & 0x08 == 0  # 上通行不能
          rect.y      += 1
          rect.height -= 1
        end
        bitmap.fill_rect(rect, KMS_MiniMap::FOREGROUND_COLOR)
      }
    }
  end # def
end # class