#==============================================================================
# Version 1.02
#
# About:
# A quick debug manager for completing/failing/revealing/concealing quests and
# objectives.
#
# Instructions:
# Place below "Modern Algebra's Quest Journal" but above "▼ Main Process".
# Call like this: SceneManager.call(Scene_QJ_Debug).
# Or Press Q (default) in the quest window to open the debug window.
#
# Requires:
# - Modern Algebra's Quest Journal 1.0.3
# - RPG Maker VX Ace
#
# Written by Napoleon (My very first addon!).
# Special thanks to Modern Algebra for answering my questions.
#
# Terms of Use:
# Credits are appreciated but not required. You may repost this as well as long
# as you do not claim this as your own work.
#
# Version History:
# 1.00 (17-1-2013)
#   - First Release
# 1.01 (18-1-2013)
#   - Added the $TEST variable
# 1.02 (18-1-2013)
#   - Added more functions
#==============================================================================


#==============================================================================
# ■ Quest Journal - Debug Addon - Singleton instance
#------------------------------------------------------------------------------
#  Singleton instance for the QJ debug scene
#==============================================================================
module Quest_Journal
  module Utility
################################################################################
# CONFIG START
################################################################################
    # When set to true (default) then you can Press [Q] (default) in the quest menu to open the debug menu.
    # When set to false this addon can only be manually called.
    # Note: This addon also requires the global $TEST set to true.
    DEBUG_MENU_ENABLED = true
    
    # Key for opening the debug menu from the quest journal. Use a nil value to disable this.
    DEBUG_MENU_KEY = QuestData::MAP_BUTTON # Should be [Q] by default
    
    # Key for completing/resetting an entire quest (left window)
    COMPLETE_RESET_QUEST_KEY = QuestData::MAP_BUTTON # Should be [Q] by default
    
    # Key for opening the debug menu directly from the map. Use a nil value to disable this.
    MAP_KEY = nil
    
    # When set to true then the debug menu will be shown if the Quest Journal has no quests and would have otherwise just played a 'buzzer sound'.
    SHOW_WHEN_NO_QUESTS = true
    
    # The first quest id, usually 0
    FIRST_QUEST = 0
    
    # When set to false then the map is shown after closing the debug menu even if it was opened through the Quest Journal's menu.
    RETURN_TO_QUEST_MENU = true
    
    # The maximum quest id to check. This must be equal or higher than your highest quest id
    MAX_QUEST = 1000

    # Quest text color when completed (in debug menu only)
    QUEST_COMPLETE_COLOR = 3 # 3 = lightgreen
    
    # The text status colors
    COLORS = {
      'revealed' => 1, # blue
      'completed' => 3, # green
      'failed' => 18, # red
      'concealed' => 0 # white
    }    
