# The Plane class. Planes are special sprites that tile bitmap patterns across the entire screen and are used to display parallax backgrounds and so on.
class Plane

  # Refers to the bitmap (Bitmap) used in the plane.
  #attr_accessor :bitmap

  # Refers to the viewport (Viewport) associated with the plane.
  attr_accessor :viewport

  # The plane's visibility. If TRUE, the plane is visible. The default value is TRUE.
  #attr_accessor :visible

  # The plane's z-coordinate. The larger the value, the closer to the player the plane will be displayed.
  #
  # If multiple objects share the same z-coordinate, the more recently created object will be displayed closest to the player.
  #attr_accessor :z

  # The x-coordinate of the plane's starting point. Change this value to scroll the plane.
  #attr_reader :ox

  # The y-coordinate of the plane's starting point. Change this value to scroll the plane.
  #attr_reader :oy

  # The plane's opacity (0-255). Out-of-range values are automatically corrected.
  #attr_accessor :opacity

  # The plane's blending mode (0: normal, 1: addition, 2: subtraction).
  #attr_accessor :blend_type

  # The color (Color) to be blended with the plane. Alpha values are used in the blending ratio.
  #attr_accessor :color

  # The plane's color tone (Tone).
  #attr_accessor :tone

  # Creates a Plane object. Specifies a viewport (Viewport) when necessary.
  def initialize(arg_viewport=nil)
    @viewport = arg_viewport
    @sprite = Sprite.new(arg_viewport)
    @sprite.repeat_x = 2
    @sprite.repeat_y = 2
    @src_bitmap = nil
  end

  # Frees the plane. If the plane has already been freed, does nothing.

  def dispose
    @sprite.bitmap.dispose unless @sprite.bitmap.nil? or @sprite.bitmap.disposed?
    @sprite.dispose unless @sprite.nil? or @sprite.disposed?
  end

  # Returns TRUE if the plane has been freed.

  def disposed?
    @sprite.nil? or @sprite.disposed?
  end

  def ox
    @sprite.ox
  end

  def oy
    @sprite.oy
  end

  def ox=(val)
    return if @src_bitmap.nil?
    if zoom_x != 1
      @sprite.ox = (val/zoom_x % @src_bitmap.width*zoom_x)
    else
      @sprite.ox = (val % @src_bitmap.width)
    end
  end


  def oy=(val)
    return if @src_bitmap.nil?
    if zoom_y != 1
      @sprite.oy = (val/zoom_y %  @src_bitmap.height*zoom_y)
    else
      @sprite.oy = (val % @src_bitmap.height)
    end
  end

  def z
    @sprite.z
  end

  def z=(v)
    @sprite.z = v
  end

  def zoom_x
    @sprite.zoom_x
  end

  def zoom_x=(v)
    @sprite.zoom_x = v
  end

  def zoom_y
    @sprite.zoom_y
  end

  def zoom_y=(v)
    @sprite.zoom_y = v
  end

  def bitmap
    @src_bitmap
  end
  def bitmap=(arg_bmp)

    if arg_bmp.nil?
      @src_bitmap = arg_bmp

      @sprite.bitmap.dispose unless @sprite.bitmap.nil?
      @sprite.bitmap = nil
      return
    end

    vp_width = @sprite.viewport.nil? ? \
                            Graphics.width : @sprite.viewport.rect.width
    vp_height = @sprite.viewport.nil? ? \
                            Graphics.height : @sprite.viewport.rect.height

    # 구름같은 것을 그리기 위해서..
    x_steps = [(vp_width.to_f / arg_bmp.width).ceil, 1].max
    y_steps = [(vp_height.to_f / arg_bmp.height).ceil, 1].max

    bmp_width = x_steps * arg_bmp.width
    bmp_height = y_steps * arg_bmp.height

    if not @sprite.bitmap or @sprite.bitmap.disposed? \
      or @sprite.bitmap.width < bmp_width \
      or @sprite.bitmap.height < bmp_height
      @sprite.bitmap.dispose unless @sprite.bitmap.nil?
      @sprite.bitmap = Bitmap.new(bmp_width, bmp_height)
    end

    @src_bitmap = arg_bmp
    arg_bmp.entity.setBlendMode SDL::BLENDMODE_NONE

    x_steps.times { |ix| y_steps.times { |iy|
      @sprite.bitmap.blt(ix * arg_bmp.width, iy * arg_bmp.height,
                         @src_bitmap, @src_bitmap.rect)
    } }
  end

  def method_missing(symbol, *args)
    @sprite.method(symbol).call(*args)
  end

end