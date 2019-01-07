#===============================================================================
# * [ACE] Custom Enemy Placement
#===============================================================================
# * Made by: Sixth (www.rpgmakervxace.net, www.forums.rpgmakerweb.com)
# * Version: 1.0
# * Updated: 25/01/2015
# * Requires: -------
#-------------------------------------------------------------------------------
# * < Change Log >
#-------------------------------------------------------------------------------
# * Version 1.0 (25/01/2015)
#   - Initial release.
#-------------------------------------------------------------------------------
# * < Description >
#-------------------------------------------------------------------------------
# * This script adds new ways to setup the position of your enemies in battle.
#   - You can set the X and Y position of the enemy directly.
#   - You can make offset values to the default position of the enemy.
#   - Includes Yanly's and Tsukihime's methods of calculating the enemy's position.
#   - And for completion's sake, includes the default placement type.
# * Works in battle test mode, so you can quickly edit the positions of the
#   enemies!
#------------------------------------------------------------------------------- 
# * < Installation >
#-------------------------------------------------------------------------------
# * Place this script below Materials but above Main!
# * If you are using Yanfly's Core Engine script, place this script below it!
# *	If you are using Dekita's Core script, place this script below it!
# * If you are using Tsukihime's Battle Sprites Auto-Position script, don't
#   use it, it is not necessary with this script! Or don't use this one...
#-------------------------------------------------------------------------------
# * < Compatibility Info >
#-------------------------------------------------------------------------------
# * Won't work with ABS systems... No kidding, ehh? :P
#-------------------------------------------------------------------------------
# * < Known Issues >
#-------------------------------------------------------------------------------
# * No known issues.
#-------------------------------------------------------------------------------
# * < Terms of Use >
#-------------------------------------------------------------------------------
# * Free to use for whatever purposes you want.
# * You can credit me (Sixth) in your game, thought this was too easy to ask
#	credit for, so it is your choice... :P
# * Posting modified versions of this script is allowed as long as you notice me
#   about it with a link to it!
#===============================================================================
$imported = {} if $imported.nil?
$imported["SixthEnemyPlacement"] = true
module Sixth_Enemy_Placement
#===============================================================================
# Settings:
#===============================================================================
  # Setup the type of the placement used for enemies. 
  # Several options are available:
  #  :direct = If you choose this, the co-ordinates entered in the below settings
  #            will be the direct positions for the enemies in battle.
  #  :offset = If you choose this, the co-ordinates entered in the below settings
  #            will be offset values for the positions of the enemies in battle.
  #            Meaning the values will be added to the default enemy positions.
  #  :yanfly = This type will use Yanfly's method to calculate the enemy position.
  #            Yanfly's Core Engine has this method.
  #  :tsuki  = This type will use Tsukihime's method to calculate the enemy 
  #            position. I guess this method is used in his troop reposition 
  #            script. I never used it, so I can't know. :P
  # :default = RPG Maker VX Ace's default position type.
  Placement_Type = :direct
  
  # The new position settings.
  # You can setup the positions of the enemies in battle here.
  # All troop must have a setting here and all enemies in the troop must have a
  # value set up for their position too!
  # These settings work only if you have set the above setting to 
  # :direct or :offset!
  # The sample settings are the default positions of the enemies for the 30 
  # default troops setup in the database.
  #
  # Format:
  #
  #   troop_id => { enemy_index => [x,y], enemy_index => [x,y], ... },
  #
  # troop_id    = The ID of the troop, obviously. Starts from 1.
  # enemy_index = The index of the enemies in the troop.
  #               The index starts from 0. The first enemy placed in the troop
  #               got the ID of 0, the second one got the ID of 1, the third one
  #               got the ID of 2, and so on...
  #       [x,y] = The X and Y position for the enemy measured in pixels.
  #               If you set the above setting to :direct, than this will be the
  #               direct position for the enemies.
  #               If you set the above setting to :offset, than this will be an
  #               offset value and will be added to the enemy's default X and Y
  #               position. 
  #               The X position defines the position of the horizontal center 
  #               of the battler's image, and the Y position defines the bottom 
  #               position of the battler's image on the screen!
  Setup_Pos = { # <-- No touchy-touchy!
    1 => { 0 => [196,288], 1 => [348,288] },
    2 => { 0 => [207,288], 1 => [337,288] },
    3 => { 0 => [227,288], 1 => [317,288] },
    4 => { 0 => [112,288], 1 => [272,288], 2 => [432,288] },
    5 => { 0 => [154,288], 1 => [272,288], 2 => [390,288] },
    6 => { 0 => [110,288], 1 => [272,288], 2 => [434,288] },
    7 => { 0 => [170,288], 1 => [374,288] },
    8 => { 0 => [105,288], 1 => [272,288], 2 => [439,288] },
    9 => { 0 => [183,288], 1 => [361,288] },
   10 => { 0 => [101,288], 1 => [272,288], 2 => [443,288] },
   11 => { 0 => [146,288], 1 => [272,288], 2 => [398,288] },
   12 => { 0 => [181,288], 1 => [363,288] },
   13 => { 0 => [136,288], 1 => [272,288], 2 => [408,288] },
   14 => { 0 => [201,288], 1 => [343,288] },
   15 => { 0 => [112,288], 1 => [272,288], 2 => [432,288] },
   16 => { 0 => [233,288], 1 => [321,288] },
   17 => { 0 => [160,288], 1 => [272,288], 2 => [384,288] },
   18 => { 0 => [171,288], 1 => [373,288] },
   19 => { 0 => [272,288] },
   20 => { 0 => [272,288] },
   21 => { 0 => [183,288], 1 => [361,288] },
   22 => { 0 => [149,288], 1 => [395,288] },
   23 => { 0 => [272,288] },
   24 => { 0 => [156,288], 1 => [388,288] },
   25 => { 0 => [272,288] },
   26 => { 0 => [272,288] },
   27 => { 0 => [272,288] },
   28 => { 0 => [272,288] },
   29 => { 0 => [272,288] },
   30 => { 0 => [272,288] },
    # Add as many as you want!
  } # <-- No touchy-touchy!
  
end # <-- No touchy-touchy!
#===============================================================================
# End of Settings! Editing anything below may lead to... You know what, right?
#===============================================================================

class Game_Troop < Game_Unit

  def setup(troop_id)
    clear
    @troop_id = troop_id
    @pos = Sixth_Enemy_Placement::Setup_Pos[@troop_id]
    @enemies = []
    troop.members.each_with_index do |member,i|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      if Sixth_Enemy_Placement::Placement_Type == :direct
        enemy.screen_x = @pos[i][0]
        enemy.screen_y = @pos[i][1]
      elsif Sixth_Enemy_Placement::Placement_Type == :offset
        enemy.screen_x = member.x + @pos[i][0] 
        enemy.screen_y = member.y + @pos[i][1] 
      elsif Sixth_Enemy_Placement::Placement_Type == :yanfly
        enemy.screen_x = member.x + (Graphics.width - 544)/2
        enemy.screen_y = member.y + (Graphics.height - 416)
      elsif Sixth_Enemy_Placement::Placement_Type == :tsuki
        enemy.screen_x = member.x * Graphics.width / 544.0
        enemy.screen_y = member.y * Graphics.height / 416.0
      else
        enemy.screen_x = member.x
        enemy.screen_y = member.y
      end
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end

end
#==============================================================================
# !!END OF SCRIPT - OHH, NOES!!
#==============================================================================