################################################################################    
# CONFIG END
################################################################################
    # Samples:
      # Utility.quest_data(1,:objectives)
      # Utility.quest_data(1,:name)
    # Possible symbols: :line, :level, :name, :description, :objectives, :rewards
    def self.quest_data(q_id, symbol)    
      return QuestData.setup_quest(q_id)[symbol]
    end
    
    # Returns true if this addon is enabled AND if the global debug mode is turned on
    def self.enabled?
      return DEBUG_MENU_ENABLED && $TEST
    end
    
    # Returns an array with all used (=non-empty) quest id's.
    def self.set_quest_data
      result = []
      array_idx = 0
      for i in FIRST_QUEST..MAX_QUEST
        if quest_data(i,:name) != nil
          result[array_idx] = i
          array_idx +=1
        end
      end
      return result
    end    
    
    #Utility.quests
    @@quests = set_quest_data
    # static getter
    def self.quests
      @@quests
    end  
    
    #Utility.quest_complete?()
    def self.quest_complete?(q_id)
      return $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].status?(:complete)
    end    
    #Utility.quest_revealed?()
    def self.quest_revealed?(q_id)
      return $game_party.quests.revealed?(q_id)
    end    
    #Utility.quest_failed?()
    def self.quest_failed?(q_id)
      return $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].status?(:failed)
    end    
    #Utility.quest_concealed?()
    def self.quest_concealed?(q_id)
      return !$game_party.quests.revealed?(q_id)
    end        
   
    def self.reveal_objective(q_id, *obj_id)
      obj_id.each do|o_id|
        $game_party.quests[q_id].reveal_objective(o_id)
      end
    end
    def self.conceal_objective(q_id, *obj_id)
      obj_id.each do|o_id|
        $game_party.quests[q_id].conceal_objective(o_id)
      end
    end
    def self.complete_objective(q_id, *obj_id)
      obj_id.each do|o_id|
        $game_party.quests[q_id].complete_objective(o_id)
      end
    end
    def self.fail_objective(q_id, *obj_id)
      obj_id.each do|o_id|
        $game_party.quests[q_id].fail_objective(o_id)
      end
    end    
    
    #Utility.objective_complete?(,)
    def self.objective_complete?(q_id, *obj_id)
      $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].objective_status?(:complete, *obj_id)
    end
    #Utility.objective_revealed?(,)
    def self.objective_revealed?(q_id, *obj_id)
      $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].objective_status?(:revealed, *obj_id)
    end
    #Utility.objective_concealed?(,)
    def self.objective_concealed?(q_id, *obj_id)
      $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].objective_status?(:concealed, *obj_id)
    end          
    #Utility.objective_failed?(,)
    def self.objective_failed?(q_id, *obj_id)
      $game_party.quests.revealed?(q_id) && $game_party.quests[q_id].objective_status?(:failed, *obj_id)
    end    

    #Utility.complete_quest(,)
    # Completes all objectives for the specified quest
    # Note that objective ID's may not have gaps. They must be numbered starting from 0 without any gaps in between.
    def self.complete_quest(q_id)
      obj_count = QuestData.setup_quest(q_id)[:objectives].compact.length
      for i in 0..obj_count-1
          complete_objective(q_id,i)
      end
    end    
    
    #Utility.reset_quest()
    def self.reset_quest(q_id)
      $game_party.quests.delete_quest(q_id)
    end 
  end # Utility
  
  #==============================================================================
  # ■ Quest Journal - Debug Addon - Quest window (left window)
  #------------------------------------------------------------------------------
  #  This window contains the list of all quests
  #============================================================================== 
  class Window_Quests < Window_Selectable
    include Quest_Journal
    #--------------------------------------------------------------------------
    # * Class Variable
    #--------------------------------------------------------------------------
    @@last_top_row = 0                      # For saving first line
    @@last_index   = 0                      # For saving cursor position
    @@sel_quest_id = 1                      # The current selected quest id
    @@is_first_update                       # Determines if this window had it's first update called.
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_reader   :right_window             # Right window
    attr_reader   :sel_quest_id             #   
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(x, y)
      @@is_first_update = true
      super(x, y, window_width, window_height)
      @sel_quest_id = Utility.quests[0]
      refresh
      self.top_row = @@last_top_row
      select(@@last_index)
      activate
    end
    #--------------------------------------------------------------------------
    # * Get Window Width
    #--------------------------------------------------------------------------
    def window_width
      return 164
    end
    #--------------------------------------------------------------------------
    # * Get Window Height
    #--------------------------------------------------------------------------
    def window_height
      Graphics.height
    end
    #--------------------------------------------------------------------------
    # * Get Number of Items
    #--------------------------------------------------------------------------
    def item_max
      Utility.quests.length || 0
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update      
      super
      if active && Input.trigger?(Utility::COMPLETE_RESET_QUEST_KEY) && !@@is_first_update
        q_id = Utility.quests[index]
        if Utility.quest_complete?(q_id)
          Utility.reset_quest(q_id)
        else
          Utility.complete_quest(q_id)
        end
        Sound.play_ok
        redraw_current_item
        @right_window.refresh
      end
      
      if !Input.press?(:L) then @@is_first_update = false end

      return unless @right_window
      @sel_quest_id = Utility.quests[index]
      @right_window.refresh_me 
    end
    #--------------------------------------------------------------------------
    # * Refresh
    #--------------------------------------------------------------------------
    def refresh
      create_contents
      draw_all_items
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index)
      quest_id = Utility.quests[index]
      
      # quest item color
      if Utility.quest_failed?(quest_id)
        change_color(text_color(Utility::COLORS['failed']))
      elsif Utility.quest_concealed?(quest_id)
        change_color(text_color(Utility::COLORS['concealed']))
      elsif Utility.quest_complete?(quest_id)              
        change_color(text_color(Utility::COLORS['completed']))     
      elsif Utility.quest_revealed?(quest_id)
        change_color(text_color(Utility::COLORS['revealed']))                
      end

      text = sprintf("%02d: #{QuestData.setup_quest(quest_id)[:name]} ", quest_id )
      text_rect = item_rect_for_text(index)
      text_rect.x+=24
      
      draw_text(text_rect, text)
      change_color(normal_color)
      draw_icon(QuestData.setup_quest(quest_id)[:icon_index], text_rect.x-24, text_rect.y, true)
    end
    #--------------------------------------------------------------------------
    # * Processing When Cancel Button Is Pressed
    #--------------------------------------------------------------------------
    def process_cancel
      super
      @@last_top_row = top_row
      @@last_index = index
    end
    #--------------------------------------------------------------------------
    # * Set Right Window
    #--------------------------------------------------------------------------
    def right_window=(right_window)
      @right_window = right_window
      update
    end
  end

  #==============================================================================
  # ■ Quest Journal - Debug Addon - Objective window (right window)
  #------------------------------------------------------------------------------
  #  This window contains the list of all objectives for the selected quest
  #==============================================================================
  #==============================================================================
  # ** Objective Window
  #------------------------------------------------------------------------------
  #  Displays the objectives for the currently selected quest (if any)
  #==============================================================================
  class Window_Objectives < Window_Selectable
    include Quest_Journal
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    # None
    #--------------------------------------------------------------------------
    # * Private Instance Variables
    #--------------------------------------------------------------------------    
    # The previously selected quest id (in the left window)
    @previous_quest_id
    

    #--------------------------------------------------------------------------
    # * Object Initialization
    #-------------------------------------------------------------------------
    def initialize(x, y, width, left_window)
      @left_window = left_window
      super(x, y, width, fitting_height(10))      
      refresh
    end
    #--------------------------------------------------------------------------
    # * Get Number of Items
    #--------------------------------------------------------------------------
    def item_max
      return QuestData.setup_quest(sel_q_id)[:objectives].length
    end
    #--------------------------------------------------------------------------
    # * Refresh
    #--------------------------------------------------------------------------
    def refresh
      contents.clear
      draw_all_items
    end
    #--------------------------------------------------------------------------
    # * Selected Quest ID
    #--------------------------------------------------------------------------
    def sel_q_id
      return @left_window.sel_quest_id
    end  
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------  
    def draw_item(index)    
      if sel_q_id == nil then return end
      
      obj_id = index # store currently selected objective_id in a more meaningful variable name
      item_text = sprintf("Obj. %0d: #{QuestData.setup_quest(sel_q_id)[:objectives][index]}",obj_id)
      id_width = text_size(item_text).width
      status = Utility.objective_complete?(sel_q_id,obj_id) ? "[X]" : "[ ]"    
      
      # objective item color
      if Utility.objective_failed?(sel_q_id,index)
        change_color(text_color(Utility::COLORS['failed']))
      elsif Utility.objective_concealed?(sel_q_id,index)
        change_color(text_color(Utility::COLORS['concealed']))
      elsif Utility.objective_complete?(sel_q_id,index)              
        change_color(text_color(Utility::COLORS['completed']))     
      elsif Utility.objective_revealed?(sel_q_id,index)
        change_color(text_color(Utility::COLORS['revealed']))                
      end
      
      # draw text
      text_rect = item_rect_for_text(index)
      status_rect = item_rect_for_text(index)
      text_rect.width -= 30
      draw_text(text_rect, item_text)      
      # draw status
      status_rect.x+= 5
      draw_text(status_rect, status, 2)    
      change_color(normal_color) # reset text color
    end
    #--------------------------------------------------------------------------
    # * Refresh
    #--------------------------------------------------------------------------
    def refresh_me
      if sel_q_id != @previous_quest_id then refresh end
      @previous_quest_id = sel_q_id
    end
    #--------------------------------------------------------------------------
    # * redraw_current_items (redraws both windows current items)
    #--------------------------------------------------------------------------
    def redraw_current_items
      redraw_current_item
      @left_window.redraw_current_item
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update
      super
      
      if Input.trigger?(:C)
        if Utility.objective_complete?(sel_q_id,index)
          $game_party.quests[sel_q_id].uncomplete_objective(index)
        else
          Utility.complete_objective(sel_q_id,index)
        end
        redraw_current_items
        Sound.play_ok
      end
      
      if active && Input.trigger?(:L)
        if Utility.objective_complete?(sel_q_id,index)
          $game_party.quests[sel_q_id].fail_objective(index)
          #p 'now failed'
        elsif Utility.objective_failed?(sel_q_id,index)
          $game_party.quests[sel_q_id].unfail_objective(index)
          $game_party.quests[sel_q_id].reveal_objective(index)
          #p 'now revealed'
        elsif Utility.objective_revealed?(sel_q_id,index)
          $game_party.quests[sel_q_id].conceal_objective(index)
          #p 'now concealed'
        else # it's ONLY revealed
          $game_party.quests[sel_q_id].complete_objective(index)
          #p 'now completed'
        end
        redraw_current_items
        Sound.play_cursor
      end      
    end
    
  end # end of right window class

