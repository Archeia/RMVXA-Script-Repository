=begin
================================================================================
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
OZ Particle Emitter - Versión 0.5a
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Testeado en RGSS1
Autor: Orochii Zouveleki

Documentación:
''''''''''''''
module OZMath
  Este módulo incluye algunas operaciones comunes.

  def self.deg2rad(degrees) 	- Convierte grados a radianes.
								Retorno: Numeric.
  def self.lerp(v,a,b) 			- Interpolación lineal entre números a y b 
								de acuerdo a v (0..1).
								Retorno: Numeric.
  def self.clamp(v,min,max) 	- Restringe un valor v a un intérvalo [min,max]
								Retorno: Numeric.
  def self.rand_range(a,b) 		- Número aleatorio entre a y b.
								Retorno: Numeric.
  def self.rand_range_i(a,b)	- Número aleatorio entero entre a y b.
								Retorno: Numeric.
  def self.lerp_col(v, c1, c2)	- Interpolación lineal entre Color c1 y c2 
								de acuerdo a v.
  								Retorno: Color.

class FreeRange
	Esta clase es una versión inútil de Range, con el objeto de soportar 
	valores de punto flotante.
	Simplemente necesitaba algo que lo guardara, y no fuera Array. ¯\_(ツ)_/¯

  def initialize(first,last)	-Inicializa objeto
  attr_reader :first			-Valor inicial
  attr_reader :last				-Valor final

class Particle < Sprite
  attr_reader :dead				
  def initialize(bitmap,emissor,x,y,viewport=nil)
								-Inicialización partícula
  def update					-Lógica de partícula
  def get_property(p,modifier=nil,k=:number)
								-Obtiene valor real de propiedad
  								Retorno: Numeric, Array de Numeric o Color
  def get_max(p, k=:number)		-
  								Retorno: Numeric o Array de Numeric
  def get_modifier(mod)
    							Retorno: Numeric 0..1
  # Métodos de utilidad internos
  def iter_modifiers(m, lm, sm)	
  def get_property_color(p,modifier)
  def get_property_array(p,modifier)
  def get_property_number(p,modifier)
  def get_max_array(p)
  def get_max_number(p)

class ParticleEmissorProperties
  
  # Global attributes
  attr_accessor :viewport			-Viewport usado por todos los sprites
  attr_accessor :simulation_space	-:local para mover partícula con emisor
  attr_accessor :max_particles		-Numeric, límite de sprites
  attr_accessor :duration			-frames antes de reinicio de emisión
  attr_accessor :looping			-si se repite el efecto
  attr_accessor :autoplay			-emitir al iniciar
  attr_accessor :bitmaps			-imágenes usadas por partículas (al azar)
  
  # Emission attributes
  attr_accessor :pps 				-Partículas por segundo
  attr_accessor :bursts 			-Array de ráfagas. Usa un tiempo t de 
									acuerdo al temporizador interno del emisor
									y un número n de partículas a emitir en 
									el momento. bmp es usado para determinar
									un bitmap personalizado (nil para usar
									los otros al azar).
									[[t1,n1,bmp],[t2,n2,bmp], (...)]
  attr_accessor :shape 				-Forma del emisor. :circle o :square
  attr_accessor :shape_a			-Radio mínimo para :circle. Ancho para :square
  attr_accessor :shape_b			-Radio máximo para :circle. Alto para :square
  attr_accessor :shape_angle 		-En círculos, delimita el arco de efecto.
									[anguloInicio,anguloFin,angleStep]
  
  # Particle attributes
		Los atributos de partícula suelen poseer un atributo modificador que modifica su
		comportamiento de acuerdo a otro valor. 
			Ej. Si speed_modifier==:lifetime, la velocidad cambiará a lo largo de 
			la vida de la partícula.
		Los atributos además pueden recibir valores en arrays o sueltos, así como rangos.
		Los rangos pueden ser clase Range o FreeRange (clase hecha como parte de este script).
			Ejs.
				color = Color.new(0,0,0,0)
				color = [Color.new(0,0,0,255),Color.new(32,128,196,160)]
				speed = [1,0]
				speed = [[-1,5,7],FreeRange.new(-3,3)]
		Algunos atributos requieren ser encapsulados en un array siempre de un tamaño específico, 
		pero sus miembros internos pueden encapsularse en otro array o ser Range/FreeRange.
		
  attr_accessor :lifetime			-Tiempo de vida de partículas (en frames)
  attr_accessor :speed				-Velocidad [X,Y].
  attr_accessor :speed_modifier 	# :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  attr_accessor :acceleration		-
  attr_accessor :acceleration_modifier # :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  attr_accessor :size				-
  attr_accessor :size_modifier 		# :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  attr_accessor :rotation			-
  attr_accessor :rotation_modifier 	# :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  attr_accessor :opacity			-
  attr_accessor :opacity_modifier 	# :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  attr_accessor :color				- 
  attr_accessor :color_modifier 	# :none AZAR :speed VELOCIDAD :lifetime VIDA RESTANTE
  def initialize(bitmaps=[])		-Inicializador, recibe bitmaps a usar.
  def get_random_bitmap				-Devuelve un bitmap al azar de bitmaps.
									Devuelve un bitmap blanco de 8x8 si no hay bitmaps.
  
