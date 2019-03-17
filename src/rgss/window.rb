
class Skin
  #--------------------------------------------------------------------------
  # ? instances settings
  #--------------------------------------------------------------------------
  attr_reader   :margin
  attr_accessor :contents_margin
  attr_accessor :bitmap
  #--------------------------------------------------------------------------
  # ? initialize
  #--------------------------------------------------------------------------
  def initialize
    @bitmap = nil
    @values = {}

    if $RGSS_VERSION == 1
      @values['bg'] = Rect.new(0, 0, 128, 128)
      @values['pause0'] = Rect.new(160, 64, 16, 16)
      @values['pause1'] = Rect.new(176, 64, 16, 16)
      @values['pause2'] = Rect.new(160, 80, 16, 16)
      @values['pause3'] = Rect.new(176, 80, 16, 16)
      @values['arrow_up'] = Rect.new(152, 16, 16, 8)
      @values['arrow_down'] = Rect.new(152, 40, 16, 8)
      @values['arrow_left'] = Rect.new(144, 24, 8, 16)
      @values['arrow_right'] = Rect.new(168, 24, 8, 16)
      self.margin = 16
      self.contents_margin = 16

    elsif $RGSS_VERSION == 2

      @values['bg'] = Rect.new(0, 0, 64, 64)
      @values['pause0'] = Rect.new(160, 64, 16, 16)
      @values['pause1'] = Rect.new(176, 64, 16, 16)
      @values['pause2'] = Rect.new(160, 80, 16, 16)
      @values['pause3'] = Rect.new(176, 80, 16, 16)
      @values['arrow_up'] = Rect.new(152, 16, 16, 8)
      @values['arrow_down'] = Rect.new(152, 40, 16, 8)
      @values['arrow_left'] = Rect.new(144, 24, 8, 16)
      @values['arrow_right'] = Rect.new(168, 24, 8, 16)

      self.margin = 16
      self.contents_margin = 16

    elsif $RGSS_VERSION == 3

      @values['bg'] = Rect.new(0, 0, 64, 64)
      @values['pause0'] = Rect.new(160, 64, 16, 16)
      @values['pause1'] = Rect.new(176, 64, 16, 16)
      @values['pause2'] = Rect.new(160, 80, 16, 16)
      @values['pause3'] = Rect.new(176, 80, 16, 16)
      @values['arrow_up'] = Rect.new(152, 16, 16, 8)
      @values['arrow_down'] = Rect.new(152, 40, 16, 8)
      @values['arrow_left'] = Rect.new(144, 24, 8, 16)
      @values['arrow_right'] = Rect.new(168, 24, 8, 16)

      self.margin = 16
      self.contents_margin = 12
    end
  end
  #--------------------------------------------------------------------------
  # ? width
  #--------------------------------------------------------------------------
  def margin=(width)
    @margin = width
    set_values
  end
  #--------------------------------------------------------------------------
  # ? set_values
  #--------------------------------------------------------------------------
  def set_values
    w = @margin

    if $RGSS_VERSION == 1
      @values['ul_corner'] = Rect.new(128, 0, w, w)
      @values['ur_corner'] = Rect.new(192-w, 0, w, w)
      @values['dl_corner'] = Rect.new(128, 64-w, w, w)
      @values['dr_corner'] = Rect.new(192-w, 64-w, w, w)
      @values['up'] = Rect.new(128+w, 0, 64-2*w, w)
      @values['down'] = Rect.new(128+w, 64-w, 64-2*w, w)
      @values['left'] = Rect.new(128, w, w, 64-2*w)
      @values['right'] = Rect.new(192-w, w, w, 64-2*w)
    elsif $RGSS_VERSION == 2 || $RGSS_VERSION == 3
      @values['ul_corner'] = Rect.new(64, 0, 16, 16)
      @values['ur_corner'] = Rect.new(64+48, 0, 16, 16)
      @values['dl_corner'] = Rect.new(64, 48, 16, 16)
      @values['dr_corner'] = Rect.new(64+48, 48, 16, 16)
      @values['up'] = Rect.new(64+16, 0, 32, 16)
      @values['down'] = Rect.new(64+16, 48, 32, 16)
      @values['left'] = Rect.new(64, 16, 16, 32)
      @values['right'] = Rect.new(64+48, 16, 16, 32)
    end
  end
  #--------------------------------------------------------------------------
  # ? []
  #--------------------------------------------------------------------------
  def [](value)
    return @values[value]
  end
