# Graphical Object Global Reference
# v 1.21 VXACE
# A debugger script.
# Created by Mithran
# hosted at forums.rpgmakerweb.com

# Created to address the issue of specific Game.exe crashes during play
# Special thanks to Galv for information on the ACE version of the crash

%q( 
AUTHOR'S NOTE: The following description primarily describes the VX (RGSS2) 
version of the crash.  The VX ACE crash shares some circumstances with the VX 
crash.  This script and instructions were written to address the VX issue then
updated to work in VX ACE.  This script itself may or may not stop crashes in ACE 
as it did with VX, but it can be used to log undisposed sprites and stop the 
error from happening in the first place.


The cause of a given Game.exe crash could be any number of things - anything that 
doesn't create throw an error in Ruby, but causes an unhandled exception in one 
of the 'hidden' classes.

After extensive testing, I was finally able to recreate the circumstances leading
up to one such exception that, if left unhandled, could lead to Game.exe crash.  

1. A "GO" - Graphical Object (Sprite, Window, Plane, or Tilemap) is created
2. The Graphical Object is assigned a Viewport
3. The Viewport is disposed, but the sprite is not
?? - VX ACE Version.  There is a yet unknown factor that also needs to happen.
4. The Graphical Object is claimed by GC (garbage disposal)*

* - Newly Discovered: attempting to dispose a sprite that has a disposed viewport
    will occasionally also crash. (v 1.1)
    Note that this particuar crash only seems to occur if screen draws have taken
    place (any of the Graphics methods) between the time the viewport is disposed
    and the sprite disposal is attempted.

Due to the way GC is implemented, you are unlikely to see an immediate effect 
when the situation comes up.  It could be several scene changes down the line
before the crash finally happens.  To make matters worse, following the exact
same course of action will yield completely different results, making it seem
as though the crashes are random.  In addition, there is yet another circumstance
which I have still been unable to pinpoint, but I suspect has something to do
with the order in which assets associated with the Graphical Object are claimed
by the GC, or the amount of screen rewdraws that have taken place,
that allows the GO to be cliamed without causing an exception and
thus making it even harder to find.

In essence: you could be suffering from an unstable game and not even know it.

So that is where this little script comes in.  This does the following:

1. Creates a global variable backreference to every Graphical Object created.
  This prevents them from being marked by the GC so long as the reference exists, 
  circumventing the final condition to cause this version of the crash.
  
2. Removes reference to the Graphical Object once it has been disposed.
  This reallows the object to be marked by GC for disposal (once all other
  references are removed).  Since the GO is disposed, condition 3 is no longer met
  and the object is deemed 'safe'.
  
3. Report on potential issues to the user.
  This allows the user (given limited scripting knowledge) to identify potential
  errors and fix them outright.
  
4. Prevents further Game.exe crashes caused by this specific issue.
  Includes a 'lazy' fix that cleans up offending Graphical Objects when the scene
  changes.*
  
* v 1.1 'Lazy' fix has been superceeded to prevent crashes caused by disposal of
    these errant sprites.  Lazy fix only works if debug criticial disposal has 
    been disabled.
    
Version History:

v 1.2 VX ACE
  Discovered possibility of crash in RGSS3.  Thanks to Galv for bringing the 
  problem to my attention and supplying a script to use as a test case.
  Updated logging features to specificially work with VX ACE.  RGSS Console must
  be enabled to recieve live updates.  
  Added GOBJ_ABRIDGED_LOG option.
  Altered some terms in the log.  Specifically changed the term 'non-critical object'
  to 'Memory Leak' so the term 'Critical Object' can be searched in the log.
  Time in log now refers to creation time of the object.
  
v 1.1
  Discovered a new condition for a Game.exe crash.  Updated script to trap and log
  this error also.
  
v 1.01-1.05
  Minor bugfixes, improved logging, added consideration for Plane objects viewport method error

v 1.0 
  Initial Release
    
)
# Creates a global refrence list to all graphical objects, preventing them from
# ever being garbage collected.  Objects from this list are removed when the object
# runs its dispose method, thereby allowing them to be GC'd.  

