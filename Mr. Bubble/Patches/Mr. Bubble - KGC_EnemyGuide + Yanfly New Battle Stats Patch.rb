#==============================================================================
# KGC_EnemyGuide + Yanfly New Battle Stats Patch (DEX, RES, DUR, and LUK)
# v0.1 (August 24, 2011)
# By Mr. Bubble
#==============================================================================
# Installation: Insert this patch into its own page below KGC Enemy Guide in
#               your script editor.
#------------------------------------------------------------------------------
# This patch allows you to show an enemy's Yanfly stats in KGC Enemy Guide.
# No customization is required in this script. Just install it.
#
# This is a *very* badly made patch. If anyone wants to clean it up or make a
# better one, feel free to.
#==============================================================================

#==============================================================================
#------------------------------------------------------------------------------
#------- Do not edit below this point unless you know what you're doing -------
#------------------------------------------------------------------------------
#==============================================================================


class Window_EnemyGuideStatus < Window_Base
  def draw_parameter2(dx, dy)
    # ATK ～ AGI
    param = {}
    if KGC::Commands.enemy_defeated?(enemy.id)
      param[:atk]   = enemy.atk
      param[:def]   = enemy.def
      param[:spi]   = enemy.spi
      param[:agi]   = enemy.agi
      # Enemy DEX
      if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
        param[:dex] = enemy.dex
      end
      # Enemy RES
      if $imported["BattlerStatRES"] || $imported["RES Stat"]
        param[:res] = enemy.res
      end
      # Enemy DUR
      if $imported["ClassStatDUR"]
        param[:dur] = enemy.base_dur
      end
      # Enemy LUK
      if $imported["ClassStatLUK"]
        param[:luk] = enemy.base_luk
      end
    else
      param[:atk] = param[:def] = param[:spi] = param[:agi] =
        KGC::EnemyGuide::UNDEFEATED_PARAMETER
      # Enemy DEX
      if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
        param[:dex] = KGC::EnemyGuide::UNDEFEATED_PARAMETER
      end
      # Enemy RES
      if $imported["BattlerStatRES"] || $imported["RES Stat"]
        param[:res] = KGC::EnemyGuide::UNDEFEATED_PARAMETER
      end
      # Enemy DUR
      if $imported["ClassStatDUR"]
        param[:dur] = KGC::EnemyGuide::UNDEFEATED_PARAMETER
      end
      # Enemy LUK
      if $imported["ClassStatLUK"]
        param[:luk] = KGC::EnemyGuide::UNDEFEATED_PARAMETER
      end
    end
    dw = (width - 32) / 2
    dw = (width - 32) / 3 if param.size > 4
    dw = (width - 32) / 4 if param.size > 6
    self.contents.font.color = system_color
    self.contents.draw_text(dx,      dy,       80, WLH, Vocab.atk)
    self.contents.draw_text(dx + dw, dy,       80, WLH, Vocab.def)
    self.contents.draw_text(dx,      dy + WLH, 80, WLH, Vocab.spi)
    self.contents.draw_text(dx + dw, dy + WLH, 80, WLH, Vocab.agi)
    
    if $imported["BattlerStatRES"] || $imported["RES Stat"]
      res_dw = 2
      self.contents.draw_text(dx + dw * res_dw, dy,       80, WLH, Vocab.res)
    end
    
    if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
      dex_dw = 2
      self.contents.draw_text(dx + dw * dex_dw, dy + WLH, 80, WLH, Vocab.dex)
    end
    
    if $imported["ClassStatDUR"]
      if param.size > 6
        dur_dw = 3
      else
        dur_dw = 2
      end
      self.contents.draw_text(dx + dw * dur_dw, dy,       80, WLH, Vocab.dur)
    end
    
    if $imported["ClassStatLUK"]
      if param.size > 6
        luk_dw = 3
      else
        luk_dw = 2
      end
      self.contents.draw_text(dx + dw * luk_dw, dy + WLH, 80, WLH, Vocab.luk)
    end
    
    if param.size > 6
      dx += (80 / 4)
    elsif param.size > 4
      dx += (80 / 2)
    else
      dx += 80
    end
    
    self.contents.font.color = normal_color
    self.contents.draw_text(dx,      dy,       48, WLH, param[:atk], 2)
    self.contents.draw_text(dx + dw, dy,       48, WLH, param[:def], 2)
    self.contents.draw_text(dx     , dy + WLH, 48, WLH, param[:spi], 2)
    self.contents.draw_text(dx + dw, dy + WLH, 48, WLH, param[:agi], 2)
    
    if $imported["BattlerStatRES"] || $imported["RES Stat"]
      self.contents.draw_text(dx + dw * res_dw, dy,       48, WLH, param[:res], 2)
    end
    
    if $imported["BattlerStatDEX"] || $imported["DEX Stat"]
      self.contents.draw_text(dx + dw * dex_dw, dy + WLH, 48, WLH, param[:dex], 2)
    end
    
    if $imported["ClassStatDUR"]
      self.contents.draw_text(dx + dw * dur_dw, dy,       48, WLH, param[:dur], 2)
    end
    
    if $imported["ClassStatLUK"]
      self.contents.draw_text(dx + dw * luk_dw, dy + WLH, 48, WLH, param[:luk], 2)
    end
    
    return dy + WLH * 2
  end

end # class Window_EnemyGuideStatus < Window_Base