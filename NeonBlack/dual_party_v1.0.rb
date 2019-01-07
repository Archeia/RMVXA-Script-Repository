###--------------------------------------------------------------------------###
#  Dual Party script                                                           #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#  Requested by: xXx| - Kilim - | [420[MLG]]|xXx                               #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 8.20.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script allows you to have several parties with their own items and     #
#  members.  Note that the first party will be the default created party       #
#  all other parties have no members or items by default.                      #
#                                                                              #
#   switch_party(x)  - Switch the currently active party where "x" is the      #
#                      party number.  The default party is part 0, so if you   #
#                      have 3 parties, they would be parties 0, 1, and 2.      #
#   merge_party(x)  - Combine party "x" with the currectly active party.       #
#                     Adds the items, gold, and members of party "x" to the    #
#                     current party and then empties party "x".                #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
module CP         # Do not edit                                                #
module DUAL_PARTY #  these lines.                                              #
#                                                                              #
###-----                                                                -----###
# Default number of parties to have.                                           #
PARTIES = 2 # Default = 2                                                      #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end

module DataManager
  class << self  ## Alias the create objects spot.
    alias cp_dual_party create_game_objects
    alias cp_dual_loading extract_save_contents
  end
  
  def self.create_game_objects
    cp_dual_party  ## Sets up parts to store the new parties.
    $game_all_parties   = Party_Storage.new
    $game_party         = $game_all_parties.active_party
  end
  
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player
    
    ## Added.
    contents[:parties]       = $game_all_parties
    contents
  end
  
  def self.extract_save_contents(contents)
    cp_dual_loading(contents)  ## Load the parties container.
    $game_all_parties   = contents[:parties]
  end
end

class Game_Interpreter
  def switch_party(num)  ## Switch the parties.
    $game_all_parties.switch_party(num)
    $game_party = $game_all_parties.active_party
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  def merge_party(num)
    $game_all_parties.merge_party(num)
    $game_player.refresh
    $game_map.need_refresh = true
  end
end

class Party_Storage
  attr_reader :active
  
  def initialize
    @groups = []  ## Sets up the default containers.
    @active = 0
    create_all_groups
  end
  
  def create_all_groups
    number.times do  ## Creates all the default parties.
      @groups.push(Game_Party.new)
    end
  end
  
  def active_party  ## Gets the active party.
    @groups[@active]
  end
  
  def switch_party(num)
    @active = num  ## Change the party to the user defined party.
    @active = 0 if @active < 0
    while (@active > 0 && @groups[@active].nil?)
      @active -= 1
    end
  end
  
  def merge_party(num)
    return if @groups[num].nil?
    return if num == @active
    unless @groups[num].items.nil? || @groups[num].items.empty?
      @groups[num].items.each do |k|
        i = @groups[num].item_number(k)
        @groups[@active].gain_item(k, i)
      end
    end
    unless @groups[num].weapons.nil? || @groups[num].weapons.empty?
      @groups[num].weapons.each do |k|
        i = @groups[num].item_number(k)
        @groups[@active].gain_item(k, i)
      end
    end
    unless @groups[num].armors.nil? || @groups[num].armors.empty?
      @groups[num].armors.each do |k|
        i = @groups[num].item_number(k)
        @groups[@active].gain_item(k, i)
      end
    end
    unless @groups[num].members.nil? || @groups[num].members.empty?
      @groups[num].members.each do |actor|
        @groups[@active].add_actor(actor.id)
      end
    end
    @groups[@active].gain_gold(@groups[num].gold)
    @groups[num].reset_party
  end
  
  def number  ## Get the default number of parties.
    CP::DUAL_PARTY::PARTIES
  end
end

class Game_Party < Game_Unit
  def reset_party
    @items = {}
    @weapons = {}
    @armors = {}
    @actors = []
    @gold = 0
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###