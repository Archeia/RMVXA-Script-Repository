#Vlue~
#Music_Player.play(:jbells)
module Music_Player
  SOUNDS = {
    :basic => 'Audio/SE/Switch1'
  }
  NOTES = {
    :d => [SOUNDS[:basic],80],
    :e => [SOUNDS[:basic],85],
    :f => [SOUNDS[:basic],90],
    :g => [SOUNDS[:basic],95],
    :A => [SOUNDS[:basic],100],
    :B => [SOUNDS[:basic],105],
    :C => [SOUNDS[:basic],110],
    :D => [SOUNDS[:basic],115],
    :E => [SOUNDS[:basic],120],
  }
  SONGS = {
    :jbells => {
      :notes => [:A,:A,:A,0,:A,:A,:A,0,:A,:C,:d,:f,:g,
                0,0,:B,:B,:B,:B,:B,:f,:f,[:f,10],[:f,10],:f,:d,:d,
                :f,[:d,20],:E],
      :tempo => 15,
    }
  }
  def self.play(sym)
    return unless SONGS[sym]
    @current_song = SONGS[sym]
    @current_note = 0
    @current_time = 0
  end
  def self.update
    return unless @current_song
    if @current_time <= 0
      note = @current_song[:notes][@current_note]
      @current_time = @current_song[:tempo]
      if note != 0
        if note.is_a?(Array)
          se = NOTES[note[0]]
          @current_time = note[1]
        else
          se = NOTES[note]
        end
        Audio.se_play(se[0],100,se[1])
      end
      @current_note += 1
    end
    @current_time -= 1
    stop if @current_note == @current_song[:notes].size
  end
  def self.stop
    @current_song = nil
    @current_note = nil
    @current_time = nil
  end
end
    
class Scene_Base
  alias music_player_update update
  def update
    music_player_update
    Music_Player.update
  end
end