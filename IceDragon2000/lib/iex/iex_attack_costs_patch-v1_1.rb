#==============================================================================#
# ** IEX(Icy Engine Xelion) - Attack Costs/Patch
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (IEX - Attack Costs)
# ** Script Type   : Patch
# ** Date Created  : 02/11/2011
# ** Date Modified : 07/17/2011
# ** Script Tag    : IEX - Attack Costs/Patch
# ** Difficulty    : N/A
# ** Version       : 1.1
#------------------------------------------------------------------------------#
# Install this script above the IEX - Attack Costs
# But below custom battle systems.
# WARNING* This overwrites much of the Window_ActorCommand
#         also in the Scene_Battle 
# the update_actor_command_selection has been totally overwritten
# This may cause very serious errors in your game for battles.
# NOTE* This patch becomes ineffective if you have BEM.
#
$imported ||= {} 
$imported["IEX_AttackCosts-Patch"] = true

unless $imported["BattleEngineMelody"]
#===============================================================================#
# ** Icon
#===============================================================================#
module Icon
  
  #--------------------------------------------------------------------------#
  # * mp_cost
  #--------------------------------------------------------------------------#
  def self.mp_cost
    return IEX::ATTACK_COSTS::ATTACK_SETTINGS[:mp_icon]
  end
  
  #--------------------------------------------------------------------------#
  # * hp_cost
  #--------------------------------------------------------------------------#
  def self.hp_cost
    return IEX::ATTACK_COSTS::ATTACK_SETTINGS[:hp_icon]
  end
  
  #--------------------------------------------------------------------------#
  # * gold_cost
  #--------------------------------------------------------------------------#
  def self.gold_cost
    return IEX::ATTACK_COSTS::ATTACK_SETTINGS[:gold_icon]
  end
  
end # Icon

end

#===============================================================================#
# ** Game_Battler
#===============================================================================#
class Game_Battler
  
unless $imported["BattleEngineMelody"]
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :action
  attr_accessor :update_commands
  attr_accessor :battle_command_index
  
  #--------------------------------------------------------------------------#
  # * new-method :attack_vocab
  #--------------------------------------------------------------------------#  
  def attack_vocab()
    return Vocab.attack
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :skill_vocab
  #--------------------------------------------------------------------------#  
  def skill_vocab()
    return Vocab.skill
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :guard_vocab
  #--------------------------------------------------------------------------#  
  def guard_vocab()
    return Vocab.guard
  end
  
end

end

#===============================================================================#
# ** Game_Party
#===============================================================================#
class Game_Party < Game_Unit
unless $imported["BattleEngineMelody"]
  #--------------------------------------------------------------------------#
  # * alias method :gain_item
  # Quick Cache Data
  #--------------------------------------------------------------------------#
  alias gain_item_bem gain_item unless $@
  def gain_item(item, n, include_equip = false)
    gain_item_bem(item, n, include_equip)
    @battle_items_cache = nil
  end
  
  #--------------------------------------------------------------------------#
  # * new method :battle_item_size
  # Quick Cache Data
  #--------------------------------------------------------------------------#
  def battle_item_size
    return @battle_items_cache if @battle_items_cache != nil
    @battle_items_cache = 0
    for item in items
      next unless item_can_use?(item)
      @battle_items_cache += 1
    end
    return @battle_items_cache
  end
  
  #--------------------------------------------------------------------------#
  # * new method :clear_caches
  #--------------------------------------------------------------------------#
  def clear_caches()
    @battle_items_cache = nil
    for i in 0..$data_actors.size
      actor = $game_actors[i]
      next if actor == nil
      actor.clear_battle_cache
    end
  end
  
end # // Unless Imported

end

#===============================================================================#
# ** Window_ActorCommand
#===============================================================================#
class Window_ActorCommand < Window_Command