end


#==============================================================================
# ? SG::Cursor_Rect
#==============================================================================

class Cursor_Rect < ::Sprite
  #--------------------------------------------------------------------------
  # ? instances settings
  #--------------------------------------------------------------------------
  attr_reader   :height, :width, :skin, :margin
  #--------------------------------------------------------------------------
  # ? initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @width = 0
    @height = 0
    @skin = nil
    @margin = 0
    @rect = {}

    if $RGSS_VERSION == 1
      @rect['cursor_up'] = Rect.new(129, 64, 30, 1)
      @rect['cursor_down'] = Rect.new(129, 95, 30, 1)
      @rect['cursor_left'] = Rect.new(128, 65, 1, 30)
      @rect['cursor_right'] = Rect.new(159, 65, 1, 30)
      @rect['upleft'] = Rect.new(128, 64, 1, 1)
      @rect['upright'] = Rect.new(159, 64, 1, 1)
      @rect['downleft'] = Rect.new(128, 95, 1, 1)
      @rect['downright'] = Rect.new(159, 95, 1, 1)
      @rect['bg'] = Rect.new(129, 65, 30, 30)
    elsif $RGSS_VERSION == 2 || $RGSS_VERSION == 3
      @rect['cursor_up'] = Rect.new(64+2, 64, 28, 2)
      @rect['cursor_down'] = Rect.new(64+2, 64+30, 28, 2)
      @rect['cursor_left'] = Rect.new(64, 64+2, 2, 28)
      @rect['cursor_right'] = Rect.new(64+30, 64+2, 2, 28)
      @rect['upleft'] = Rect.new(64, 64, 2, 2)
      @rect['upright'] = Rect.new(64+30, 64, 2, 2)
      @rect['downleft'] = Rect.new(64, 64+30, 2, 2)
      @rect['downright'] = Rect.new(64+30, 64+30, 2, 2)
      @rect['bg'] = Rect.new(64+2, 64+2, 28, 28)
    end
  end
  #--------------------------------------------------------------------------
  # ? margin=
  #--------------------------------------------------------------------------
  def margin=(margin)
    @margin = margin
    set(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # ? skin=
  #--------------------------------------------------------------------------
  def skin=(skin)
    return if @skin == skin
    @skin = skin
    draw_rect
  end
  #--------------------------------------------------------------------------
  # ? width=
  #--------------------------------------------------------------------------
  def width=(width)
    return if @width == width
    @width = width
    if @width == 0 and self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    draw_rect
  end
  #--------------------------------------------------------------------------
  # ? height=
  #--------------------------------------------------------------------------
  def height=(height)
    return if @height == height
    @height = height
    if @height == 0 and self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    draw_rect
  end
  #--------------------------------------------------------------------------
  # ? set
  #--------------------------------------------------------------------------
  def set(*args)
    if args.length == 4
      x, y, width, height = args[0], args[1], args[2], args[3]
    elsif args.length == 1
      rect = args[0]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
    end
    self.x = x + @margin
    self.y = y + @margin
    if @width != width or @height != height
      @width = width
      @height = height
      if width > 0 and height > 0
        draw_rect
      end
    end
  end
  #--------------------------------------------------------------------------
  # ? empty
  #--------------------------------------------------------------------------
  def empty
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
  end
  #--------------------------------------------------------------------------
  # ? draw_rect
  #--------------------------------------------------------------------------
  if $RGSS_VERSION == 1
    def draw_rect
      return if @skin == nil
      if @width > 0 and @height > 0

        fw = 0
        w = 0
        self.bitmap.dispose if self.bitmap
        self.bitmap = Bitmap.new(@width, @height)

        @skin.entity.setBlendMode SDL::BLENDMODE_NONE
        @skin.entity.setAlpha 255

        rect = Rect.new(w+1, w+1, @width - 2-fw, @height - 2-fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['bg'])
        self.bitmap.blt(w+0, w+0, @skin, @rect['upleft'])
        self.bitmap.blt(@width-1-w, w, @skin, @rect['upright'])
        self.bitmap.blt(w+0, @height-1-w, @skin, @rect['downright'])
        self.bitmap.blt(@width-1-w, @height-1-w, @skin, @rect['downleft'])

        rect = Rect.new(w+1, w+0, @width - 2-fw, 1+w)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_up'])

        rect = Rect.new(w+0, w+1, 1+w, @height - 2 - fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_left'])

        rect = Rect.new(w+1, @height-1-w, @width - 2-fw, 1-w)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_down'])

        rect = Rect.new(w+@width - 1, 1-w, 1-w, @height - 2-fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_right'])
      end
    end
  elsif $RGSS_VERSION == 2 || $RGSS_VERSION == 3
    def draw_rect
      return if @skin == nil
      if @width > 0 and @height > 0

        fw = 0
        w = 0
        self.bitmap.dispose if self.bitmap
        self.bitmap = Bitmap.new(@width, @height)

        @skin.entity.setBlendMode SDL::BLENDMODE_NONE
        @skin.entity.setAlpha 255

        rect = Rect.new(w+2, w+2, @width - 4-fw, @height - 4-fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['bg'])
        self.bitmap.blt(w+0, w+0, @skin, @rect['upleft'])
        self.bitmap.blt(@width-2-w, w, @skin, @rect['upright'])
        self.bitmap.blt(w+0, @height-2-w, @skin, @rect['downright'])
        self.bitmap.blt(@width-2-w, @height-2-w, @skin, @rect['downleft'])

        rect = Rect.new(w+2, w+0, @width - 4-fw, 2+w)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_up'])

        rect = Rect.new(w+0, w+2, 2+w, @height - 4 - fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_left'])

        rect = Rect.new(w+2, @height-2-w, @width - 4-fw, 2-w)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_down'])

        rect = Rect.new(w+@width - 2, 2-w, 2-w, @height - 4-fw)
        self.bitmap.stretch_blt(rect, @skin, @rect['cursor_right'])
      end
    end
  end
end

#==============================================================================
# ? SG::Window
#------------------------------------------------------------------------------
# ?
#==============================================================================

class Window

  #--------------------------------------------------------------------------
  # ? set instances variables
  #--------------------------------------------------------------------------
  attr_accessor(:width, :height, :ox, :oy, :opacity, :back_opacity,
              :stretch, :contents_opacity, :visible, :paused, :viewport,
              :padding, :padding_bottom, :arrows_visible)

  attr_reader :active

  attr_reader :openness # RGSS_VERSION == 2

  #--------------------------------------------------------------------------
  # ? initialize
  #--------------------------------------------------------------------------
  def initialize(*args)

    viewport = nil
    x, y, width, height = 0, 0, 0, 0

    if args.length == 1
      viewport = args[0]
    elsif args.length == 4
      x, y, width, height = args[0], args[1], args[2], args[3]
    end

    @window_vport = viewport || Viewport.new()
    @viewport = viewport || Viewport.new() # 생성시 취득한 viewport로 고정된다고 한다.
    @cr_vport = Viewport.new()

    @skin = Skin.new
    @width = width
    @height = height
    @ox = 0
    @oy = 0
    @opacity = 255
    @back_opacity = 255
    @contents_opacity = 255
    @bg      = Sprite.new(@window_vport)
    @frame   = Sprite.new(@window_vport)
    @frame.z = @bg.z+1
    @window  = Sprite.new(@viewport)
    @pause_s = Sprite.new(@window_vport)
    @arrows = []
    for i in 0...4
      @arrows.push(Sprite.new(@cr_vport))
      @arrows[i].bitmap = Bitmap.new(16, 16)
      @arrows[i].visible = false
    end
    @cursor_rect = Cursor_Rect.new(@cr_vport)
    @cursor_rect.margin = @skin.contents_margin
    @cursor_fade = true
    @pause_s.visible = false
    @paused = false
    @active = true
    @stretch = true
    @visible = true
    @native_x = 0
    @native_y = 0
    @padding = 12
    @padding_bottom = 0
    @arrows_visible = false
    self.z = 100

    if $RGSS_VERSION == 1
      self.windowskin = RPG::Cache.windowskin($game_system.windowskin_name)
    elsif $RGSS_VERSION == 2 || $RGSS_VERSION == 3
      self.windowskin = RPG::Cache.system("Window")
      @openness = 255
      @opening = false
      @closing = false
      self.contents = Bitmap.new(1, 1)
      @cursor_rect.visible = false

      self.back_opacity = 200
    end

    self.x = x
    self.y = y
  end
  #--------------------------------------------------------------------------
  # for RGSS_VERSION == 2 or 3
  #--------------------------------------------------------------------------
  if $RGSS_VERSION == 2 || $RGSS_VERSION == 3
    def openness=(v)
      @openness = [0, [255, v].min].max
      @visible = @openness == 255
    end

    def viewport=(v)
      v = v || Viewport.new()
      @viewport = v
      @window_vport = v
      @cr_vport.x = v.x
      @cr_vport.y = v.y

      @bg.viewport = v
      @frame.viewport = v
      @window.viewport = v
      @pause_s.viewport = v
    end

    def open?
      return @openness == 255
    end

    def close?
      return @openness == 0
    end

    def tone
      return @bg.tone
    end

    def tone=(v)
       @bg.tone = v
    end
  end

  #--------------------------------------------------------------------------
  # ? contents=
  #--------------------------------------------------------------------------
  def contents=(bmp)
    # @window.bitmap.dispose if @window.bitmap
    @window.bitmap = bmp

    if bmp != nil
      if bmp.width > @viewport.rect.width
        bmp.height > @viewport.rect.height
        draw_arrows
      end
    end
  end

  #--------------------------------------------------------------------------
  # ? contents
  #--------------------------------------------------------------------------
  def contents
    return @window.bitmap
  end
  #--------------------------------------------------------------------------
  # ? dispose
  #--------------------------------------------------------------------------
  def dispose
    @bg.dispose
    @frame.dispose
    @window.dispose
    @cursor_rect.dispose
    @viewport.dispose
    @pause_s.dispose
    @cr_vport.dispose
    for arrow in @arrows
      arrow.dispose
    end
  end

  def disposed?
    return false
  end
  #--------------------------------------------------------------------------
  # ? update
  #--------------------------------------------------------------------------
  def update
    @window.update
    update_cursor_rect
    #@viewport.update
    #@cr_vport.update
    @pause_s.src_rect = @skin["pause#{(Graphics.frame_count / 8) % 4}"]
    @pause_s.update

    update_visible
    update_arrows

    if @cursor_fade
      @cursor_rect.opacity -= 10
      @cursor_fade = false if @cursor_rect.opacity <= 100
    else
      @cursor_rect.opacity += 10
      @cursor_fade = true if @cursor_rect.opacity >= 255
    end
  end
  #--------------------------------------------------------------------------
  # ? update_visible
  #--------------------------------------------------------------------------
  def update_visible
    @frame.visible = @visible
    @bg.visible = @visible
    @window.visible = @visible
    @cursor_rect.visible = @visible
    if @pause
      @pause_s.visible = @visible
    else
      @pause_s.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ? update_cursor_rect
  #--------------------------------------------------------------------------
  def update_cursor_rect
    @cr_vport.x = @viewport.x+@native_x - @viewport.ox
    @cr_vport.y = @viewport.y+@native_y - @viewport.oy
    @cursor_rect.update
  end
  #--------------------------------------------------------------------------
  # ? pause=
  #--------------------------------------------------------------------------
  def pause=(pause)
    @paused = pause
    update_visible
  end
  def pause()
    return @paused
  end
  #--------------------------------------------------------------------------
  # ? update_arrows
  #--------------------------------------------------------------------------
  def update_arrows
    if @window.bitmap == nil or @visible == false
      for arrow in @arrows
        arrow.visible = false
      end
    else
      @arrows[0].visible = @oy > 0
      @arrows[1].visible = @ox > 0
      @arrows[2].visible = (@window.bitmap.width - @ox) > @viewport.rect.width
      @arrows[3].visible = (@window.bitmap.height - @oy) > @viewport.rect.height
    end

    @viewport.ox = @ox
    @viewport.oy = @oy
  end
  #--------------------------------------------------------------------------
  # ? visible=
  #--------------------------------------------------------------------------
  def visible=(visible)
    @visible = visible
    update_visible
    update_arrows
  end
  #--------------------------------------------------------------------------
  # ? x=
  #--------------------------------------------------------------------------
  def x
    @native_x
  end
  def x=(x)
    @native_x = x
    @bg.x = x + 2
    @frame.x = x

    @window.x = @skin.contents_margin
    @viewport.rect.x = x
    @cr_vport.rect.x = x
    @pause_s.x = x + (@width / 2) - 8
    set_arrows
  end
  #--------------------------------------------------------------------------
  # ? y=
  #--------------------------------------------------------------------------
  def y
    @native_y
  end
  def y=(y)
    @native_y = y
    @bg.y = y + 2
    @frame.y = y

    @window.y = @skin.contents_margin
    @viewport.rect.y = y
    @cr_vport.rect.y = y
    @pause_s.y = y + @height - @skin.margin
    set_arrows
  end
  #--------------------------------------------------------------------------
  # ? z=
  #--------------------------------------------------------------------------
  def z
    @native_z
  end
  def z=(z)
    @native_z = z

    @window_vport.z = z
    #
    #
    #@bg.z = z
    #@frame.z = z + 1
    @cr_vport.z = z + 2
    @viewport.z = z + 3
    #@pause_s.z = z + 4
  end
  #--------------------------------------------------------------------------
  # ? ox=
  #--------------------------------------------------------------------------
  def ox=(ox)
    return if @ox == ox
    @ox = ox
    update_arrows
  end
  #--------------------------------------------------------------------------
  # ? oy=
  #--------------------------------------------------------------------------
  def oy=(oy)
    return if @oy == oy
    @oy = oy
    update_arrows
  end
  #--------------------------------------------------------------------------
  # ? width=
  #--------------------------------------------------------------------------
  def width=(width)
    @width = width
    @viewport.rect.width = width - @skin.margin
    @cr_vport.rect.width = width
    if @width > 0 and @height > 0
      @frame.bitmap.dispose if @frame.bitmap
      @frame.bitmap = Bitmap.new(@width, @height)

      @bg.bitmap.dispose if @bg.bitmap
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
      draw_window
    end
  end
  #--------------------------------------------------------------------------
  # ? height=
  #--------------------------------------------------------------------------
  def height=(height)
    @height = height
    @viewport.rect.height = height - @skin.margin
    @cr_vport.rect.height = height
    if @height > 0 and @width > 0
      @frame.bitmap.dispose if @frame.bitmap
      @frame.bitmap = Bitmap.new(@width, @height)

      @bg.bitmap.dispose if @bg.bitmap
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
      draw_window
    end
  end
  #--------------------------------------------------------------------------
  # ? opacity=
  #--------------------------------------------------------------------------
  # contents를 제외한 opacity
  def opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @opacity = value
    @frame.opacity = value

    @bg.opacity = @opacity * value / 255 if @bg
    @back_opacity = value
  end
  #--------------------------------------------------------------------------
  # ? back_opacity=
  #--------------------------------------------------------------------------
  def back_opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @back_opacity = value
    @bg.opacity = @opacity * value / 255
  end
  #--------------------------------------------------------------------------
  # ? contents_opacity=
  #--------------------------------------------------------------------------
  # contents 만을 위한 opacity
  def contents_opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @contents_opacity = value
    @window.opacity = value
  end
  #--------------------------------------------------------------------------
  # ? cursor_rect
  #--------------------------------------------------------------------------
  def cursor_rect
    return @cursor_rect
  end
  #--------------------------------------------------------------------------
  # ? cursor_rect=
  #--------------------------------------------------------------------------
  def cursor_rect=(rect)
    if $RGSS_VERSION == 1
      @cursor_rect.x = rect.x
      @cursor_rect.y = rect.y
    elsif $RGSS_VERSION == 2 || $RGSS_VERSION == 3
      @cursor_rect.x = @cursor_rect.margin+rect.x
      @cursor_rect.y = @cursor_rect.margin+rect.y
    end

    if @cursor_rect.width != rect.width or @cursor_rect.height != rect.height
      @cursor_rect.set(rect.x, rect.y, rect.width, rect.height)
    end
  end
  #--------------------------------------------------------------------------
  # ? windowskin
  #--------------------------------------------------------------------------
  def windowskin
    return @skin.bitmap
  end
  #--------------------------------------------------------------------------
  # ? windowskin=
  #--------------------------------------------------------------------------
  def windowskin=(windowskin)
    return if windowskin == nil
    if @skin.bitmap != windowskin
      @pause_s.bitmap = windowskin
      @pause_s.src_rect = @skin['pause0']
      @skin.bitmap = windowskin
      @cursor_rect.skin = windowskin
      draw_window
      draw_arrows
    end
  end
  #--------------------------------------------------------------------------
  # ? margin=
  #--------------------------------------------------------------------------
  def margin=(margin)
    if @skin.margin != margin
      @skin.margin = margin
      self.x = @native_x
      self.y = @native_y
      temp = @height
      self.height = 0
      self.width = @width
      self.height = temp
      @cursor_rect.margin = margin
      set_arrows
    end
  end
  #--------------------------------------------------------------------------
  # ? stretch=
  #--------------------------------------------------------------------------
  def stretch=(bool)
    if @stretch != bool
      @stretch = bool
      draw_window
    end
  end
  #--------------------------------------------------------------------------
  # ? set_arrows
  #--------------------------------------------------------------------------
  def set_arrows
    @arrows[0].x = @width / 2 - 8
    @arrows[0].y = 8
    @arrows[1].x = 8
    @arrows[1].y = @height / 2 - 8
    @arrows[2].x = @width - 16
    @arrows[2].y = @height / 2 - 8
    @arrows[3].x = @width / 2 - 8
    @arrows[3].y = @height - 16
  end
  #--------------------------------------------------------------------------
  # ? draw_arrows
  #--------------------------------------------------------------------------
  def draw_arrows
    return if @skin.bitmap == nil
    @arrows[0].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_up'])
    @arrows[1].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_left'])
    @arrows[2].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_right'])
    @arrows[3].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_down'])
    update_arrows
  end
  #--------------------------------------------------------------------------
  # ? draw_window
  #--------------------------------------------------------------------------
  def draw_window
    return if @skin.bitmap == nil
    return if @width == 0 or @height == 0
    m = @skin.margin
    if @frame.bitmap.nil?

      @frame.bitmap.dispose if @frame.bitmap
      @frame.bitmap = Bitmap.new(@width, @height)

      @bg.bitmap.dispose if @bg.bitmap
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
    end
    @frame.bitmap.clear
    @bg.bitmap.clear

    @skin.bitmap.entity.setBlendMode SDL::BLENDMODE_NONE

    if @stretch
      dest_rect = Rect.new(0, 0, @width-4, @height-4)
      @bg.bitmap.stretch_blt(dest_rect, @skin.bitmap, @skin['bg'])
    else
      bgw = Integer((@width-4) / 128) + 1
      bgh = Integer((@height-4) / 128) + 1
      for x in 0..bgw
        for y in 0..bgh
          @bg.bitmap.blt(x * 128, y * 128, @skin.bitmap, @skin['bg'])
        end
      end
    end

    bx = Integer((@width - m*2) / @skin['up'].width) + 1
    by = Integer((@height - m*2) / @skin['left'].height) + 1

    for x in 0..bx
      w = @skin['up'].width
      @frame.bitmap.blt(x * w + m, 0, @skin.bitmap, @skin['up'])
      @frame.bitmap.blt(x * w + m, @height - m, @skin.bitmap, @skin['down'])
    end
    for y in 0..by
      h = @skin['left'].height
      @frame.bitmap.blt(0, y * h + m, @skin.bitmap, @skin['left'])
      @frame.bitmap.blt(@width - m, y * h + m, @skin.bitmap, @skin['right'])
    end
    @frame.bitmap.erase(@width - m, 0, m, m)
    @frame.bitmap.erase(0, @height - m, m, m)
    @frame.bitmap.erase(@width - m, @height - m, m, m)
    @frame.bitmap.blt(0, 0, @skin.bitmap, @skin['ul_corner'])
    @frame.bitmap.blt(@width - m, 0, @skin.bitmap, @skin['ur_corner'])
    @frame.bitmap.blt(0, @height - m, @skin.bitmap, @skin['dl_corner'])
    @frame.bitmap.blt(@width - m, @height - m, @skin.bitmap, @skin['dr_corner'])

    #@skin.bitmap.entity.setBlendMode SDL::BLENDMODE_BLEND
  end
  #--------------------------------------------------------------------------
  # ? active=
  # active가 false일때에는 index값도 -1이 되어야한다. 선택 안되어있게끔.
  #--------------------------------------------------------------------------
  def active=(v)
    @active = v
  end

  include RGSS::Drawable

end