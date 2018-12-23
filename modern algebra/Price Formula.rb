#==============================================================================
#    Price Formulas
#    Version: 1.0.1
#    Author: modern algebra (rmrk.net)
#    Date: 1 January 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This script lets you calculate the standard price of an item by a formula. 
#   The most useful implementation for this is likely to implement a tax, where
#   the price of the item varies depending on the value of the tax rate
#   variable.
#
#    Naturally, this does not interact with any prices that are set directly
#   in the Shop event itself.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    Paste this script into its own slot in the Script Editor, above Main but
#   below Materials.
#
#    To set the basic default formula that applies to all items, go to the 
#   Editable Region at line xx and alter MAPF_DEFAULT_PRICE_FORMULA. You can 
#   also give each item, weapon, or armor its own custom formula by using the 
#   following code in a notebox:
#
#        \price_f { ... }
#
#   where you replace the ... with the custom formula. When setting it in the 
#   notebox, DON'T use quotation marks.
#
#    As for the formula itself, the following codes are replaced:
#
#        \p    - This is replaced by the price value set in the database.
#        \v[n] - This is replaced with the value of the variable with ID n.
#        \s[n] - This is replaced by the value of the switch with ID n. It can 
#               be used for conditionals.
#
#   Beyond those replacements, the code will run just as you input it, and as
#   such must obey ordinary syntax and it should output an integer.
#``````````````````````````````````````````````````````````````````````````````
#  Example Formulas:
#
#    (\p * (\v[4] / 100.0)).to_i
#      This formula multiplies the ordinary price of the item by the value of 
#      variable 4 divided by 100. What that effectively means is that variable
#      4 is a percentage, and the price of the item will be modified by that 
#      percentage. If, say the ordinary price is 120 and the value of variable 
#      4 is 150, then the price of an item calculated by that formula would be 
#      180 since that is 150% of 120. Similarly, if the value of variable 4 is 
#      75, then the price would be 90, since that is 75% of 120. This would be
#      a good formula to use if you wanted to have a tax rate, since then all
#      you would need to do is adjust the value of variable 4 before every shop
#      and it would adjust the price of every item in the shop.
#
#    \p / (\s[24] ? 2 : 1)
#      This formula depends on the value of switch 24. If switch 24 is ON, then
#      the item is divided by 2 (half price). If it is OFF, then it is divided 
#      by 1 (full price).
#==============================================================================

$imported = {} unless $imported
$imported[:MA_PriceFormulas] = true

#==============================================================================
# *** MA_PriceFormulas
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module mixes in with RPG::Item and RPG::EquipItem to modify the price
# method.
#==============================================================================

module MA_PriceFormulas
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #    BEGIN Editable Region
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  MAPF_DEFAULT_PRICE_FORMULA - This is the default formula that is applied
  # to all items that do not use a custom formula in their noteboxes. '\p' 
  # means that it will just be the ordinary price. However, this is a good 
  # place to modify the formula for something that should apply to all items,
  # like a tax rate. It is necessary here to use quotation marks, though the
  # same is not true when you are setting it in a notebox.
  MAPF_DEFAULT_PRICE_FORMULA = '\p'
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #    END Editable Region
  #//////////////////////////////////////////////////////////////////////////
  # Replace variable and switch codes
  MAPF_DEFAULT_PRICE_FORMULA.gsub!(/\\[Vv]\[\s*(\d+)\s*\]/) { "$game_variables[#{$1.to_i}]" }
  MAPF_DEFAULT_PRICE_FORMULA.gsub!(/\\[Ss]\[\s*(\d+)\s*\]/) { "$game_switches[#{$1.to_i}]" }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Price Formula
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def mapf_price_formula
    if !@mapf_price_formula
      if note[/\\PRICE_F\s*\{(.+?)\}/i]
        @mapf_price_formula = $1.strip 
        # Delete any quotation marks if user mistakenly inserts them
        @mapf_price_formula = $1 if @mapf_price_formula[/\A['"](.+?)['"]\z/]
        # Replace variable and switch codes
        @mapf_price_formula.gsub!(/\\[Vv]\[\s*(\d+)\s*\]/) { "$game_variables[#{$1.to_i}]" }
        @mapf_price_formula.gsub!(/\\[Ss]\[\s*(\d+)\s*\]/) { "$game_switches[#{$1.to_i}]" }
      else
        @mapf_price_formula = MAPF_DEFAULT_PRICE_FORMULA
      end
    end
    @mapf_price_formula
  end
end

#==============================================================================
# *** RPG
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Mix MA_PriceFormulas into RPG::Item and RPG::EquipItem
#==============================================================================

module RPG
  class EquipItem
    include MA_PriceFormulas # add mapf_price_formula method
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Price
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias mapf_pric_3gh6 price
    def price(*args)
      standard_p = mapf_pric_3gh6(*args) # Run Original Method
      eval(mapf_price_formula.gsub(/\\[Pp]/, standard_p.to_s)).to_i # Calculate
    end
  end
  class Item
    include MA_PriceFormulas
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Price
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias mapf_price_7bw2 price # add mapf_price_formula method
    def price(*args)
      standard_p = mapf_price_7bw2(*args) # Run Original Method
      eval(mapf_price_formula.gsub(/\\[Pp]/, standard_p.to_s)).to_i # Calculate
    end
  end
end