unless $imported["BattleEngineMelody"]
  #--------------------------------------------------------------------------#
  # Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actor
  
  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias initialize_window_actorcommand_bem initialize unless $@
  def initialize
    @disable_empty_commands = IEX::ATTACK_COSTS::DISABLE_EMPTY_COMMANDS
    initialize_window_actorcommand_bem
  end
  
  #--------------------------------------------------------------------------#
  # * new method :item
  #--------------------------------------------------------------------------#
  def item; return @data[self.index]; end
  
  #--------------------------------------------------------------------------#
  # * new method :skill
  #--------------------------------------------------------------------------#
  def skill; return $data_skills[@skills[item]]; end
  
  #--------------------------------------------------------------------------#
  # * overwrite method :setup
  #--------------------------------------------------------------------------#
  def setup(actor)
    @actor = actor
    @data = []; @commands = []; @skills = {}
    data_set = actor.class.id
    data_set = 0 if !IEX::ATTACK_COSTS::CLASS_COMMANDS.include?(actor.class.id)
    #---
    for item in IEX::ATTACK_COSTS::CLASS_COMMANDS[data_set]
      case item
      when :attack; @commands.push(actor.attack_vocab)
      when :skill;  @commands.push(actor.skill_vocab)
      when :guard;  @commands.push(actor.guard_vocab)
      when :item;   @commands.push(Vocab.item)
      when :equip;  @commands.push(IEX::ATTACK_COSTS::EQUIP_VOCAB)
      when :escape
        next unless $game_troop.can_escape
        @commands.push(Vocab.escape)
      else
        valid = false
        if IEX::ATTACK_COSTS::SKILL_COMMANDS.include?(item)
          @skills[item] = IEX::ATTACK_COSTS::SKILL_COMMANDS[item][0]
          @commands.push(IEX::ATTACK_COSTS::SKILL_COMMANDS[item][1])
          valid = true
        end
        next unless valid
      end
      @data.push(item)
    end
    #---
    @item_max = @commands.size
    refresh
    self.index = 0
  end
  
  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update()
    return unless $scene.is_a?(Scene_Battle)
    super unless Input.trigger?(Input::L) or Input.trigger?(Input::R)
    #return unless @actor == $scene.status_window.actor
    refresh if @actor != nil and @actor.update_commands
  end
  
  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    create_contents
    @actor.update_commands = false if @actor != nil
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    obj = @data[index]
    enabled = enabled?(obj)
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
  #--------------------------------------------------------------------------#
  # * new method :enabled?
  #--------------------------------------------------------------------------#
  def enabled?(obj = nil)
    return false unless @actor.actor?
    return false unless @actor.inputable?
    return false if obj == nil
    if @disable_empty_commands
      return false if obj == :skill and @actor.skills.size <= 0
      return false if obj == :item and $game_party.battle_item_size <= 0
    end
    if @skills.include?(obj)
      skill = $data_skills[@skills[obj]]
      return @actor.skill_can_use?(skill)
    end
    return true
  end
  
end # $imported

end

#==============================================================================#
# ** Scene Battle
#==============================================================================#
class Scene_Battle < Scene_Base 
 
unless $imported["BattleEngineMelody"] 
  def ctb? ; return false end
  def atb? ; return false end
  def ptb? ; return false end
  def dtb? ; return true  end
  #--------------------------------------------------------------------------#
  # * overwrite method :update_actor_command_selection
  #--------------------------------------------------------------------------#
  def update_actor_command_selection
    @selected_battler = @active_battler
    if @selected_battler.battle_command_index != @actor_command_window.index
      @selected_battler.battle_command_index = @actor_command_window.index
      if (dtb? or ctb?) and !@selected_battler.auto_battle
        #$game_troop.clear_ctb_cache
        last_action = @selected_battler.action.clone
        case @actor_command_window.item
        when :attack;  @selected_battler.action.set_attack
        when :guard;   @selected_battler.action.set_guard
        else
          item = @actor_command_window.item
          array = IEX::ATTACK_COSTS::SKILL_COMMANDS[item]
          if array != nil
            skill = $data_skills[array[0]]
            @selected_battler.action.set_skill(skill.id) if skill != nil
          end
        end
        make_action_orders
        @selected_battler.action = last_action
      end
      make_action_orders if @selected_battler.auto_battle and (dtb? or ctb?)
    end
    #---
    if Input.trigger?(Input::B)
      Sound.play_cancel
      cancel_action
    elsif Input.trigger?(Input::C)
      actor_command_case
    elsif Input.repeat?(Input::LEFT)
      Sound.play_cursor
      prior_actor
    elsif Input.repeat?(Input::RIGHT)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      @status_shortcut_index = @status_window.index
      start_party_command_selection
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      @status_shortcut_index = @status_window.index
      start_confirm_command_selection
    end
  end
  
  #--------------------------------------------------------------------------#
  # * new method :actor_command_case
  #--------------------------------------------------------------------------#
  def actor_command_case()
    if !@actor_command_window.enabled?(@actor_command_window.item)
      if @selected_battler.inputable? and !@selected_battler.auto_battle
        Sound.play_buzzer
      else
        Sound.play_cursor
        if !dtb? and (@actor_index == $game_party.members.size - 1)
          @actor_index = -1
        end
        next_actor
      end
      return
    end
    case @actor_command_window.item
    when :attack
      Sound.play_decision
      @selected_battler.action.set_attack
      start_target_enemy_selection
    when :skill
      Sound.play_decision
      start_skill_selection
    when :guard
      Sound.play_decision
      @selected_battler.action.set_guard
      confirm_action
    when :item
      Sound.play_decision
      start_item_selection
    when :equip
      Sound.play_decision
      call_equip_menu
    when :escape
      Sound.play_decision
      @selected_battler.action.set_escape
      confirm_action
    else
      Sound.play_decision
      @command_action = true
      @skill = @actor_command_window.skill
      determine_skill
    end
  end
end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#