# Has a built in layer to notify the player if the scene changes with live 
# graphical objects in play.  As a rule, this should almost never happen.  Certain
# scripts have sprites that are used across every scene and never disposed,
# thus intentionally having an additional global reference (such as mouse script)
# As such, they should never generate a critical error.  However, they can be manually
# exempted from being detected by this script by using the instance method 
# 'gobj_exempt' on the sprite.  In the case of Woratana's Simple Mouse/Jets Mouse
# simply place my script as low as possible on the scripts list, but above Main,
# to avoid conflicts.

GOBJ_NOTIFY_LEAK = false # when true, displays a list of undisposed graphical objects
# every time the scene changes.  This includes all graphical objects

GOBJ_NOTIFY_CRITICAL = false # when true, displays information regarding critical 
# graphical object disposal oversights on scene switch.  These are the errors 
# that could otherwise turn into a Game.exe crash.

# The above two options print a message directly to the screen.

GOBJ_DEBUG_FILE = true # makes a file (gobj.txt) in the game directory containing
# information about new critcal objects whenever a scene switches
# the list includes: 
# the time the error was recorded
# the object's class and ID
# the scene it was created during (NilClass = in a script before any scene was created)
# and the 'caller', or the list of methods run prior to this object's creation
# the first line on caller will generally be the location of where the 
# offending object was initially CREATED
# HOWEVER, the error this script addresses is that this object is never DISPOSED
# of properly.  Knowing where the object will only allow a scripter to go back
# and properly dispose of the object at the correct time.

GOBJ_LOG_NON_CRITICAL = true
# if set to true creates log entries for non-critical objects that are not disposed
# between scenes.  Only works if GOBJ_DEBUG_FILE is also set to true.
# if you have a game.exe crash that seems to pop up randomly after a while
# try using this and see if there are any unfreed objects at all

GOBJ_LAZY = false
# turn this to true and graphical objects without disposed viewports will be disposed
# when the scene changes.  It is recommended this setting not be used and instead
# the code be cleaned up directly.
# v 1.21 This function now only affects sprites without disposed viewports.
# Sprites must be kept in memory to prevent a crash if their viewport has already 
# been disposed. 

GOBJ_DEBUG_CRITICAL_DISPOSAL = true
# disables disposal of GO that have had their viewports already disposed
# this is only considered unsafe if screen redraws have taken place between the 
# time that the viewport and sprite are disposed.
# Some of the base scripts dispose viewport immediately before the sprites, which
# has never been known to cause errors, therefore, this option has been added to
# circumvent dealing with these type of objects.  Turn this on if you continue
# to get Game.exe crashes that are not logged.

GOBJ_ABRIDGED_LOG = false
# logs only the basic info about the created object and not the whole stack

GOBJ_NOTIFY_REPEAT_DISPOSE = false
# notifies (to console) when a repeat dispose is attempted on the same object
# while normally ignored, repeat disposes are indicative of poor sprite control

GOBJ_LOG_REPEAT_DISPOSE = false
# logs repeat disposes


# --- End Setup
  $gobj = []

  
