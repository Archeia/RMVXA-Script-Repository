$simport.r 'iek/taggable', '1.0.0', 'Interface for custom taggable objects'

module Taggable
  attr_writer :tags

  def tags
    @tags ||= []
  end

  def tag(name)
    tags << name
  end
end
