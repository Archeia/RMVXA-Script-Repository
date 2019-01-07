=begin
#===============================================================================
 Title: Bit Switches
 Author: Hime
 Date: Sep 1, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 1, 2013
   - fixed bug where setting a single bit was not working correctly
 Jun 10, 2013
   - added support for matching ON/OFF bits simultaneously
   - implemented Bitmask Lookup table, for naming your bit masks
 Jun 8, 2013
   - added mask matching methods
 Jun 7, 2013
   - bitmask checking now checks for ON bits or OFF bits exclusively
 Jun 6, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script introduces a new type of switch called a "bit switch".
 These switches operate on numbers stored in game variables. The purpose is
 to allow you to group a collection of related switches into a single variable
 rather than reserving multiple game switches, allowing you to manage larger
 projects more easily.
 
 A bit switch is a single digit in the binary representation of a number
 stored in the variable. So for example, the number 6 in binary is written as
 110. If we treat each digit as a switch, then we have three bit switches in
 the number 6.
 
 Bit switches have the property that a value of 1 is ON and a value of 0 is OFF.
 Bit switches are read from right to left, so the first bit switch is the digit
 on the very right, and the second bit switch is the digit next to it. The
 number 6 means
   
   bitswitch 1 is OFF
   bitswitch 2 is ON
   bitswitch 3 is ON
   
 We can perform batch switch processing using "bit masks". A "bit mask" is
 a collection of bit switches. Rather than checking multiple bit switches
 separately, we can check them all at the same time. Similarly, we can also
 set multiple bit switches using a bit mask.
--------------------------------------------------------------------------------
 ** Example
 
 Suppose our variable holds the number 102. In binary, this is 1100110.
 If we wanted to know whether bit switch 2 and bit switch 7 are ON, we use the
 following bit mask: 1000010. Observe that digits 2 and 7 are ON (why?)
 
 The mask is applied to the variable using a bitwise AND operation as follows
 
   1100110 : value
 & 1000010 : mask
 = 1000010 : result, equal to mask
   
 If the result is equal to our mask switch, then it will return true.
 Otherwise, if even one bit switch is different, then our result is false.
 
 If our variable had a value of 101, or in binary 1100101, our mask would have
 failed as follows:
 
   1100101 : value
 & 1000010 : mask
 = 1000000 : result, not equal to mask
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 -- summary --
 
 These are all the methods that you will need

   set_bit_switch(var_id, bit, value)   - set a bit-switch to true/false
   set_mask_switch(var_id, mask, value) - set multiple bit switches to true/false
   set_mask_match(var_id, mask1, mask2) - set variable to the mask
   bit_switch?(var_id, bit)             - check if the bit switch is ON
   mask_switch?(var_id, mask)           - check if the bit switches are ON
   mask_match?(var_id, mask1, mask2)    - check if variable matches the mask
 
 -- details --
 
 1. You can set a variable directly using the control variables event command,
 using the script call box to enter binary or hex values if is easier.
 
 To set a specific bit switch, use the script call
 
   set_bit_switch(var_id, bit, value)
   ---------------------------------------------------------------
   set_bit_switch(2, 9, true) # Turn ON bit switch 9 in variable 2
   
 Where
   `var_id` is the ID of the variable you want to set
   `bit` is the digit that you want to set
   `value` is either true or false
   
 Remember that the first digit is the one on the very right.
 
 2. To perform batch bit switch setting, use the script call
 
   set_mask_switch(var_id, mask, value)
   ---------------------------------------------------------------
   set_mask_switch(3, 0b0101, true)
   
 Where the `mask` is the bit mask you want to use. Note that in this case,
 a 1 in the mask means that the corresponding bit will have its value changed,
 so if your mask is 0b0101 with a value of false, then bit switches 1 and 3
 will be set to false, while 2 and 4 will remain the same.
   
 3. To set ON and OFF bits at the same time, use the script call
 
   set_mask_match(var_id, mask1, mask2)
   ---------------------------------------------------------------
   set_mask_match(3, 0b1100, 0b0010)
   
 In this case, the first mask specifies which bits will be set to ON, while
 the second mask specifies which bits will be set to OFF. The 1's indicate
 which bits will be checked, so in the example, bits 3 and 4 are ON, bit 2 is
 OFF, and bit 1 is ignored.
  
 4. To check whether a bit switch is ON, use the script call
 
   bit_switch?(var_id, bit)
   ---------------------------------------------------------------
   bit_switch?(3, 8) # check if bit switch 8 in variable 3 is ON
   
 This will return true if the specified bit is ON, and false otherwise.
 
 5. To perform batch checking using a bit mask, use the script call
 
   mask_switch?(var_id, mask)
   ---------------------------------------------------------------
   mask_switch?(2, 0b1100, true)  # check if bit switches 3, and 4 are ON
   mask_switch?(2, 0b0011, false) # check if bit switches 1 and 2 are OFF
   
 It will return true if the specified bit switches match the  mask for the
 given value. The 1 means we will check the corresponding bit, and a 0 means we
 will ignore the corresponding bit.
 
 6. You can also check ON bits and OFF bits at the same time using
 
   mask_match?(var_id, mask1, mask2)
   ---------------------------------------------------------------
   mask_match?(4, 0b1100, 0b0010) # check if bits 3 and 4 are ON, and bit 2 is OFF
   
 The first mask checks for ON bits, and the second mask checks for OFF bits.
 The 1's indicate which bits will be checked by that mask.
 
 --Bitmask Lookup Table--

 This script allows you to assign bitmasks to constants stored in a look up
 table. You can then reference these constants throughout your events so that
 if you ever change the bitmasks, you don't have to go through all your events
 to make sure that the specific bitmask has been updated correctly.

 The bitmask look table is located in the script configuration. The keys are
 symbols, which represent the name of your bitmask, and the value associated
 with it is the bitmask itself.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BitSwitches"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Bit_Switches
    
    # This table maintains a set of "named" bitmasks.
    # Instead of hardcoding bitmasks into your checks, you can pass in a symbol
    # that will look up this table
    Bitmask_Table = {
       :dungeon1_doorA   => 0b1101,
       :dungeon1_doorB   => 0b1100,
       :waterfall_gates  => 0b110101010101
    }
    
