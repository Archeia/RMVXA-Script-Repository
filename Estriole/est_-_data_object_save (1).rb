=begin
EST - DATA OBJECT SAVE
v 1.0

Author : Estriole
also credits : Tsukihime since i learn this custom database from his script

Version History
v. 1.0 - 2013-01-07 - finish the script

Introduction
if you have script that modify the $data object such as $data_actors,
$data_weapons, etc (usually capture system, individual item script, etc)

you would like to save the changes you made in game (in case you have
dynamic system)

this script save all the $data objects in save file. then load it when
loading the data. so we can keep our changes.

=end

#module data manager to save all the changes to $data object
#but be careful when changing thing directly to $data object
module DataManager
  
  class << self
    alias est_objects_save_make_save_contents make_save_contents
    alias est_objects_save_extract_save_contents extract_save_contents
  end
    
  def self.make_save_contents
    contents = est_objects_save_make_save_contents
    contents = contents.merge(make_object_save_contents)
    contents
  end
  
  def self.make_object_save_contents
    contents = {}
    contents[:data_actors]	       =	$data_actors
    contents[:data_classes]	       =	$data_classes    
    contents[:data_skills]	       =	$data_skills
    contents[:data_items]	         =	$data_items
    contents[:data_weapons]	       =	$data_weapons
    contents[:data_armors]	       =	$data_armors
    contents[:data_enemies]	       =	$data_enemies    
    contents[:data_troops]	       =	$data_troops    
    contents[:data_states]	       =	$data_states
    contents[:data_tilesets]	     =	$data_tilesets
    contents[:data_common_events]	 =	$data_common_events
    contents[:data_system]	       =	$data_system
    contents[:data_mapinfos]	     =	$data_mapinfos
    contents
  end

  def self.extract_save_contents(contents)
    est_objects_save_extract_save_contents (contents)
    extract_objects_save_contents(contents)
  end
  
  def self.extract_objects_save_contents(contents)
    $data_actors             =    contents[:data_actors]	     
    $data_classes            =    contents[:data_classes]	     
    $data_skills             =    contents[:data_skills]	     
    $data_items              =    contents[:data_items]	       
    $data_weapons            =    contents[:data_weapons]	     
    $data_armors             =    contents[:data_armors]	     
    $data_enemies            =    contents[:data_enemies]	     
    $data_troops             =    contents[:data_troops]	     
    $data_states             =    contents[:data_states]	     
    $data_tilesets           =    contents[:data_tilesets]	   
    $data_common_events      =    contents[:data_common_events]
    $data_system             =    contents[:data_system]	     
    $data_mapinfos           =    contents[:data_mapinfos]	   
  end
  
end