=begin
#--------------------------------------------------------------------------
  Angle-view Setup for Tankentai SBS 3.4 and above 
  v0.1
  by Mr. Bubble
#--------------------------------------------------------------------------
  Installation: Place below the Sideview scripts.
#--------------------------------------------------------------------------
    Not plug and play. Read the comments thoroughly.

    This snippet changes several default anime keys to support angle-view
  battles. The changes are *minimal* and certain action sequences may
  look strange. Kaduki format sprites are recommended, but can work with
  default RTP battlers *only* if you have 8-dir sprites.
  
    This setup requires that you have 8-directional sprites in the
  Graphics/Characters folder of your project. Each 8-dir sprite graphics
  requires "_5" postfixed at the end of the file name. If you are familiar
  with the Kaduki format then this will seem familar.
  
    For example, if you have an actor that has a graphic with the file name
  "$Ralph.png" then the 8-dir graphic's file name should be "$Ralph_5.png".
  
    You will still need to change the coordinates within the ACTOR_POSITION
  array in the SBS General Settings script. Some recommended coordinates
  are: [[300,250],[340,235],[380,220],[420,205],[460,190],[500,175]]
  
    Angle-view animated enemies are not technically supported (yet).
#--------------------------------------------------------------------------
=end

module N01
  ANGLE_VIEW_KEYS_1 = {
 #--------------------------------------------------------------------------
 # ++ Battler Poses
 #--------------------------------------------------------------------------
  # ANIME Key         FileNo. Row Spd Loop Wait Fixed   Z Shadow  Weapon
  "MOVE_POSE"       => [ 5,  1,   1,   1,   0,  -1,   0, true,      "" ],
  "MOVE_AWAY_POSE"  => [ 5,  2,   2,   1,   0,  -1,   0, true,      "" ],
  "STANDBY_POSE"    => [ 5,  1,  15,   0,   0,  -1,   0, true,      "" ],
 #--------------------------------------------------------------------------
 # ++ Battler Movement
 #--------------------------------------------------------------------------
  # ANIME Key                  Origin  X   Y  Time Accel Jump  Pose
  "BATTLE_ENTRANCE"         => [  0,  32,  32,  1,   0,   0,  "MOVE_POSE"],
  "STEP_FORWARD"            => [  3, -16, -16, 10,  -1,   0,  "MOVE_POSE"],
  "STEP_BACKWARD"           => [  0,  16,  16, 10,  -1,   0,  "MOVE_AWAY_POSE"],
  
 #--------------------------------------------------------------------------
 # ++ Battler Position Reset
 #-------------------------------------------------------------------------- 
  # ANIME Key         Type   Time Accel Jump   Pose Key
  "RESET"         => ["reset", 16,  0,   0,  "MOVE_AWAY_POSE"],
  "FLEE_RESET"    => ["reset", 16,  0,   0,  "MOVE_AWAY_POSE"],
  "START_RESET"  => ["reset", 16,  0,   0,  "MOVE_POSE"],
  } # <-- Do not delete.
  ANIME.merge!(ANGLE_VIEW_KEYS_1)
  
 #--------------------------------------------------------------------------
 # ++ Action Sequences
 #-------------------------------------------------------------------------- 
  ANGLE_VIEW_ACTIONS_1 = {
  
  "BATTLE_START"          => ["BATTLE_ENTRANCE","START_RESET"],
  }
  ACTION.merge!(ANGLE_VIEW_ACTIONS_1)
end