#--------------------------------------------------------------------------
# Screen Shake Fix
# Author(s):
# Hiino
#--------------------------------------------------------------------------
# This script is a little bug fix for the Screen shake event command.
# Originally, the "Wait for the end" checkbox was useless, and the game 
# interpreter considered it was always checked. Plus, the wait time wasn't 
# right and used the "Speed" value instead of "Duration".
# This script fixes both issues.
# 
# To use it, simply copy/paste this code in Materials.
#
#--------------------------------------------------------------------------

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#------------------------------------------------------------------------------
class Game_Interpreter  
#--------------------------------------------------------------------------  
# * Fixed Screen Shake  
#--------------------------------------------------------------------------  
def command_225    
  screen.start_shake(@params[0], @params[1], @params[2])    
  wait(@params[2]) if @params[3]  
  end
end