end # end of module
#==============================================================================
# ■ Quest Journal - Debug Addon - Scene
#------------------------------------------------------------------------------
#  The scene that contains the debug menu
#==============================================================================
class Scene_QJ_Debug < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_left_window
    create_right_window
    create_help_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
  end
  #--------------------------------------------------------------------------
  # * Create Left Window
  #--------------------------------------------------------------------------
  def create_left_window
    @left_window = Quest_Journal::Window_Quests.new(0, 0)
    @left_window.set_handler(:ok,     method(:on_left_ok))
    @left_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Right Window
  #--------------------------------------------------------------------------
  def create_right_window
    wx = @left_window.width
    ww = Graphics.width - wx
    @right_window = Quest_Journal::Window_Objectives.new(wx, 0, ww, @left_window)
    @right_window.set_handler(:cancel, method(:on_right_cancel))
    @left_window.right_window = @right_window
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    wx = @right_window.x
    wy = @right_window.height
    ww = @right_window.width
    wh = Graphics.height - wy
    @help_window = Window_Base.new(wx, wy, ww, wh)
    refresh_help_window(:left)
  end
  #--------------------------------------------------------------------------
  # * Left [OK]
  #--------------------------------------------------------------------------
  def on_left_ok
    refresh_help_window(:right)
    @right_window.activate
    @right_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * Right [Cancel]
  #--------------------------------------------------------------------------
  def on_right_cancel
    @left_window.activate
    @right_window.unselect
    refresh_help_window(:left)
  end
  #--------------------------------------------------------------------------
  # * Refresh Help Window
  #--------------------------------------------------------------------------
  def refresh_help_window(window)
    if window == :left
      help_text = "C (Enter) : Select Quest.\n" +
                  "#{Quest_Journal::Utility::COMPLETE_RESET_QUEST_KEY} (Q) : Complete / Reset+Conceal."
    else
      help_text = "C (Enter) : Complete / Reset\n" +
                  "L (Q) : Completed [green]\nFailed [red]\nRevealed [blue]\nConcealed [white]"
    end
    @help_window.contents.clear
    @help_window.draw_text_ex(4, 0, help_text)
  end