class ParticleEmissor
  attr_accessor :properties
  attr_accessor :x
  attr_accessor :y
  def initialize(x, y, z, _properties=ParticleEmissorProperties.new)
  def update
  def create_new_particle(bmp)
  def get_shape_coordinate
  def dispose
================================================================================
=end

module OZMath
  def self.deg2rad(degrees)
    return degrees * Math::PI / 180
  end
  
  def self.lerp(v,a,b)
    return (b-a)*v + a
  end
  
  def self.clamp(v,min,max)
    return [ [ min, v ].max, max ].min
  end
  
  def self.rand_range(a,b)
    return rand * (b-a) + a
  end
  
  def self.rand_range_i(a,b)
    return rand(b-a)+a
  end
  
  def self.lerp_col(v, c1, c2)
    r = lerp(v, c1.red, c2.red)
    g = lerp(v, c1.green, c2.green)
    b = lerp(v, c1.blue, c2.blue)
    a = lerp(v, c1.alpha, c2.alpha)
    return Color.new(r,g,b,a)
  end
end

class FreeRange
  def initialize(first,last)
    @first = first
    @last = last
  end
  
  attr_reader :first
  attr_reader :last
end

class Particle < Sprite
  attr_reader :dead
  
  def initialize(bitmap, emissor, x, y, viewport=nil)
    super(viewport)
    self.bitmap = bitmap
    self.blend_type = 1
    @ref = emissor if emissor.properties.simulation_space==:local
    @x = x
    @y = y
    if @ref==nil
      @x += emissor.x
      @y += emissor.y
    end
    # Lifetime is constant
    @lifetime = get_property(emissor.properties.lifetime)
    @starting_lifetime = @lifetime
    @dead = false
    # Modifiers are also constant
    @speed_modifier = emissor.properties.speed_modifier
    @acceleration_modifier = emissor.properties.acceleration_modifier
    @size_modifier = emissor.properties.size_modifier
    @rotation_modifier = emissor.properties.rotation_modifier
    @opacity_modifier = emissor.properties.opacity_modifier
    @color_modifier = emissor.properties.color_modifier
    
    # Others are processed
    @speed = emissor.properties.speed
    @top_speed = get_max(emissor.properties.speed,:array)
    @acceleration = emissor.properties.acceleration
    @size = emissor.properties.size
    @rotation = emissor.properties.rotation
    @opacity_ = emissor.properties.opacity
    @color = emissor.properties.color
    # Initialize speed
    if @speed_modifier==:lifetime
      @current_speed = get_property(@speed,0,:array)
    else
      @current_speed = get_property(@speed,nil,:array)
    end
    # Update
    update
  end
  
  def iter_modifiers(m, lm, sm)
    return (m==:lifetime) ? lm : (m==:speed) ? sm : nil
  end
  
  def update
    super
    # Lifetime update
    return if @dead==true
    @lifetime -= 1
    
    # Buffer modifiers
    lm = get_modifier(:lifetime)
    sm = get_modifier(:speed)
    # Set modifier buffers to each
    speed_mod = iter_modifiers(@speed_modifier,lm,sm)
    accel_mod = iter_modifiers(@acceleration_modifier,lm,sm)
    size_mod = iter_modifiers(@size_modifier,lm,sm)
    rot_mod = iter_modifiers(@rotation_modifier,lm,sm)
    opacity_mod = iter_modifiers(@opacity_modifier,lm,sm)
    color_mod = iter_modifiers(@color_modifier, lm, sm)
    # Update speed
    accel = get_property(@acceleration,accel_mod,:array)
    @current_speed[0] += accel[0]
    @current_speed[1] += accel[1]
    # Update size
    self.zoom_x = get_property(@size[0],size_mod) if size_mod != nil
    self.zoom_y = get_property(@size[1],size_mod) if size_mod != nil
    # Update angle
    self.angle += get_property(@rotation,rot_mod)
    self.opacity = get_property(@opacity_,opacity_mod)
    # Update color
    self.color = get_property(@color, color_mod, :color)
    # Update position
    sm = speed_mod==nil ? 1 : speed_mod
    @x += @current_speed[0]*sm
    @y += @current_speed[1]*sm
    if @ref==nil
      self.x = @x
      self.y = @y
    else
      self.x = @x + @ref.x
      self.y = @y + @ref.y
    end
    
    if (@lifetime <= 0)
      @dead = true
      self.visible = false
    end
  end
  
  # Returns: Any number / array of number
  def get_property(p,modifier=nil,k=:number)
    return get_property_color(p, modifier) if k==:color
    return get_property_array(p, modifier) if k==:array
    return get_property_number(p,modifier)
  end
  # Returns: Any number / array of number
  def get_max(p, k=:number)
    return get_max_array(p) if k==:array
    return get_max_number(p)
  end
  # Returns: 0..1
  def get_modifier(mod)
    if mod==:lifetime
      return (@starting_lifetime-@lifetime)*1.0/@starting_lifetime
    end
    if mod==:speed
      s = @current_speed[0].abs + @current_speed[1].abs
      ts= @top_speed[0].abs + @top_speed[1].abs
      return (s*1.0/ts)
    end
    return 0
  end
  
  # "HELPERS" (or internal methods)
  def get_property_color(p,modifier)
    if p.is_a?(Array)
      m = modifier==nil ? rand() : modifier
      a = (p.size * m).floor
      a = p.size-1 if a>=p.size
      b = a+1
      b = a if b>=p.size
      c1 = p[a]
      c2 = p[b]
      l = (m * p.size) - a
      return OZMath.lerp_col(l, c1, c2)
    elsif p.is_a?(Color)
      return p
    end
    return Color.new(0,0,0)
  end
  def get_property_array(p,modifier)
    val = []
    for i in 0...p.size
      val[i] = get_property_number(p[i], modifier)
    end
    return val
  end
  def get_property_number(p,modifier)
    # If modifier set to none
    if (modifier == nil)
      if p.is_a?(Numeric)||p.is_a?(Color)
        return p
      elsif p.is_a?(Array)
        return 0 if p.size==0
        a = rand(p.size)
        return p[a]
      elsif p.is_a?(Range) || p.is_a?(FreeRange)
        return OZMath.rand_range(p.first, p.last)
      end
    end
    # Modifier must be 0..1
    if p.is_a?(Numeric)
      return p * modifier
    elsif p.is_a?(Array)
      return 0 if p.size==0
      a = (p.size * modifier).floor
      a = OZMath.clamp(a, 0, p.size-1)
      return p[a]
    elsif p.is_a?(Range) || p.is_a?(FreeRange)
      return OZMath.lerp(modifier, p.first, p.last)
    end
  end
  
  
  def get_max_array(p)
    val = []
    for i in 0...p.size
      val[i] = get_max_number(p[i])
    end
    return val
  end
  def get_max_number(p)
    if p.is_a?(Numeric)
      return p
    elsif p.is_a?(Array)
      a = 0
      p.each {|v| a = v if a<v}
      return a
    elsif p.is_a?(Range) || p.is_a?(FreeRange)
      return p.last
    end
  end
  
