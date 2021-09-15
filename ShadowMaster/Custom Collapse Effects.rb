=begin
===============================================================================
Custom Collapse Effects V1.6 (01/8/2015)
-------------------------------------------------------------------------------
Created By: Shadowmaster/Shadowmaster9000/Shadowpasta(www.crimson-castle.co.uk)
===============================================================================
Information
-------------------------------------------------------------------------------
This script allows you to customise collapse effects for both enemies and even
actors (collapse effects for actors will only work if using an actor battler
sprite script like Yami's Battle Engine Symphony). Collapse effect customisation
is done through notetagging and you can find the notetags below.
===============================================================================
How to Use
-------------------------------------------------------------------------------
Place this script under Materials. It's also best to put this script under
any other scripts that overwrite the perform_collapse_effect methods in either
the Game_Actor or Game_Enemy classes.
===============================================================================
Note Tags
-------------------------------------------------------------------------------
Place any of these note tags within an actor or enemy in the database.
--------------------Actor/Enemy Notetags--------------------
<custom collapse: n>
Sets up the duration of the custom collapse, where n is the number of frames
you want the custom collapse to last (60 frames per second).
<collapse shake x: n>
Shakes the battler horizontally, where n is at what frame the shake will start.
The effect will last until the end of the duration of the collapse effect.
<collapse shake y: n>
Shakes the battler vertically, where n is at what frame the shake will start.
The effect will last until the end of the duration of the collapse effect.
<collapse fade: n>
The battler starts fading to nothing, where n is at what frame the fading will
start. The effect will last until the end of the duration of the collapse effect.
<collapse fade color: n1 n2 n3>
Sets the fade color for the battler when using the collapse fade effect. This
uses the RGB system, with the numbers ranging between 0-255. Red is n1, Green
is n2 and Blue is n3.
<collapse sink: n1 n2>
The battler begins moving downwards, where n1 is at what frame the battler
will start sinking, and n2 is the speed that the battler will sink (you can
even use decimal values for n2). You do not have to use n2. At default, the
effect will last until the end of the duration of the collapse effect while
not using n2.
<collapse wave: n>
The battler's image begins to distort in a wavey like pattern, where n is at
what frame the wave effect will begin. The effect will last until the end of
the duration of the collapse effect.
<collapse sound: "string" n1 n2 n3>
A sound effect will start constantly playing, where "string" is the name of the
file in the Audio/SE folder, and n1 is at what frame the sound effects will start
playing. Variables n2 and n3 change the volume and pitch respectively. Variables
n2 and n3 do not need to be used. When they are not used, the value 100 is used
at default. The effect will last until the end of the duration of the collapse
effect.
<fade sound>
Makes the sound set from the collapse sound effect fade out relative to the
duration of the collapse effect. This will not effect sound effects played
from animations used with the collapse animation notetag.
<collapse animation: n>
A battle animation will play at the beginning of the battler's collapse, where
n is the id of the battle animation you want to use. The battle animation
will run along the rest of the custom collapse effects you have set up for
the battler.
<no wait for collapse animation>
By default the battle system will wait for a battle animation to finish before
proceeding with the battle, even if the custom collapse itself ended long
before. Using this notetag will allow the battle to continue when a battle
animation from a battler's custom collapse effect is still going on.
===============================================================================
Example
-------------------------------------------------------------------------------
To help give you a better understanding of how to manipulate these effects
to achieve various results, below is an example of a custom collapse effect.
<custom collapse: 230>
The collapse will last for 230 frames.
<collapse shake x: 80>
The battler will begin to shake once 80 frames have gone past.
<collapse sound: "Collapse4" 80>
The Collapse4 sound effect will start playing continuously once 80 frames
have gone past.
<collapse fade: 110>
<collapse fade color: 255 0 0>
The battler will begin to fade in a red color once 110 frames have gone past.
<collapse sink: 110>
<collapse wave: 110>
The battler will begin to sink with a wavey distortion once 110 frames have
gone past.
<collapse animation: 111>
Animation no.111 (which I like to call the Thunder Death animation) will
start playing.
This is what I have set up for the Thunder Death animation:
#007 Thunder10 Screen (255,255,255,200), @5
#020 Thunder10 Screen (255,255,255,200), @5
The Thunder10 sound effect will be played at frames 7 and 20 (word of warning,
battle animation frames are 15 frames per second and not 60 so the timing will
be different), along with the screen flashing white, with the flash lasting for
5 frames.
I highly recommend using battle animations for your custom collapse animations
as it allows for a far larger variety of effects that would otherwise not be
achievable without them.
===============================================================================
Required
-------------------------------------------------------------------------------
Nothing.
===============================================================================
Compatibility Issues
-------------------------------------------------------------------------------
Below are a list of scripts that this script is currently incompatible with.
A future update may fix these issues but I can't guarantee anything.
Yanfly Visual Battlers
----------------------
They've been set up differently to how enemy sprites are loaded up and they
haven't been set up to load collapse effects when an actor dies. This script
will still work with enemies while using Visual Battlers, but it won't work
with actors.
===============================================================================
Change log
-------------------------------------------------------------------------------
v1.6: Added the option to fade out sounds using a new notetag. (01/8/2015)
v1.5: Fixed a bug that didn't rest various graphical effects when an actor
or enemy with a custom collapse animation is revived. (25/5/2015)
v1.4: Updated the sound notetag to allow control of the sound's volume and
pitch. (12/10/2013)
v1.3: Fixed the sinking function so the effect will now last for the duration
of the collapse effect. You can now also set a speed for the battler to sink.(27/8/2013)
v1.2: Fixed a bug where the battle would continue before finishing a collapse
animation containing a battle animation that extended to longer than the
collapse animation's duration. Also allowing users to skip this bug fix with
a notetag. (25/10/2013)
v1.1: Fixed a bug where using a battle animation as a custom collapse effect
would delay the battle log until the battle animation finished. Unfortunately
the battle animations can no longer be used in conjunction with the default
collapse animations. (23/10/2013)
v1.0: First release. (23/10/2013)
===============================================================================
Terms of Use
-------------------------------------------------------------------------------
* Free to use for both commercial and non-commerical projects.
* Credit me if used.
* Do not claim this as your own.
* You're free to post this on other websites, but please credit me and keep
the header intact.
* If you want to release any modifications/add-ons for this script, the
add-on script must use the same Terms of Use as this script uses. (But you
can also require any users of your add-on script to credit you in their game
if they use your add-on script.)
* If you're making any compatibility patches or scripts to help this script
work with other scripts, the Terms of Use for the compatibility patch does
not matter so long as the compatibility patch still requires this script to run.
* If you want to use your own seperate Terms of Use for your version or
add-ons of this script, you must contact me at
[URL="http://www.rpgmakervxace.netor"]
http://www.rpgmakervxace.netor[/URL] www.crimson-castle.co.uk
===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Shadowmaster_Custom_Collapses"] = true
#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
# This module manages the database and game objects. Almost all of the
# global variables used by the game are initialized by this module.
#==============================================================================
module DataManager
#--------------------------------------------------------------------------
# * Load Database
#--------------------------------------------------------------------------
    class <<self;
        alias load_database_custom_collapse load_database;
    end
    def self.load_database
        load_database_custom_collapse
        load_notetags_custom_collapse
    end
#--------------------------------------------------------------------------
# * Load Notetags for Custom Collapse
#--------------------------------------------------------------------------
    def self.load_notetags_custom_collapse
        groups = [$data_actors, $data_enemies]
            for group in groups
                for obj in group
                    next if obj.nil?
                    obj.load_notetags_custom_collapse
                end
            end
        end
    end
class RPG::BaseItem
#--------------------------------------------------------------------------
# Public Instance Variables
#--------------------------------------------------------------------------
    attr_accessor :custom_collapse
    attr_accessor :collapse_duration
    attr_accessor :collapse_shake
    attr_accessor :shake_x_start
    attr_accessor :shake_y_start
    attr_accessor :collapse_fade
    attr_accessor :fade_start
    attr_accessor :fade_colors
    attr_accessor :fade_red
    attr_accessor :fade_green
    attr_accessor :fade_blue
    attr_accessor :wave_start
    attr_accessor :sink_start
    attr_accessor :sink_speed
    attr_accessor :collapse_sound
    attr_accessor :sound_start
    attr_accessor :sound_volume
    attr_accessor :sound_pitch
    attr_accessor :sound_fade
    attr_accessor :collapse_animation
    attr_accessor :no_wait_for_animation
#--------------------------------------------------------------------------
# Defining Attributes
#--------------------------------------------------------------------------
    def load_notetags_custom_collapse
        @custom_collapse = false
        @collapse_duration = 0
        @shake_x_start = nil
        @shake_y_start = nil
        @fade_start = nil
        @fade_colors = false
        @wave_start = nil
        @sink_start = nil
        @sink_speed = nil
        @collapse_sound = nil
        @sound_start = nil
        @sound_volume = 100
        @sound_pitch = 100
        @sound_fade = false
        @collapse_animation = nil
        @no_wait_for_animation = nil
        if @note =~ /<custom collapse: (.*)>/i
            @custom_collapse = true
            @collapse_duration = $1.to_i
        end
        if @note =~ /<collapse shake x: (.*)>/i
            @shake_x_start = $1.to_i
        end
        if @note =~ /<collapse shake y: (.*)>/i
            @shake_y_start = $1.to_i
        end
        if @note =~ /<collapse fade: (.*)>/i
            @fade_start = $1.to_i
        end
        if @note =~ /<collapse fade color: (.*) (.*) (.*)>/i
            @fade_colors = true
            @fade_red = $1.to_i
            @fade_green = $2.to_i
            @fade_blue = $3.to_i
        end
        if @note =~ /<collapse wave: (.*)>/i
            @wave_start = $1.to_i
        end
        if @note =~ /<collapse sink: (.*) (.*)>/i
            @sink_start = $1.to_i
            @sink_speed = $2.to_f
        end
        if @note =~ /<collapse sound: "(.+?)\" (.*)>/i
            @collapse_sound = $1.to_s
            @sound_start = $2.to_i
        end
        if @note =~ /<collapse sound: "(.+?)\" (.*) (.*)>/i
            @collapse_sound = $1.to_s
            @sound_start = $2.to_i
            @sound_volume = $3.to_i
        end
        if @note =~ /<collapse sound: "(.+?)\" (.*) (.*) (.*)>/i
            @collapse_sound = $1.to_s
            @sound_start = $2.to_i
            @sound_volume = $3.to_i
            @sound_pitch = $4.to_i
        end
        if @note =~ /<fade sound>/i
            @sound_fade = true
        end
        if @note =~ /<collapse animation: (.*)>/i
            @collapse_animation = $1.to_i
        end
        if @note =~ /<no wait for collapse animation>/i
            @no_wait_for_animation = true
        end
    end
end
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
# This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================
class Game_Actor < Game_Battler
#--------------------------------------------------------------------------
# * Public Instance Variables
#--------------------------------------------------------------------------
    attr_reader :collapse_duration
    attr_reader :shake_x_start
    attr_reader :shake_y_start
    attr_reader :fade_start
    attr_reader :fade_colors
    attr_reader :fade_red
    attr_reader :fade_green
    attr_reader :fade_blue
    attr_reader :wave_start
    attr_reader :sink_start
    attr_reader :sink_speed
    attr_reader :collapse_sound
    attr_reader :sound_start
    attr_reader :kovolume
    attr_reader :kopitch
    attr_reader :sound_fade
    attr_reader :collapse_animation
    attr_reader :no_wait_for_animation
#--------------------------------------------------------------------------
# * Object Initialization
#--------------------------------------------------------------------------
    alias shadowmaster_setup_collapse setup
    def setup(actor_id)
        shadowmaster_setup_collapse(actor_id)
        @collapse_duration = actor.collapse_duration
        @shake_x_start = actor.shake_x_start
        @shake_y_start = actor.shake_y_start
        @fade_start = actor.fade_start
        @fade_colors = actor.fade_colors
        @fade_red = actor.fade_red
        @fade_green = actor.fade_green
        @fade_blue = actor.fade_blue
        @wave_start = actor.wave_start
        @sink_start = actor.sink_start
        @sink_speed = actor.sink_speed
        @collapse_sound = actor.collapse_sound
        @sound_start = actor.sound_start
        @kovolume = actor.sound_volume
        @kopitch = actor.sound_pitch
        @sound_fade = actor.sound_fade
        @collapse_animation = actor.collapse_animation
        @no_wait_for_animation = actor.no_wait_for_animation
    end
#--------------------------------------------------------------------------
# * Execute Collapse Effect
#--------------------------------------------------------------------------
    alias shadowmaster_perform_collapse_effect perform_collapse_effect
    def perform_collapse_effect
        if actor.custom_collapse == true
            @sprite_effect_type = :shadowmaster_custom_collapse
        else
            shadowmaster_perform_collapse_effect
        end
    end
end
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
# This class handles enemies. It used within the Game_Troop class
# ($game_troop).
#==============================================================================
class Game_Enemy < Game_Battler
#--------------------------------------------------------------------------
# * Public Instance Variables
#--------------------------------------------------------------------------
    attr_reader :collapse_duration
    attr_reader :shake_x_start
    attr_reader :shake_y_start
    attr_reader :fade_start
    attr_reader :fade_colors
    attr_reader :fade_red
    attr_reader :fade_green
    attr_reader :fade_blue
    attr_reader :wave_start
    attr_reader :sink_start
    attr_reader :sink_speed
    attr_reader :collapse_sound
    attr_reader :sound_start
    attr_reader :kovolume
    attr_reader :kopitch
    attr_reader :sound_fade
    attr_reader :collapse_animation
    attr_reader :no_wait_for_animation
#--------------------------------------------------------------------------
# * Object Initialization
#--------------------------------------------------------------------------
    alias shadowmaster_initialize_collapse initialize
    def initialize(index, enemy_id)
        shadowmaster_initialize_collapse(index, enemy_id)
        @collapse_duration = enemy.collapse_duration
        @shake_x_start = enemy.shake_x_start
        @shake_y_start = enemy.shake_y_start
        @fade_start = enemy.fade_start
        @fade_colors = enemy.fade_colors
        @fade_red = enemy.fade_red
        @fade_green = enemy.fade_green
        @fade_blue = enemy.fade_blue
        @wave_start = enemy.wave_start
        @sink_start = enemy.sink_start
        @sink_speed = enemy.sink_speed
        @collapse_sound = enemy.collapse_sound
        @sound_start = enemy.sound_start
        @kovolume = enemy.sound_volume
        @kopitch = enemy.sound_pitch
        @sound_fade = enemy.sound_fade
        @collapse_animation = enemy.collapse_animation
        @no_wait_for_animation = enemy.no_wait_for_animation
    end
#--------------------------------------------------------------------------
# * Execute Collapse Effect
#--------------------------------------------------------------------------
    alias shadowmaster_perform_collapse_effect perform_collapse_effect
    def perform_collapse_effect
        if enemy.custom_collapse == true
            @sprite_effect_type = :shadowmaster_custom_collapse
        else
            shadowmaster_perform_collapse_effect
        end
    end
end
#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
# This sprite is used to display battlers. It observes an instance of the
# Game_Battler class and automatically changes sprite states.
#==============================================================================
class Sprite_Battler < Sprite_Base
#--------------------------------------------------------------------------
# * Start Effect
#--------------------------------------------------------------------------
    alias shadowmaster_start_effect start_effect
    def start_effect(effect_type)
        shadowmaster_start_effect(effect_type)
        case @effect_type
        when :shadowmaster_custom_collapse
            @effect_duration = @battler.collapse_duration
            @orig_eff_duration = @effect_duration
            @shake_x_start = @effect_duration - @battler.shake_x_start if @battler.shake_x_start != nil
            @shake_y_start = @effect_duration - @battler.shake_y_start if @battler.shake_y_start != nil
            @fade_start = @effect_duration - @battler.fade_start if @battler.fade_start != nil
            @wave_start = @effect_duration - @battler.wave_start if @battler.wave_start != nil
            @sink_start = @effect_duration - @battler.sink_start if @battler.sink_start != nil
            @sink_speed = @battler.sink_speed if @battler.sink_speed != nil
            @sound = @battler.collapse_sound if @battler.collapse_sound != nil
            @sound_start = @effect_duration - @battler.sound_start if @battler.sound_start != nil
            @volume = @battler.kovolume
            @pitch = @battler.kopitch
            self.wave_amp = 0
            @full_sink = 0
            @round_sink = 1
            @battler_visible = false
            if @battler.collapse_animation != nil
                animation = $data_animations[@battler.collapse_animation]
                start_animation(animation)
                SceneManager.scene.wait_for_animation if @battler.no_wait_for_animation == nil
            end
        end
    end
#--------------------------------------------------------------------------
# * Revert to Normal Settings
#--------------------------------------------------------------------------
    alias shadowmaster_revert_to_normal revert_to_normal
    def revert_to_normal
        shadowmaster_revert_to_normal
        self.oy = bitmap.height if bitmap
        self.wave_amp = 0
    end
    #--------------------------------------------------------------------------
# * Update Effect
#--------------------------------------------------------------------------
    alias shadowmaster_update_effect update_effect
    def update_effect
        if @effect_type == :shadowmaster_custom_collapse && @effect_duration > 0
            shadowmaster_update_custom_collapse
        end
        shadowmaster_update_effect
    end
#--------------------------------------------------------------------------
# * Update Custom Collapse Effect
#--------------------------------------------------------------------------
    def shadowmaster_update_custom_collapse
        if @fade_start != nil && @fade_start >= @effect_duration
            alpha = @effect_duration.to_f / @fade_start.to_f
            if @battler.fade_colors == true
                @fade_red = @battler.fade_red
                @fade_green = @battler.fade_green
                @fade_blue = @battler.fade_blue
                self.color.set(@fade_red, @fade_green, @fade_blue, 255 * alpha)
            else
                self.color.set(255, 255, 255, 255 * alpha)
            end
            self.opacity = 128 * alpha
            self.blend_type = 1
        end
        if @shake_x_start != nil && @shake_x_start >= @effect_duration
            self.ox += ((rand(2) + 1) * 5) - ((rand(2) + 1) * 5)
        end
        if @shake_y_start != nil && @shake_y_start >= @effect_duration
            self.oy += ((rand(2) + 1) * 5) - ((rand(2) + 1) * 5)
        end
        if @sink_start != nil && @sink_start >= @effect_duration
            @full_sink += @sink_speed if @sink_speed != nil
            @full_sink += (bitmap.height.to_f / @sink_start.to_f) if @sink_speed == nil
            while @full_sink >= @round_sink
                self.src_rect.y -= 1
                @round_sink += 1
            end
        end
        if @wave_start != nil && @wave_start >= @effect_duration && self.wave_amp == 0
            self.wave_amp = 8
        elsif @wave_start != nil && @wave_start >= @effect_duration && self.wave_amp > 0
            self.wave_amp += 2 if @effect_duration % 20 == 0
        else
            self.wave_amp = 0
        end
        if @sound != nil && @sound_start != nil && @sound_start >= @effect_duration
            if @battler.sound_fade
                @volume_mult = @effect_duration.to_f / @sound_start.to_f
            else
                @volume_mult = 1
            end
            sound = RPG::SE.new(@sound, @volume * @volume_mult, @pitch)
            sound.play if @effect_duration % 20 == 19
        end
    end
end