#===============================================================================
# ** Rest of Script
#===============================================================================    

    def bit_sequence_lookup(mask)
      return mask.is_a?(Symbol) || mask.is_a?(String) ? Bitmask_Table[mask] : mask
    end
    
    #---------------------------------------------------------------------------
    # Sets the given bit to the specified value. The value should be true
    # or false. Note that the digit is 1-based, so the least-significant bit
    # is 1 instead of 0
    #---------------------------------------------------------------------------
    def set_bit_switch(var_id, bit, value)
      if value
        $game_variables[var_id] |= 1 << (bit - 1)
      else
        $game_variables[var_id] &= ~(1 << (bit - 1))
      end
    end
    
    #---------------------------------------------------------------------------
    # Batch operation. Sets the specified bits in the mask to the given value
    # of true or false. A 1 in the mask, in this case, means that the bit
    # in that position will have their value changed. For example, if your mask
    # is 0b0101 with a value of false, then switches 1 and 3 will be set to
    # false while 2 and 4 are preserved
    #---------------------------------------------------------------------------
    def set_mask_switch(var_id, mask, value)
      mask = bit_sequence_lookup(mask)
      # set designated bits to true
      if value
        $game_variables[var_id] |= mask
      # set designated bits to false. We negate our mask and do bitwise AND to
      # take out the bits we don't want, while preserving the rest
      else
        $game_variables[var_id] &= ~mask
      end
    end
    
    #---------------------------------------------------------------------------
    # Sets the variable to the given mask. If a second mask is provided, the
    # first mask is treated as the ON bits, while the second mask is treated
    # as the OFF bits.
    #
    #For example, if mask1 is 0b1010 and mask2 is 0b0100 then bits 2 and 4 are
    # ON, bit 3 is OFF, while bit 1 is ignored
    #---------------------------------------------------------------------------
    def set_mask_match(var_id, mask1, mask2=nil)
      mask1 = bit_sequence_lookup(mask1)
      mask2 = bit_sequence_lookup(mask2)
      if mask2
        $game_variables[var_id] |= mask1
        $game_variables[var_id] &= ~mask2
      else
        $game_variables[var_id] = mask1
      end
    end
    
    #---------------------------------------------------------------------------
    # Returns true if the specified varswitch is ON, false otherwise.
    # AND the given bit and if the value > 0 than that bit must be ON
    #---------------------------------------------------------------------------
    def bit_switch?(var_id, bit)
      mask = 1 << (bit - 1)
      return ($game_variables[var_id] & mask) != 0
    end
    
    #---------------------------------------------------------------------------
    # Batch operation. Checks whether multiple bits are ON or OFF based on the
    # mask. A 1-bit in the mask means the corresponding bit in the variabie
    # will be checked against the provided value. For example, if your mask is
    # 0b1010 and value is true, then it will check whether bits 2 and 4 are ON.
    # The other bits are ignored because their values are 0.
    #---------------------------------------------------------------------------
    def mask_switch?(var_id, mask, value=true)
      mask = bit_sequence_lookup(mask)
      if value
        return ($game_variables[var_id] & mask) == mask
      else
        mask = ~mask
        return ($game_variables[var_id] | mask) == mask
      end
    end
    
    #---------------------------------------------------------------------------
    # Batch operation. Checks whether the variable matches the mask exactly.
    # If mask2 is provided, then the second mask checks for OFF bits.
    #
    # For example, if mask1 is 0b1100 and mask2 is 0b0001 then this returns
    # true if bit 1 is OFF and bits 3 and 4 are ON. Bit 2 is ignored.
    #---------------------------------------------------------------------------
    def mask_match?(var_id, mask1, mask2=nil)
      mask1 = bit_sequence_lookup(mask1)
      if mask2
        mask2 = bit_sequence_lookup(mask2)
        mask2 = ~mask2
        return ($game_variables[var_id] & mask1) == mask1 && 
               ($game_variables[var_id] | mask2) == mask2
      else
        return $game_variables[var_id] == mask1
      end
    end
  end
end

class Game_Interpreter
  include TH::Bit_Switches
end

if $imported["TH_CustomPageConditions"]
  class Game_Event < Game_Character; include TH::Bit_Switches; end
  class Game_CommonEvent; include TH::Bit_Switches; end
  class Game_Troop; include TH::Bit_Switches; end
end