end

class ParticleEmissorProperties
  # Global attributes
  attr_accessor :viewport
  attr_accessor :simulation_space
  attr_accessor :max_particles
  attr_accessor :duration
  attr_accessor :looping
  attr_accessor :autoplay
  attr_accessor :bitmaps
  
  # Emission attributes
  attr_accessor :pps #Particles Per Second
  attr_accessor :bursts #Array [[t1,n1],[t2,n2]]
  attr_accessor :shape # :circle :square
  attr_accessor :shape_a
  attr_accessor :shape_b
  attr_accessor :shape_angle #circle only, [a,b,c]
  
  # Particle attributes (can receive array, range, etc)
  attr_accessor :lifetime
  attr_accessor :speed
  attr_accessor :speed_modifier # :none :speed :lifetime
  attr_accessor :acceleration
  attr_accessor :acceleration_modifier # :none :speed :lifetime
  attr_accessor :size
  attr_accessor :size_modifier # :none :speed :lifetime
  attr_accessor :rotation
  attr_accessor :rotation_modifier # :none :speed :lifetime
  attr_accessor :opacity
  attr_accessor :opacity_modifier # :none :speed :lifetime
  attr_accessor :color
  attr_accessor :color_modifier # :none :speed :lifetime
  
  def initialize(bitmaps=[])
    @viewport = nil
    @simulation_space = :global
    @max_particles = 1000
    @duration = 200
    @looping = true
    @autoplay = true
    
    @pps = 24
    @bursts = []
    @shape = :circle
    @shape_a = 8
    @shape_b = 0
    @shape_angle = [0,360,0]
    
    @lifetime = 60
    @speed = [FreeRange.new(-1,1),FreeRange.new(-1,1)]# ??
    @speed_modifier = :none
    @acceleration = [0,0]
    @acceleration_modifier = :none
    @size = [FreeRange.new(0.5,1.0),FreeRange.new(0.5,1.0)]
    @size_modifier = :none
    @rotation = 2
    @rotation_modifier = :none
    @opacity = FreeRange.new(192,32)
    @opacity_modifier = :lifetime
    @color = [Color.new(255,255,255,255),
              Color.new(255,255,0,255),
              Color.new(0,0,255,255)]
    @color_modifier = :lifetime
    @bitmaps = bitmaps
  end
  
  def get_random_bitmap
    if @bitmaps.size==0
      b = Bitmap.new(8,8)
      b.fill_rect(b.rect, Color.new(255,255,255,255))
      @bitmaps[0] = b
      return b
    end
    return @bitmaps[rand(bitmaps.size)]
  end
