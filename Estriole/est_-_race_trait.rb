$imported = {} if $imported.nil?
$imported["EST-RACE"] = true

=begin
==============================================================================
 ** EST - RACE TRAITS AND FEATURE 1.2
------------------------------------------------------------------------------
 Author             : ESTRIOLE
 Usage Level        : Easy
 
 licences:
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 also credits to FORMAR since i use his extra trait lv up as guide.
 
 modification for your own usage is permitted just don't claim this is yours
 just add below the author: Modded by : ....

 Version History:
  v 1.2 - 2012.10.08 > -  able to show 'fake' info in yanfly status script.
  v 1.1 - 2012.10.07 > -  add more function for variable showing
  v 1.0 - 2012.10.06 > -  finish the script

------------------------------------------------------------------------------
 This script assign traits to actors based on what race the actor is. actor
 race assigned using notetags. and the traits added is using armors as reference
 in the database.
------------------------------------------------------------------------------
 How to use:
 1) set your race in the configuration part below
    a) set the name
    b) set the armor id that it reference as trait adder. you could also assign
       multiple armor since i made it arrays in case you have mixed race. ex:
       hercules is half god half human. he gain both human and god trait.
 2) create the armor that you assign as race trait and give it traits (ex:maxhp +100%,etc)
 3) give tags to your actors
 
 <race: x>
 
 x is the race name you defined in the configuration (not case sensitive)
 
 from v1.2:
 to set the 'fake' skill info to show in yanfly status menu. (fake because they
 only text. the actual effect need to set in the armor)
 1) set your skill in configuration skill text config (see the example format)
 2) add in your race in ABILITYTEXT:
 3) SKILL[:yourskill]
 
 Future Development
 none
 
 Author Notes
 none
 
=end

module ESTRIOLE
######## SKILL TEXT CONFIG ######################################
  SKILL = {
  COMBOGOD:["Combo God","Attack hit 9 times"],
  FAST:["Fast","Agi +10%"],
  CRAZYREGEN:["Crazy Regen","Regenerate HP 100% each turn"],
  CRAZYMP:["Crazy MP","Max MP x 10"],
  FORTITUDE:["Fortitude","Max Hp x 10"],
  DOUBLEACTION:["Double Action","Act Twice in a turn"],
  TENCOMMAND:["10th Command","Act 10 times in turn"],
  }
  
