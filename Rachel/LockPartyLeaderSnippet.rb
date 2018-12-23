#--------------------------------------------------------------------------
# Lock Party Leader Snippet
# Authors:
# Racheal / Yato
# Nathan Frost
#--------------------------------------------------------------------------
# A snippet from this script that simply brings up a message that prevents 
# the main actor from being changed / swapped around from within the formation menu.
#
# Compatibilities:
# Yanfly's Party System
# Neonblack's CP Battle Engine 
# Blackmorning's base script, simple equip menu, icon menu and column menu.
#
#--------------------------------------------------------------------------
# https://forums.rpgmakerweb.com/index.php?threads/snippet-required-locking-party-leader.35855
#--------------------------------------------------------------------------
class Window_MenuStatus < Window_Selectable    
	attr_accessor :formation 
	#--------------------------------------------------------------------------  
	# * Object Initialization  
	#--------------------------------------------------------------------------  
	alias lock_main_menustatus_initialize initialize  
	def initialize(x, y)    
		lock_main_menustatus_initialize(x, y)    
		@formation = false  
	end  
	#--------------------------------------------------------------------------  
	# * Get Activation State of Selection Item  
	#--------------------------------------------------------------------------  
	def current_item_enabled?    
		return !(self.index == 0 and @formation == true)  
	end
end

class Scene_Menu < Scene_MenuBase    
	MESSAGE = "Can't complete this action!"  
	#--------------------------------------------------------------------------  
	# * [Formation] Command  
	#--------------------------------------------------------------------------  
	alias lock_main_command_formation command_formation  
	def command_formation    
		lock_main_command_formation    
		@status_window.formation = true  
	end  
	#--------------------------------------------------------------------------  
	# * Create Popup Window  
	#--------------------------------------------------------------------------  
	def create_popup_window    
		center_x = (Graphics.width - 320) / 2    
		center_y = (Graphics.height - 48) / 2.5    
		@popup_window = Window_Selectable.new(center_x, center_y, 320, 48)    
		@popup_window.openness = 0   
		@popup_window.draw_text(@popup_window.contents.rect, MESSAGE, 1)    
		@popup_window.set_handler(:ok,     method(:on_popup_confirm))    
		@popup_window.set_handler(:cancel, method(:on_popup_confirm))    
		@status_window.deactivate ; @popup_window.open.activate  
	 end  
	 #--------------------------------------------------------------------------  
	 # * Frame Update  
	 #--------------------------------------------------------------------------  
	 alias nathan_frost_lock_main_on_formation_update update  
	 def update    
		 nathan_frost_lock_main_on_formation_update    
		 if @status_window.formation && @status_window.index == 0 && Input.trigger?(:C)      
		 create_popup_window    
		 end  
	 end  
	 #--------------------------------------------------------------------------  
	 # * On Popup Confirm  
	 #--------------------------------------------------------------------------  
	 def on_popup_confirm   
		 @popup_window.deactivate.close    
		 @status_window.activate  
	 end  
	 #--------------------------------------------------------------------------  
	 # * Formation [Cancel]  
	 #--------------------------------------------------------------------------  
	 alias lock_main_on_formation_cancel on_formation_cancel 
	 def on_formation_cancel    
		@status_window.formation = !(@status_window.pending_index == -1)
		lock_main_on_formation_cancel  
	end
 end
