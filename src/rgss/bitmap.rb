# The bitmap class. Bitmaps represent images.
#
# Sprites (Sprite) and other objects must be used to display bitmaps onscreen.

class Bitmap
  attr_accessor :font, :entity, :text

  # :call-seq:
  #  Bitmap.new(filename)
  #  Bitmap.new(width, height)
  #
  # Loads the graphic file specified in filename or size and creates a bitmap object.
  #
  # Also automatically searches files included in RGSS-RTP and encrypted archives. File extensions may be omitted.

  def initialize(width, height=nil)
    @entity = if width.is_a? String
      filename = width

      begin
        s = SDL::Surface.load(filename)
      rescue
        filepath = RGSS.get_file(filename)
        s = SDL::Surface.load(filepath)
      end

      # Convert surface format to ARGB32
      dest = SDL::Surface.convertFormat(s, SDL::PIXELFORMAT_ARGB8888, 0)
      s.destroy


      dest.setBlendMode SDL::BLENDMODE_NONE

      dest
    elsif width.is_a? SDL::Renderer
      width
    else
      rmask = 0x00ff0000
      gmask = 0x0000ff00
      bmask = 0x000000ff
      amask = 0xff000000

      #begin
      #1/0
      #rescue
      #  puts '---------------------'
      #  puts $!.backtrace
      #end

      SDL::Surface.create(0, width, height, 32, rmask, gmask, bmask, amask)
    end

    @font   = Font.new
    @width = @entity.w
    @height = @entity.h
  end

  # Frees the bitmap. If the bitmap has already been freed, does nothing.

  def dispose
    if @entity and @entity.is_a? SDL::Surface
      @entity.destroy
      @entity = nil
    end
  end

  # Returns true if the bitmap has been freed.

  def disposed?
    return true if not @entity or not @entity.is_a? SDL::Surface
  end

  # Gets the bitmap width.

  def width
    @width
  end

  # Gets the bitmap height.

  def height
    @height
  end

  # Gets the bitmap rectangle (Rect).

  def rect
    Rect.new(0, 0, width, height)
  end

  def clone
    b        = Bitmap.new(width, height)
    b.blt 0, 0, self, Rect.new(0, 0, width, height)
    b.font   = Font.new(b.font.name, b.font.size)

    b
  end

  def dup
    clone
  end

  # Performs a block transfer from the src_bitmap box src_rect (Rect) to the specified bitmap coordinates (x, y).
  #
  # opacity can be set from 0 to 255.

  def blt(x, y, src_bitmap, src_rect, opacity=255, z=0)
    return if @entity.nil?

    return if src_bitmap.nil? or src_bitmap.entity.nil?

    src_bitmap.entity.setAlpha(opacity)


    if @entity.is_a? SDL::Renderer
      @entity.stretchBlit(src_bitmap.entity,
                          [src_rect.x, src_rect.y, src_rect.width, src_rect.height],
                          [x, y, src_rect.width, src_rect.height],
                          z)
    else
      SDL::Surface.blit(src_bitmap.entity, src_rect.x, src_rect.y,
                        src_rect.width, src_rect.height,
                        @entity, x, y)
    end
  end

  # Performs a block transfer from the src_bitmap box src_rect (Rect) to the specified bitmap box dest_rect (Rect).
  #
  # opacity can be set from 0 to 255.

  def stretch_blt(dest_rect, src_bitmap, src_rect, opacity=255, z=0)
    return if @entity.nil?

    src_bitmap.entity.setAlpha(opacity)

    if @entity.is_a? SDL::Renderer
      @entity.stretchBlit(src_bitmap.entity,
                          [src_rect.x, src_rect.y, src_rect.width, src_rect.height],
                          [dest_rect.x, dest_rect.y, dest_rect.width, dest_rect.height],
                          z)
    else
      SDL::Surface.stretchBlit(src_bitmap.entity,
                               [src_rect.x, src_rect.y, src_rect.width, src_rect.height],
                               @entity,
                               [dest_rect.x, dest_rect.y, dest_rect.width, dest_rect.height])
    end


  end

  # :call-seq:
  # fill_rect(x, y, width, height, color)
  # fill_rect(rect, color)
  #
  # Fills the bitmap box (x, y, width, height) or rect (Rect) with color (Color).

  def fill_rect(x, y, width=nil, height=nil, color=nil)
    return if @entity.nil?

    if x.is_a? Rect
      rect   = x
      color  = y
      x      = rect.x
      y      = rect.y
      width  = rect.width
      height = rect.height
    end
    @entity.fillRect(x, y, width, height, @entity.mapRGBA(color.red, color.green, color.blue, color.alpha))
  end

  def erase(*args)
    if args.size == 1
      rect = args[0]
    elsif args.size == 4
      rect = Rect.new(*args)
    end
    fill_rect(rect, Color.new(0, 0, 0, 0))
  end

  # :call-seq:
  # gradient_fill_rect(x, y, width, height, color1, color2[, vertical])
  # gradient_fill_rect(rect, color1, color2[, vertical])
  #
  # Fills in this bitmap box (x, y, width, height) or rect (Rect) with a gradient from color1 (Color) to color2 (Color).
  #
  # Set vertical to true to create a vertical gradient. Horizontal gradient is the default.

  def gradient_fill_rect(x, y, width, height=false, color1=nil, color2=nil, vertical=false)
    return if @entity.nil?

    if x.is_a? Rect
      rect     = x
      color1   = y
      color2   = width
      vertical = height
      x        = rect.x
      y        = rect.y
      width    = rect.width
      height   = rect.height
    end
    if vertical
      height.times do |i|
        @entity.fillRect(x, y+i, width, 1, self.map_rgba(
            color1.red + (color2.red - color1.red) * i / height,
            color1.green + (color2.green - color1.green) * i / height,
            color1.blue + (color2.blue - color1.blue) * i / height,
            color1.alpha + (color2.alpha - color1.alpha) * i / height
        ))
      end
    else
      width.times do |i|
        @entity.fillRect(x+i, y, 1, height, self.map_rgba(
            color1.red + (color2.red - color1.red) * i / width,
            color1.green + (color2.green - color1.green) * i / width,
            color1.blue + (color2.blue - color1.blue) * i / width,
            color1.alpha + (color2.alpha - color1.alpha) * i / width
        ))
      end
    end
  end

  def map_rgba(a, r, g, b)
    return (a << 24) | (r << 16) | (g << 8) | b
  end

  # Clears the entire bitmap.

  def clear
    return if @entity.nil?

    @entity.fillRect(0, 0, width, height, 0x00000000)
  end

  # Clears this bitmap box or (x, y, width, height) or rect (Rect).

  def clear_rect(x, y=nil, width=nil, height=nil)
    return if @entity.nil?

    if x.is_a? Rect
      rect   = x
      x      = rect.x
      y      = rect.y
      width  = rect.width
      height = rect.height
    end
    @entity.fillRect(x, y, width, height, 0x00000000)
  end

  # Gets the color (Color) at the specified pixel (x, y).

  def get_pixel(x, y)

    color = @entity.getPixel(x, y)
    Color.new((color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff, (color >> 24) & 0xff)
  end

  # Sets the specified pixel (x, y) to color (Color).

  def set_pixel(x, y, color)
    return if @entity.nil?

    @entity.putPixel(x, y, @entity.mapRGBA(color.red, color.green, color.blue, color.alpha))
  end

  # Changes the bitmap's hue within 360 degrees of displacement.
  #
  # This process is time-consuming. Furthermore, due to conversion errors, repeated hue changes may result in color loss.

  def hue_change(hue)
    if @entity and @entity.is_a? SDL::Surface
      @entity.hueChange hue
    end
  end

  # Applies a blur effect to the bitmap. This process is time consuming.

  def blur
    # TODO
  end

  # Applies a radial blur to the bitmap. angle is used to specify an angle from 0 to 360. The larger the number, the greater the roundness.
  #
  # division is the division number (from 2 to 100). The larger the number, the smoother it will be. This process is very time consuming.

  def radial_blur(angle, division)
    # TODO
  end

  # Draws the string str in the bitmap box (x, y, width, height) or rect (Rect).
  #
  # If str is not a character string object, it will be converted to a character string using the to_s method before processing is performed.
  #
  # If the text length exceeds the box's width, the text width will automatically be reduced by up to 60 percent.
  #
  # Horizontal text is left-aligned by default. Set align to 1 to center the text and to 2 to right-align it. Vertical text is always centered.
  #
  # As this process is time-consuming, redrawing the text with every frame is not recommended.

  def draw_text(x, y, width=0, height=nil, str=nil, align=0 )
    return if @entity.nil?

    if x.is_a? Rect
      rect  = x
      str   = y
      align = width

      x      = rect.x
      y      = rect.y
      width  = rect.width
      height = rect.height
    end

    str = str.to_s
    if align == 2
      x += width - @font.entity.textSize(str)[0]
    elsif align == 1
      x += (width - @font.entity.textSize(str)[0]) / 2
    end

    y += (height - @font.entity.textSize(str)[1]) / 2 if height

    # @text << [str, x, y, @font.color.red, @font.color.green, @font.color.blue] See you ~
    tmp = @font.entity.renderBlendedUTF8(str,  @font.color.red, @font.color.green, @font.color.blue)
    return if tmp.nil?
    tmp.setAlpha @font.color.alpha
    tmp.setBlendMode SDL::BLENDMODE_NONE
    @entity.put tmp, x, y

    tmp.destroy
  end

  # Gets the box (Rect) used when drawing the string str with the draw_text method. Does not include the outline portion (RGSS3) and the angled portions of italicized text.
  #
  # If str is not a character string object, it will be converted to a character string using the to_s method before processing is performed.

  def text_size(str)
    Rect.new 0, 0, *@font.entity.textSize(str.to_s)
  end
end