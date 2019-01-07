#==============================================================================
# ■ Configuration
#==============================================================================
module KRX
  
  # Name of the token soundfile
  AS_SOUNDFILE = '!ShakeMe'
  
  # Basic shake properties (power, speed, duration)
  AS_SETTINGS = [5, 20, 25]
  
end

#==============================================================================
# ■ RPG::Animation::Timing
#==============================================================================

class RPG::Animation::Timing
	#--------------------------------------------------------------------------
	# ● Check if shaking frame
	#--------------------------------------------------------------------------
  def shaking?
    @se.name.include?(KRX::AS_SOUNDFILE)
  end
  
  def shake_settings  ## CP Addition
    return KRX::AS_SETTINGS unless @flash_scope == 1
    power = @flash_color.alpha
    speed = @flash_color.red
    duration = @flash_duration * 4
    return [power, speed, duration]
  end
end

#==============================================================================
# ■ Game_ActionResult
#==============================================================================

class Game_ActionResult
	#--------------------------------------------------------------------------
	# ● Set miss flag
	#--------------------------------------------------------------------------
  def missed=(value)
    if @battler.precalc && @battler.precalc != self
      @missed = @battler.precalc.missed
    else
      @missed = value
    end
  end
	#--------------------------------------------------------------------------
	# ● Set evaded flag
	#--------------------------------------------------------------------------
  def evaded=(value)
    if @battler.precalc && @battler.precalc != self
      @evaded = @battler.precalc.evaded
    else
      @evaded = value
    end
  end
	#--------------------------------------------------------------------------
	# ● Set Hp damage
	#--------------------------------------------------------------------------
  def hp_damage=(value)
    if @battler.precalc && @battler.precalc != self
      @hp_damage = @battler.precalc.hp_damage
    else
      @hp_damage = value
    end
  end
end

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :precalc
	#--------------------------------------------------------------------------
	# ● Execute damage
	#--------------------------------------------------------------------------
  alias_method(:krx_as_gb_ed, :execute_damage)
  def execute_damage(user)
    krx_as_gb_ed(user)
    @precalc = nil
  end
	#--------------------------------------------------------------------------
	# ● Precalc action result
	#--------------------------------------------------------------------------
  def item_precalc(user, item)
    @precalc = Game_ActionResult.new(self)
    @precalc.used = item_test(user, item)
    @precalc.missed = (@precalc.used && rand >= item_hit(user, item))
    @precalc.evaded = (!@precalc.missed && rand < item_eva(user, item))
    puts @precalc.missed
    puts @precalc.evaded
    if @precalc.hit?
      unless item.damage.none?
        @precalc.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        @precalc.make_damage(@result.hp_damage, item)
        @result.clear
      end
    end
  end
end

#==============================================================================
# ■ Sprite_Base
#==============================================================================

class Sprite_Base < Sprite
	#--------------------------------------------------------------------------
	# ● Get animation timings
	#--------------------------------------------------------------------------
  alias_method(:krx_as_sb_pat, :animation_process_timing)
  def animation_process_timing(timing)
    if is_a?(Sprite_Battler) && timing.shaking?
      if @battler.precalc.hit? && @battler.precalc.hp_damage > 0
        start_shake(*timing.shake_settings)  ## CP Edit
      end
    else
      krx_as_sb_pat(timing)  ## CP Edit
    end
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Execute action
	#--------------------------------------------------------------------------
  alias_method(:krx_as_sb_ea, :execute_action)
  def execute_action
    precalculate_results
    krx_as_sb_ea
  end
	#--------------------------------------------------------------------------
	# ● Pre-calculate action results
	#--------------------------------------------------------------------------
  def precalculate_results
    item = @subject.current_action.item
    targets = @subject.current_action.make_targets.compact
    targets.each {|target| target.item_precalc(@subject, item)}
  end
end