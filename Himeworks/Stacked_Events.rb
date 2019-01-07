=begin
#===============================================================================
 Title: Stacked Events
 Author: Hime
 Date: Jun 2, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 2, 2013
   - Fixed bug where multiple stack events were not created correctly
 Apr 7, 2013
   - added support for multiple stack assignment
   - initial release
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
 
 This script allows you to indirectly stack events by using a single event
 to store event pages for multiple events. The game then sorts the pages
 and then splits it up into multiple events that are stacked on top of each
 other.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To create a stacked event, you need to do two things
 
 1. The name of the event must have the word [stack]
 2. Each page must indicate which event in the stack they belong to.
 
 For each page, create a comment of the form
 
   <stack: x>
   
 Where x is some value used to distinguish between different events in the
 stack. The value you choose is not important as long as you are consistent.
 The pages will be grouped based on these stack ID's. You can use numbers
 or letters, or even words.
 
 A single page can be added to multiple stack events, rather than duplicating
 the same page again and again for each event in the stack. Simply add multiple
 ID's to the comment and they will be added appropriately, separating each ID
 by a space.
 
   <stack: 1 2 3>
  
 This will add the page to stacks 1, 2, and 3.
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StackedEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Stacked_Events
    
    Stack_Name = /\[stack\]/i
    Stack_Regex = /<stack: (.*)>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Event
    
    def stack_event?
      return @is_stack_event unless @is_stack_event.nil?
      parse_event_name_stack_event
    end
    
    def parse_event_name_stack_event
      res = self.name.match(TH::Stacked_Events::Stack_Name)
      @is_stack_event = !res.nil?
    end
    
    #---------------------------------------------------------------------------
    # Split the pages into separate stacks based on the stack ID, then return it
    #---------------------------------------------------------------------------
    def split_stack
      new_pages = {}
      @pages.each do |page|
        page.list.each do |cmd|
          if cmd.code == 108 && cmd.parameters[0] =~ TH::Stacked_Events::Stack_Regex
            stack_ids = $1.split
            stack_ids.each do |id|
              new_pages[id] ||= []
              new_pages[id] << page
            end
            next
          end
        end
      end
      return new_pages
    end
  end
  
  class Map
    def split_stacked_events
      new_events = {}
      temp_events = @events.clone
      temp_events.each do |id, event|
        next unless event.stack_event?
        page_stacks = event.split_stack
        stack_events = create_stack_events(event, page_stacks)
        @events.merge!(stack_events)
      end
    end
    
    #---------------------------------------------------------------------------
    # Takes a set of page stacks and put them into their own events
    # The first stack will be the original event ID, but the rest will have
    # their own, uniquely assigned event ID's
    #---------------------------------------------------------------------------
    def create_stack_events(event, page_stacks)
      new_events = {}
      # first event
      first_stack = page_stacks.shift
      ev = RPG::Event.new(event.x, event.y)
      ev.id = event.id
      ev.pages = first_stack[1]
      new_events[ev.id] = ev
      
      max_id = @events.keys.max
      # rest of the events      
      page_stacks.each do |stack_id, pages|
        max_id += 1
        ev = RPG::Event.new(event.x, event.y)
        ev.id = max_id
        ev.pages = pages
        new_events[max_id] = ev
      end
      return new_events
    end
  end
end

class Game_Map
  
  alias :th_stacked_events_setup_events :setup_events
  def setup_events
    @map.split_stacked_events
    th_stacked_events_setup_events
  end
end