end # Scene

#==============================================================================
# Overwrite Algebra's Window_QuestList update method so it can call this addon's scene
#==============================================================================
class Window_QuestList < Window_Selectable
  def update
    super
    if Quest_Journal::Utility.enabled? && Quest_Journal::Utility::DEBUG_MENU_KEY != nil && Input.trigger?(Quest_Journal::Utility::DEBUG_MENU_KEY)
      SceneManager.return if !Quest_Journal::Utility::RETURN_TO_QUEST_MENU
      SceneManager.call(Scene_QJ_Debug)
    end
  end
end
#==============================================================================
# Call this addon directly from the worldmap
#==============================================================================
class Scene_Map  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Call Quest Journal
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_call_quest_journal
    if $game_map.interpreter.running?
      @quest_journal_calling = false
    else      
      if Input.trigger?(QuestData::MAP_BUTTON)
        if $game_system.quest_access_disabled || $game_party.quests.list.empty?
          Quest_Journal::Utility.enabled? && Quest_Journal::Utility::SHOW_WHEN_NO_QUESTS ?
            SceneManager.call(Scene_QJ_Debug) : Sound.play_buzzer
        else
          @quest_journal_calling = true
        end
      end  
      if !@quest_journal_calling && Quest_Journal::Utility.enabled? && Quest_Journal::Utility::MAP_KEY != nil && Input.trigger?(Quest_Journal::Utility::MAP_KEY) && $game_system.quest_map_access && !scene_changing?
        SceneManager.call(Scene_QJ_Debug)
      else
        call_quest_journal if @quest_journal_calling && !$game_player.moving?
      end
    end
  end
end
#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================