[Sprite, Plane, Window, Tilemap].each { |cl|
class << cl
  alias new_gobj new unless $@
  def new(*args)
    obj = new_gobj(*args)
    ary = [obj, SceneManager.scene.class, nil, nil, Time.now]
    if GOBJ_ABRIDGED_LOG
      ary[2] = (caller[0..0]) if GOBJ_DEBUG_FILE # add caller list if debug file is enabled
    else
      ary[2] = (caller) if GOBJ_DEBUG_FILE # add caller list if debug file is enabled      
    end
    # if object is disposed already during initialization, dont add it
    $gobj.push(ary) unless obj.disposed? 
    obj
  end
  
end

cl.class_eval {

  alias dispose_gobj dispose unless $@
  def dispose
    if self.disposed?
      p "#{self} is already disposed!" if GOBJ_NOTIFY_REPEAT_DISPOSE 
      File.open("gobj.txt", "a") do |f| 
        f.print "\n-----\n"
        f.print("Time: #{Time.now}\n")
        f.print "Warning: #{self} is attempting a repeat dispose.\n" 
        f.print("Calling #{GOBJ_ABRIDGED_LOG ? 'Point' : 'Stack' }:: \n")
        stk = GOBJ_ABRIDGED_LOG ? caller[2..2] : caller[2..caller.size]
        stk.each { |e| e.gsub!(/\{(\d+)\}\:(\d+)/i) { |m| 
        "Script #{$1} -- #{ScriptNames[$1.to_i]}, Line: #{$2}" }
        } # close stk.each
        outp = stk.join("\n")
        f.print(outp)
      end if GOBJ_LOG_REPEAT_DISPOSE 
    elsif !disposed? && GOBJ_DEBUG_CRITICAL_DISPOSAL && viewport && viewport.disposed?
      o = $gobj.find { |a| a[0] == self }
      print "#{o[0]} created in #{o[1]} is attempting to dispose with a disposed viewport!\n" if GOBJ_NOTIFY_CRITICAL
      if GOBJ_DEBUG_FILE && !o[3]
        gobj_log_to_file(o, true)
        o[3] = true
      end
      return
    end
    gobj_exempt   # remove from global reference
    dispose_gobj # original dispose
  end
  
  def gobj_exempt
    $gobj.delete_if { |a| a[0] == self } 
  end

} # class eval

} # each class

class Scene_Base
  alias main_gobj main unless $@
  def main
    if $TEST && $gobj.size > 0 
      p 'Live Graphical Object List:', $gobj.collect { |o| o[0..1] } if GOBJ_NOTIFY_LEAK
      $gobj.clone.each { |o| 
      next o[0].gobj_exempt if o[0].disposed?
      critical = o[0].viewport && o[0].viewport.disposed? 
      print "#{o[0]} created in #{o[1]} is a potential for Game.exe crash!\n" if GOBJ_NOTIFY_CRITICAL && critical
      if GOBJ_DEBUG_FILE && !o[3] && (critical or GOBJ_LOG_NON_CRITICAL)
        gobj_log_to_file(o, critical)
        o[3] = true # do not log again this instance
      end
      if GOBJ_LAZY && !critical
        o[0].dispose
      end
      } # close $gobj.each
    end # debug branch
    main_gobj  #original method
  end
  
  
end

module Kernel
  
  def gobj_log_to_file(o, critical)
    File.open("gobj.txt", "a") { |f|
    f.print "\n-----\n"
    f.print("Time: #{o[4]}\n")
    f.print("#{critical ? 'CRITICAL OBJECT' : 'Memory Leak'} #{o[0]}\n")
    f.print("In Scene #{o[1]}\n")
    f.print("Creation #{GOBJ_ABRIDGED_LOG ? 'Point' : 'Stack' }:: \n")
    o[2].each { |e| e.gsub!(/\{(\d+)\}\:(\d+)/i) { |m| 
    "Script #{$1} -- #{ScriptNames[$1.to_i]}, Line: #{$2}" }
    } # close o[2].each
    outp = o[2].join("\n")
    f.print(outp)
    } # close file
  end
  
end

class Viewport
  alias dispose_gobj dispose unless $@
  def dispose
    @disposed = true
    dispose_gobj
  end
  
  def disposed?
    @disposed
  end
  
end

ScriptNames = {}

$RGSS_SCRIPTS.each_with_index { |s, i| ScriptNames[i] = s[1] } 

#load_data("Data/Scripts.rvdata2").each_with_index {|s, i| ScriptNames[i] = s[0] }