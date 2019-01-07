=begin
#===============================================================================
 Title: Large Troops
 Author: Hime
 Date: Mar 9, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 9, 2013
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
 
 This script combines multiple troops into a single troop.
 You will still set them up as separate troops, but at run-time they will
 be merged together.
 
 All events will be merged and updated as required.
 
--------------------------------------------------------------------------------
 ** Usage 
 
 Create a comment on the first page of the troop events with the following
 string
 
   <parent troop: x>
   
 Where x is the ID of the troop that this troop should extend.
 All of the enemies and event pages will be merged.
 
 You can set up the troop events as you normally do without having to worry
 about indexing. The only thing you need to worry about is where to place
 the sprites.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_LargeTroops"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Large_Troops
    
    Regex = /<parent troop: (\d+)/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class Troop
    #---------------------------------------------------------------------------
    # New. Merges the other troop with this troop
    #---------------------------------------------------------------------------
    def add_extended_troop(troop)
      add_extended_pages(troop)
      @members.concat(troop.members)
    end
    #---------------------------------------------------------------------------
    # New. Merge other troop's pages with this troop
    #---------------------------------------------------------------------------
    def add_extended_pages(troop)
      new_pages = setup_extended_pages(troop.pages)
      @pages.concat(new_pages)
    end
    
    #---------------------------------------------------------------------------
    # New. Update all indices in enemy-related commands to point to the correct 
    # member when they are added to the troop
    #---------------------------------------------------------------------------
    def setup_extended_pages(pages)
      member_offset = self.members.size
      page_offset = self.pages.size
      new_pages = pages.clone
      new_pages.each {|page|
        page.list.each {|cmd|
          case cmd.code
          when 331, 332, 333, 336, 337
            cmd.parameters[0] += member_offset unless cmd.parameters[0] == -1
          when 335
            cmd.parameters.map! {|member_id| member_id += member_offset } unless cmd.parameters[0] == -1
          when 339
            cmd.parameters[1] += member_offset if cmd.parameters[0] == 0
          end
        }
      }
      return new_pages
    end
  end
end

module DataManager
  class << self
    alias :th_large_troops_load_database :load_database
  end
  
  def self.load_database
    th_large_troops_load_database
    load_large_troops
  end
  
  #-----------------------------------------------------------------------------
  # New. Setup all extended troops
  #-----------------------------------------------------------------------------
  def self.load_large_troops
    $data_troops.each {|troop|
      next unless troop
      troop.pages[0].list.each {|cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Large_Troops::Regex
          $data_troops[$1.to_i].add_extended_troop(troop)
        end
      }
    }
  end
end