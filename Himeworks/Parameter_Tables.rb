=begin
#===============================================================================
 Title: Parameter Tables
 Author: Hime
 Date: Dec 7, 2013
 URL: http://himeworks.com/2013/11/20/parameter-tables/
--------------------------------------------------------------------------------
 ** Change log
 Dec 7, 2013
   - fixed bug where all values were stored in a 2-byte integer
 Nov 23, 2013
   - fixed bug where game crashed if enemy didn't have a param table
 Nov 20, 2013
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
 
 This script allows you to manage your parameters using external tools such
 as spreadsheet software or text editors. The values that you enter are
 "base parameters": features are applied on top of these values.
 
 You can set up parameter tables for the following objects
 
 - Actors
 - Classes
 - Enemies
 
 The parameters are stored in csv files, one for each actor or class.
 You can specify the parameters for each level. Currently, there is only
 support for built-in basic parameters.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 Download the templates from the download page. Copy and rename them as needed
 for all of your objects.
 
 -- Storing your Files --
 
 All actors, classes, and enemies will store their parameter tables separately.
 All tables must be stored in the directory specified in the configuration.
 You may change where this directory is stored. You should place it inside
 the Data folder (or a subfolder in the Data folder) if you want the files to
 be encrypted when you distribute your project.
 
 -- Parameter Table Filenames --
 
 The format of the parameter table filename is
 
   params_actor#.csv
   params_class#.csv
   params_enemy#.csv
   
 So for example,
 
   params_actor7 is the table for actor 7
   params_class12 is table for class 12
   params_enemy2 is the table for enemy 2
   
 -- Param Table Format --
 
 The order of the table columns are hardcoded. You should use the template that
 I have prepared. The order of the columns are as follows:
 
 Level, MHP, MMP, ATK, DEF, MAT, MDF, AGI, LUK
 
 The first line contains the headers.
 The headers themselves are not used and is only for reference.
   
 -- Precedence --
   
 For actors, it will try to read from the actor table, and then the class table,
 and finally it will default to the class param curves.
 
 For enemies, it will try to read from the enemy table, and then default to
 the enemy params. If no enemy level script is used, then the enemy is assumed
 to be level 1.

 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ParamTables"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Param_Tables
    
    # Where to store parameter tables
    Param_Directory = "Data/Params"
    
    # Prefixes for your filenames. For example, 
    Actor_Prefix = "params_actor"
    Class_Prefix = "params_class"
    Enemy_Prefix = "params_enemy"
    
    def has_param_table?
      !self.param_table.nil?
    end
    
    def param_table
      load_param_table unless @param_table_checked
      return @param_table
    end
    
    def load_param_table
      @param_table_checked = true
      dir = TH::Param_Tables::Param_Directory
      filename = sprintf("%s%d.csv", param_file_prefix, @id)
      path = File.join(dir, filename)
      begin
        data = load_data(path)
      rescue
        p 'no table found for %s' %path
        return
      end
      
      data = data.split($INPUT_RECORD_SEPARATOR)      
      
      # Don't use tables, since they only signed 2-byte integers.
      # For a range (-32677, 32678)
      @param_table = Data_ParamTable.new
      
      data[1..-1].each do |line|
        line = line.split(",")
        level = line[0].to_i
        for i in 0..7
          @param_table[i, level] = line[i+1].to_i
        end
      end
    end
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  
  class Actor < BaseItem
    include TH::Param_Tables
    
    def param_file_prefix
      TH::Param_Tables::Actor_Prefix
    end
    
    def params
      return @param_table if self.param_table
    end
  end
  
  class Class < BaseItem
    include TH::Param_Tables
    
    def param_file_prefix
      TH::Param_Tables::Class_Prefix
    end
    
    def params
      return @param_table if self.param_table
      return @params
    end
  end
  
  class Enemy < BaseItem
    include TH::Param_Tables
    
    def param_file_prefix
      TH::Param_Tables::Enemy_Prefix
    end
    
    def params
      return @param_table if self.param_table
      return @params
    end
  end
end

class Data_ParamTable
  
  def initialize
    @data = []
  end

  def [](x, y)
    @data[x] ||= []
    @data[x][y] || 0
  end
  
  def []=(x, y, value)
    @data[x] ||= []
    @data[x][y] = value
  end
end

class Game_Actor < Game_Battler
  
  alias :th_param_tables_param_base :param_base
  def param_base(param_id)
    return actor.param_table[param_id, @level] if actor.has_param_table?
    th_param_tables_param_base(param_id)
  end
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Change it to support levels
  #-----------------------------------------------------------------------------
  alias :th_param_tables_param_base :param_base
  def param_base(param_id)
    if enemy.has_param_table?
      if @level
        return enemy.params[param_id, @level]
      else
        return enemy.params[param_id, 1]
      end
    end
    th_param_tables_param_base(param_id)
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