######## RACE CONFIGURATION PART ######################################
  RACE = { # DO NOT TOUCH THIS LINE
  1 => {
            NAME: "HUMAN",  #this used in notetags: <race: human>
            SHOWNNAME: "Human",  #this cosmetic version to use in variables
            ARMOR_ID: [3], #array of armor id to add starting feature
            ABILITYTEXT: [SKILL[:CRAZYREGEN],SKILL[:CRAZYMP]],  

            }, #remember the , people tend to forget this
  2 => {
            NAME: "ELF",
            SHOWNNAME: "Elf",  #this cosmetic version to use in variables
            ARMOR_ID: [4],
            ABILITYTEXT: [SKILL[:COMBOGOD],SKILL[:FAST]],  
            },
  3 => {
            NAME: "DWARF",
            SHOWNNAME: "Dwarf",  #this cosmetic version to use in variables
            ARMOR_ID: [5],
            ABILITYTEXT: [SKILL[:FORTITUDE],SKILL[:DOUBLEACTION]],  
            },
  4 => {
            NAME: "SPIRIT",
            SHOWNNAME: "Spirit",  #this cosmetic version to use in variables
            ARMOR_ID: [6],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  5 => {
            NAME: "FAIRY", #no spaces allowed if name have two words <race: half_elf>
            SHOWNNAME: "Fairy",  #this cosmetic version to use in variables
            ARMOR_ID: [7],
            ABILITYTEXT: [
            SKILL[:COMBOGOD],SKILL[:FAST],SKILL[:CRAZYREGEN],SKILL[:CRAZYMP]
            ],                        
            },
  6 => {
            NAME: "GHOST",
            SHOWNNAME: "Ghost",  #this cosmetic version to use in variables
            ARMOR_ID: [8],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  7 => {
            NAME: "MAGIA",
            SHOWNNAME: "Magia",  #this cosmetic version to use in variables
            ARMOR_ID: [9],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  8 => {
            NAME: "CATEL",
            SHOWNNAME: "Catel",  #this cosmetic version to use in variables
            ARMOR_ID: [10],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  9 => {
            NAME: "ROBOT",
            SHOWNNAME: "Robot",  #this cosmetic version to use in variables
            ARMOR_ID: [11],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  10 => {
            NAME: "DRACULA",
            SHOWNNAME: "Dracula",  #this cosmetic version to use in variables
            ARMOR_ID: [12],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  11 => {
            NAME: "WEREWOLF",
            SHOWNNAME: "Werewolf",  #this cosmetic version to use in variables
            ARMOR_ID: [13],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  12 => {
            NAME: "EARTHDATA",
            SHOWNNAME: "Earth Data",  #this cosmetic version to use in variables
            ARMOR_ID: [14],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  13 => {
            NAME: "ADMIN",
            SHOWNNAME: "Administrator",  #this cosmetic version to use in variables
            ARMOR_ID: [15],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
  14 => {
            NAME: "EARTHLING",
            SHOWNNAME: "Human - Earth",  #this cosmetic version to use in variables
            ARMOR_ID: [2],
            ABILITYTEXT: [SKILL[:TENCOMMAND]],  
            },
            
  }# DO NOT TOUCH THIS LINE

  USE_DEFAULT_RACE = false
  DEFAULT_RACE = 1

####### END RACE CONFIGURATION PART ###################################
  RACE_TAG = /<(?:RACE|TRIBE):\s*(\w+)>/i
#  RACE_TAG = /<race:[ ]*(\w+.)>/i 
  
end

#load notetags part
class RPG::Actor < RPG::BaseItem
  attr_accessor :race
  def load_notetags_race
      if ESTRIOLE::USE_DEFAULT_RACE
      @race = ESTRIOLE::RACE[ESTRIOLE::DEFAULT_RACE][:NAME]
      else
      @race = nil
      end
      self.note.split(/[\r\n]+/).each { |line|
      case line
      when ESTRIOLE::RACE_TAG
        @race = $1
      end
      } #end note split
  end
end

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_est_race1234 load_database; end
  def self.load_database
    load_database_est_race1234
    load_notetags_est_race_333
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_armpos
  #--------------------------------------------------------------------------
  def self.load_notetags_est_race_333
      for obj in $data_actors
        next if obj.nil?
        obj.load_notetags_race
      end
      puts "Read: actor race Notetags"
  end  
end # DataManager


class Game_Actor < Game_Battler

  alias est_race_feature_setup setup
  def setup(actor_id)
  @race_features = Race_Features.new
  @race_features.features = []
  set_race_features(actor_id) if $data_actors[actor_id].race != nil
  est_race_feature_setup(actor_id)
  end
  
  def get_armor_race(id)
    for i in 1..ESTRIOLE::RACE.size
    actor_race = $data_actors[id].race
    check = /#{actor_race}/i.match(ESTRIOLE::RACE[i][:NAME])      
    return ESTRIOLE::RACE[i][:ARMOR_ID] if check
    end
    return nil
  end

  def get_race_name
    for i in 1..ESTRIOLE::RACE.size
    actor_race = $data_actors[@actor_id].race
    next if !actor_race
    check = /#{actor_race}/i.match(ESTRIOLE::RACE[i][:NAME])      
    return ESTRIOLE::RACE[i][:SHOWNNAME] if check
    end
    return nil
  end
  
  def get_ability_text
    for i in 1..ESTRIOLE::RACE.size
    actor_race = $data_actors[@actor_id].race
    next if !actor_race
    check = /#{actor_race}/i.match(ESTRIOLE::RACE[i][:NAME])      
    return ESTRIOLE::RACE[i][:ABILITYTEXT] if check
    end
    return nil
  end  
  
  def set_race_features(id)
  armor_ref = get_armor_race(id)
    if armor_ref!=nil
      for i in 0..armor_ref.size-1
      @race_features.features += $data_armors[armor_ref[i].to_i].features
      end
    end
  end  
  
  def change_race(race_name)
  #change race
  $data_actors[@actor_id].race = race_name
  @race_features.features = []
  set_race_features(@actor_id) if $data_actors[@actor_id].race != nil
  end
  
  alias est_feature_objects feature_objects
  def feature_objects
    est_feature_objects + [@race_features]
  end

end


class Race_Features
  attr_accessor :features
end