end

class ParticleEmissor
  attr_accessor :properties
  attr_accessor :x
  attr_accessor :y
  
  def initialize(x, y, z, _properties=ParticleEmissorProperties.new)
    @particles = []
    @properties = _properties
    @playing = @properties.autoplay
    @timer = @properties.duration
    @x = x
    @y = y
    @z = z
    @fps = @pps = 0 # Particle creation control variables
  end
  
  def update
    # Create control variables
    to_delete = []
    count = 0
    # Update existing particles.
    @particles.each {|p|
      if p.dead==true
        to_delete.push(p)
      else
        count += 1
        p.update
      end
    }
    # Remove old particles from array
    @particles = (@particles-to_delete)
    
    # Playing particle effect (creates new particles if it's playing)
    return if (!@playing)
    @timer -= 1
    if @timer <= 0
      if @properties.looping
        @timer = @properties.duration
      else
        @playing = false
      end
    end
    return if count > @properties.max_particles
    
    # Current second particles
    @fps += 1
    if @fps > Graphics.frame_rate
      @pps = @fps = 0
    end
    expected_pps = @properties.pps * @fps / Graphics.frame_rate
    particles_to_create = expected_pps - @pps
    
    # TODO - Bursts
    curr_time = @properties.duration - @timer
    @properties.bursts.each { |burst|
      if burst[0]==curr_time
        burst[1].times {|n| create_new_particle(burst[2])}
      end
    }
    
    if particles_to_create > 0
      # Create particle x times
      particles_to_create.times {|n| create_new_particle(nil)}
    end
    @pps = expected_pps
  end
  
  def create_new_particle(bmp)
    return if @particles.size >= @properties.max_particles
    # Create new particles
    if bmp==nil
      b = properties.get_random_bitmap
    else
      b = bmp
    end
    coord = get_shape_coordinate
    p = Particle.new(b, self, coord[0], coord[1], @viewport)
    p.z = @z
    @particles.push(p)
  end
  
  def get_shape_coordinate
    coord = [0,0]
    case @properties.shape
    when :circle
      _ap = @properties.shape_angle
      angle = OZMath.rand_range(_ap[0], _ap[1])
      angle = (angle / _ap[2]).floor * _ap[2] if _ap[2] > 0
      radius = OZMath.rand_range(@properties.shape_a, @properties.shape_b)
      rad = OZMath.deg2rad(angle)
      coord[0] = Math.cos(rad)*radius
      coord[0] = Math.sin(rad)*radius
    when :square
      ah = @properties.shape_a/2
      bh = @properties.shape_b/2
      coord[0] = OZMath.rand_range(-ah,ah)
      coord[1] = OZMath.rand_range(-bh,bh)
    end
    return coord
  end
  
  def dispose
    @particles.each {|p| p.dispose }
  end
end