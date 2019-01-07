=begin
EST - SIMPLE EVENT PAGES CONTROLLER
v.1.2a
Author: Estriole

also credits: 
1) Tsukihime
for giving me inspiration to create this script.
2) Killozapit
for giving me idea to use actual event pages so it can used by other event
  
Version History
v.1.0  - 2013-01-13 - finish the script
v.1.1  - 2013-01-16 - add ability to change event force page by name using string
                      or regexp.
                      example string: set_event_force_page(4,"test 1",3)
                      this will change all event with the name test 1 (not case sensitive)
                      example regexp: set_event_force_page(4,/test (.*)/i,3)
                      this will change all event that contain test x in name. 
                      so event with these name will change it's force page:
                      test 1, test 2, test 3, battle test 1, battle test abc, etc
                      this feature only useful for people who generate event ingame
                      using either event spawner, copier, etc. since they won't know the id
                      of that event until generated.
v.1.2  - 2013-01-18 - add function to use other event pages by setting the force page
                      to RPG::Event:Page object. also added new game interpreter
                      method to make even beginner able to use it. :D(hopefully)
v.1.2a - 2013-01-18 - fix some error with new method if map/event not exist.
                      also renamed the script (change system to controller) to
                      describe this script better. (i decide to stick with simple word :D)
                      
Introduction
Did you have many pages event and have hard time setting it right. this might be
your answer. by default the event page system is like this:
from the last page it check for that page condition. if condition met than use that
page. 

Imagine if your event pages is 100. and at start it use page 100. then you want by
choosing something in page 100 will make the event goes to page 1.
if default system you need to make ALL the event page 2 to 100 condition to NOT met.
this could cost you a whole lots of Switches...

this script make you able to bypass those. now you can just specify the event pages
you want to the event to use. and if not set it still use default event pages system.
if you want simpler explanation. just imagine this as label and go to label command.
but for pages.

and i also add that that chosen page also get checked for it's condition. so if that
chosen page condition not met it will be no page selected (blank event)

example i have these event pages:
page 1 - condition switch 1 on - set force page to page 2
page 2 - condition none - do something
page 3 - condition none - set force page to page 1

the event will be use page 3 (since you havent interact / turn on /off switch and also
because that last page condition is met thus that last page used)

then by talking to that event you set force page to page 1.
but you haven't turn on the switch 1 so it will be blank event. then when you
turn on switch 1. that event will use page 1. and by talking to that event will
proceed to page 2. and by talking again to event it will do something
note: should i make demo about this? i think it's clear enough.

you could also make all the pages without condition and then treat it like go to page.
just remember the event will pick your last page at the first time

How to use
1) Script call:

set_this_event_force_page(page_id)

->this will set current event to that page id

2) Script call:

set_event_force_page(map_id,event_id,page_id)

->this will set event id in that map id to that page id
->from 1.1 above: event_id can be number/event name/ regexp format

you could set the page_id to nil for both method to use default event page system

*** new from v.1.2 above ***
3) Script call:

event_use_page(map_id,event_id,source_map_id,source_event_id,source_page_id)

->this will set event id in that map id to use page from another event.
->event_id can be number/event name/ regexp format
->source_event_id cannot use event name/regexp. it must be number.

you could set the page_id to nil for both method to use default event page system


Compatibility
i think this compatible with most script. and it also don't break existing project.
since existing project event don't have force page set for them thus using default
event page system.

=end
class Game_Event < Game_Character
  attr_accessor :force_page  
  attr_reader   :event  
  alias est_force_event_page_find_page find_proper_page
  def find_proper_page
    return [@force_page].find{|page| conditions_met?(page)} if @force_page.is_a?(RPG::Event::Page) 
    if @force_page && @force_page > 0 && @force_page <= @event.pages.size
    return [@event.pages[@force_page-1]].find{|page| conditions_met?(page)}
    end
    est_force_event_page_find_page
  end
end

class Game_Interpreter
  def set_this_event_force_page(page_id)
    $game_map.force_pages[@map_id] = {} if !$game_map.force_pages[@map_id]
    $game_map.force_pages[@map_id][@event_id] = page_id
    $game_map.events[@event_id].force_page = page_id
    $game_map.refresh
  end
  def set_event_force_page(map_id,event_id,page_id)
    $game_map.force_pages[map_id] = {} if !$game_map.force_pages[map_id]
    $game_map.force_pages[map_id][event_id] = page_id
    if @map_id == map_id
      event_id = $game_map.get_event_id_by_name(event_id) if event_id.is_a?(String) or event_id.is_a?(Regexp)
      event_id = [event_id] if event_id.is_a?(Fixnum)
      event_id = event_id.to_a if !event_id.is_a?(Array)
      return if event_id == nil
      event_id.each do |id|  
        if $game_map.events[id]
        $game_map.events[id].force_page = page_id
        $game_map.refresh
        end #end if 
      end #end do
    end #end if
  end #end def
  def event_use_page(map_id,event_id,source_map_id,source_event_id,source_page_id)
    map = load_data(sprintf("Data/Map%03d.rvdata2", source_map_id)) rescue nil
    #event = map.events[source_event_id] rescue nil#if map
    page = map.events[source_event_id].pages[source_page_id-1] rescue nil#if event
    return if !page
    $game_map.force_pages[map_id] = {} if !$game_map.force_pages[map_id]
    $game_map.force_pages[map_id][event_id] = page
    if @map_id == map_id
      event_id = $game_map.get_event_id_by_name(event_id) if event_id.is_a?(String) or event_id.is_a?(Regexp)
      event_id = [event_id] if event_id.is_a?(Fixnum)
      event_id = event_id.to_a if !event_id.is_a?(Array)
      return if event_id == nil
      event_id.each do |id|  
        if $game_map.events[id]
        $game_map.events[id].force_page = page
        $game_map.refresh
        end #end if 
      end #end do
    end #end if
  end #end def set event force page pm
end #end class game interpreter

class Game_Map
  attr_accessor :force_pages
  alias est_force_event_page_game_map_init initialize
  def initialize
    est_force_event_page_game_map_init
    @force_pages = {}
  end

  alias est_force_event_page_setup_events setup_events
  def setup_events
      est_force_event_page_setup_events
      if @force_pages[@map_id]
        @force_pages[@map_id].each do |key,value|
          ids = key
          ids = get_event_id_by_name(key) if ids.is_a?(String) or ids.is_a?(Regexp)
          ids = [ids] if ids.is_a?(Fixnum)
          ids = ids.to_a if !ids.is_a?(Array)
          next if !ids
          ids.each do |id|
            @events[id].force_page = value if @events[id]
          end
        end
      end
      refresh
      refresh_tile_events
  end
  
  def get_event_id_by_name(string)
    event = []
     @events.each do |key,value|
       if string.is_a?(String)
       event.push(value) if value.name.upcase == string.upcase 
       else
       event.push(value) if string.match(value.name)
       #event.push(value) if value.name.match(string)
       end
     end
    return false if !event
    return id = event.collect{|ev|ev.id}
  end  
end