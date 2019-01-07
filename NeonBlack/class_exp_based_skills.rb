class Game_Actor < Game_Battler
  ActorSwitchHash ={
    1 => 100,
    2 => 101,
  }
  LearnVocab = "<name> learned <skill>!"
  
  alias_method "cp_maus_02172014_change_exp", "change_exp"
  def change_exp(*args)
    exp_dif = [args[0], 0].max - @exp[@class_id]
    return cp_maus_02172014_change_exp(*args) unless exp_dif > 0
    last_level = @level
    last_skills = skills
    class_exp_v(exp_dif) if check_actor_switch_hash
    cp_maus_02172014_change_exp(*args)
    return unless @level == last_level
    set_class_based_skills
    display_skills_up(skills - last_skills) if args[1]
  end
  
  def display_skills_up(new_skills)
    return if new_skills.nil? || new_skills.empty?
    $game_message.new_page
    new_skills.each do |skill|
      text = LearnVocab.clone
      text.gsub!('<name>', name)
      text.gsub!('<skill>', skill.name)
      $game_message.add(text)
    end
  end
  
  def class_exp_v(add = 0)
    @class_exp_hash ||= {}
    @class_exp_hash[self.class.id] ||= 0
    @class_exp_hash[self.class.id] += add
    return @class_exp_hash[self.class.id]
  end
  
  def check_actor_switch_hash
    return true unless ActorSwitchHash.include?(id)
    return $game_switches[ActorSwitchHash[id]]
  end
  
  def set_class_based_skills
    self.class.learnings.each do |learning|
      result = learning.level <= @level
      if learning.note =~ /learn exp\[(\d+)\]/i
        result = result && $1.to_i <= class_exp_v
      end
      if learning.note =~ /forget exp\[(\d+)\]/i
        result = result && $1.to_i > class_exp_v
      end
      result ? learn_skill(learning.skill_id) : forget_skill(learning.skill_id)
    end
  end
  
  def init_skills
    @skills = []
    set_class_based_skills
  end
  
  def level_up
    @level += 1
    set_class_based_skills
  end
end