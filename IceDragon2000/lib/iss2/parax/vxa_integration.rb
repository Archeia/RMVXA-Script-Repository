$simport.r('iss2/parax/vxa_integration', '1.0.0', 'Parax VXA Integration') do |d|
  d.depend!('iss2/parax/spriteset_mix', '~> 1.0')
end

class Spriteset_Map
  include ISS2::Parax::SpritesetMix

  alias :iss2_parax_spm_create_all :create_all
  def create_all(*args, &block)
    iss2_parax_spm_create_all(*args, &block)
    create_parax
  end

  alias :iss2_parax_spm_dispose :dispose
  def dispose(*args, &block)
    iss2_parax_spm_dispose(*args, &block)
    dispose_parax
  end

  alias :iss2_parax_spm_update :update
  def update(*args, &block)
    iss2_parax_spm_update(*args, &block)
    update_parax
  end
end
