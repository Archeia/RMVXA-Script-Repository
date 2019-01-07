=begin
#==============================================================================
 Title: Exp Tables
 Author: Hime
 Date: Apr 22, 2014
-------------------------------------------------------------------------------
 ** Change log
 Apr 22, 2014
   - added support for ID headers
 Nov 19, 2013
   - minor updates
 Nov 11, 2012
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
------------------------------------------------------------------------------
 ** Description
 
 This script allows you to manage your EXP tables using external tools such
 as spreadsheet programs or text editors.
 
 There are two ways to manage EXP: Actor EXP tables, and Class EXP tables.
 All data is stored in external files so you can easily transfer them between
 games.
 
--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

-------------------------------------------------------------------------------- 
 ** Usage
 
 Start by downloading the appropriate EXP Table template from the download
 page and place them in your Data folder. You can change where these files
 are to be stored in the configuration.
 
 To set up the exp tables, simply fill each row in.
 
 For the class EXP table, each column header is the name of your class.
 For the actor EXP table, each column header is the name of your actor.
 
 Note that the script does not support unicode characters, so if your name
 doesn't work, you can specify the actor or class ID instead.
 
 If you are using a spreadsheet program such Microsoft Excel or
 OpenOffice Spreadsheet, it is easy to edit the files: simply open it as a 
 csv file and you're ready to go.
 
 If you are using a regular text editor, you will need to remember to follow
 the csv format.
 
 So for example, in the class exp table, your first line should look like
   ;Soldier;Monk; ...
   
 If you're using ID's instead, it might look like this instead
   ;1;2; ...
    
 For each row afterwards, you start with the level, followed by exp required
 for each class
   
   1;0;0; ...
   2;100;100; ...
   3;200;250; ...
   
 You should complete the table up to the max level + 1.
 
 If your game crashes while comparing exp, it's because your exp tables
 are not setup properly.
------------------------------------------------------------------------------
=end
$imported = {} if $imported.nil?
$imported["TH_ExpTables"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module TH
  module Exp_Tables
    
    # Where your data is stored
    Actor_Exp_Path = "Data/actor_exp.csv"
    Class_Exp_Path = "Data/class_exp.csv"
    
    # File format. CSV is fixed, but you may change the delimiter
    File_Format = ".csv"
    Delimiter = ","
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================

module RPG
  
  class Actor
    def has_exp_table?
      !@exp_table.nil?
    end
    
    def exp_for_level(level)
      get_exp_table(level)
    end
    
    def get_exp_table(level)
      @exp_table[level]
    end
    
    def load_exp_table
      begin
        data = load_data(TH::Exp_Tables::Actor_Exp_Path)
      rescue
        return
      end
      data = data.split.map!{|str| str.downcase.split(TH::Exp_Tables::Delimiter)}
      
      index = data[0].index(@id.to_s) 
      index = data[0].index(@name.downcase) unless index
      return unless index      
      @exp_table = {}
      data[1..-1].each {|row|
        level = row[0].to_i
        exp = row[index].to_i
        @exp_table[level] = exp
      }
      
    end
  end
  
  class Class
    
    alias :th_exp_tables_exp_level :exp_for_level
    def exp_for_level(level)
      return get_exp_table(level) if @exp_table
      return th_exp_tables_exp_level(level)
    end
    
    def get_exp_table(level)
      @exp_table[level]
    end
    
    def load_exp_table
      begin
        data = load_data(TH::Exp_Tables::Class_Exp_Path)
      rescue
        return
      end
      data = data.split.map!{|str| str.downcase.split(TH::Exp_Tables::Delimiter)}
      index = data[0].index(@id.to_s) 
      index = data[0].index(@name.downcase) unless index
      return unless index      
      @exp_table = {}
      data[1..-1].each {|row|
        level = row[0].to_i
        exp = row[index].to_i
        @exp_table[level] = exp
      }
    end
  end
end

module DataManager
  
  class << self
    alias :th_exp_tables_init :init
  end
  
  def self.init
    th_exp_tables_init
    load_exp_tables
  end
  
  def self.load_exp_tables
    ($data_actors | $data_classes).each {|obj|
      next unless obj;  obj.load_exp_table
    }
  end
end

class Game_Actor < Game_Battler
  
  alias :th_exp_tables_for_level :exp_for_level
  def exp_for_level(level)
    return actor.exp_for_level(level) if actor.has_exp_table?
    return th_exp_tables_for_level(level)
  end
end

#-------------------------------------------------------------------------------
# Load files from non-RM files
#-------------------------------------------------------------------------------
class << Marshal
  alias_method(:th_core_load, :load)
  def load(port, proc = nil)
    th_core_load(port, proc)
  rescue TypeError
    if port.kind_of?(File)
      port.rewind 
      port.read
    else
      port
    end
  end
end unless Marshal.respond_to?(:th_core_load)