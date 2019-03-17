# A module that handles input data from a gamepad or keyboard.
#
# Managed by symbols rather than button numbers in RGSS3. (RGSS3)

module Input
  KeyMaps = {
      :DOWN => [2, SDL::Key::DOWN], #, SDL::Key::S],
      :LEFT => [4, SDL::Key::LEFT], #, SDL::Key::A],
      :RIGHT => [6, SDL::Key::RIGHT], #, SDL::Key::D],
      :UP => [8, SDL::Key::UP], #, SDL::Key::W],

      :A => [11, SDL::Key::LSHIFT], # Y
      :B => [12, SDL::Key::X, SDL::Key::ESCAPE],
      :C => [13, SDL::Key::Z, SDL::Key::RETURN],

      :X => [14, SDL::Key::A],
      :Y => [15, SDL::Key::D],
      :Z => [16, SDL::Key::S],

      :L => [17, SDL::Key::PAGEUP],
      :R => [18, SDL::Key::PAGEDOWN],

      :SHIFT => [21, SDL::Key::RSHIFT],
      :CTRL => [22, SDL::Key::RSHIFT],
      :ALT => [23, SDL::Key::RSHIFT],
      :F5 => [25, SDL::Key::F5],
      :F6 => [26, SDL::Key::F6],
      :F7 => [27, SDL::Key::F7],
      :F8 => [28, SDL::Key::F8],
      :F9 => [29, SDL::Key::F9],
      :SHOW_FPS => [108, SDL::Key::F2],
      :RESET => [109, SDL::Key::F12],

      :S => [114,], # S
  }

  # 여기는 SDL의 심볼이 들어간다.
  Entities = {}

  KeyMaps.each { |key, value|
    const_set(key, value[0])
    value[1..-1].each { |entity| Entities[entity] = value[0] }

  }
  @status = {}
  @events = []
  @update_replaced = true

  class <<self
    attr_accessor :events

    # Updates input data. As a general rule, this method is called once per frame.

    def _update
      if @update_replaced
        for k, v in @status
          @status[k] = v.next
        end

        while event = events.shift
          key = Entities[event.sym]

          next if event.repeat > 0

          if event.press
            case key
              when :SHOW_FPS
                RGSS.show_fps = !RGSS.show_fps
              when :RESET
                raise RGSSReset
              else
                @status[key] = 0
            end
          else
            @status.delete key
          end
        end
      end

      @update_replaced = true
    end

    def update
      @update_replaced = false
      for k, v in @status
        @status[k] = v.next
      end

      while event = events.shift
        key = Entities[event.sym]

        next if event.repeat > 0

        if event.press
          case key
            when :SHOW_FPS
              RGSS.show_fps = !RGSS.show_fps
            when :RESET
              raise RGSSReset
            else
              @status[key] = 0
          end
        else
          @status.delete key
        end
      end
    end

    # Determines whether the button corresponding to the symbol sym is currently being pressed.
    #
    # If the button is being pressed, returns TRUE. If not, returns FALSE.
    #
    #  if Input.press?(:C)
    #    do_something
    #  end

    def _press?(sym)
      sym = KeyMaps[sym][0] if sym.class == Symbol
      return !@status[sym].nil?
    end

    def press?(*args)
      return _press?(*args)
    end

    # Determines whether the button corresponding to the symbol sym is currently being pressed again.
    #
    # "Pressed again" is seen as time having passed between the button being not pressed and being pressed.
    #
    # If the button is being pressed, returns TRUE. If not, returns FALSE.

    def _trigger?(sym)
      sym = KeyMaps[sym][0] if sym.class == Symbol
      if (@status[sym] and @status[sym].zero?)
        # if $RGSS_VERSION >= 2
        #   @status[sym] = @status[sym].next
        # end
        return true
      end

      return false
    end

    def trigger?(*args)
      return _trigger?(*args)
    end

    # Determines whether the button corresponding to the symbol sym is currently being pressed again.
    #
    # Unlike trigger?, takes into account the repeated input of a button being held down continuously.
    #
    # If the button is being pressed, returns TRUE. If not, returns FALSE.

    def _repeat?(sym)
      sym = KeyMaps[sym][0] if sym.class == Symbol
      @status[sym] and (@status[sym].zero? or (@status[sym] > 10 and (@status[sym] % 4).zero?))
    end

    def repeat?(*args)
      return _repeat?(*args)
    end

    # Checks the status of the directional buttons, translates the data into a specialized 4-direction input format, and returns the number pad equivalent (2, 4, 6, 8).
    #
    # If no directional buttons are being pressed (or the equivalent), returns 0.

    def _status(sym)
      @status[KeyMaps[sym][0]]
    end

    def status(*args)
      return _status(*args)
    end

    def dir4
      case
        when status(:DOWN)
          2
        when status(:LEFT)
          4
        when status(:RIGHT)
          6
        when status(:UP)
          8
        else
          0
      end
    end

    # Checks the status of the directional buttons, translates the data into a specialized 8-direction input format, and returns the number pad equivalent (1, 2, 3, 4, 6, 7, 8, 9).
    #
    # If no directional buttons are being pressed (or the equivalent), returns 0.

    def dir8
      case
        when status(:DOWN) && status(:LEFT)
          1
        when status(:DOWN) && status(:RIGHT)
          3
        when status(:DOWN)
          2
        when status(:UP) && status(:LEFT)
          7
        when status(:UP) && status(:RIGHT)
          9
        when status(:UP)
          8
        when status(:LEFT)
          4
        when status(:RIGHT)
          6
        else
          0
      end
    end

    def _win32_to_sdl(button)
      case button
        when 0x28
          return NekoInput::DOWN
        when 0x25
          return NekoInput::LEFT
        when 0x27 # Right
          return NekoInput::RIGHT
        when 0x26 # Up
          return NekoInput::UP
        when 0x5A, 0x10 # Z, Shift
          return NekoInput::A
        when 0x58, 0x1B # X, ESC
          return NekoInput::B
        when 0x43, 0x0d, 0x20 # C, ENTER, Space
          return NekoInput::C
        when 0x41 # A
          return NekoInput::X
        when 0x53 # S
          return NekoInput::Y
        when 0x44 # D
          return NekoInput::Z
        when 0x51, 0x21 # Q, Page Up
          return NekoInput::L
        when 0x57, 0x22 # W, Page Down
          return NekoInput::R
        when 0x10
          return NekoInput::SHIFT
        when 0x11
          return NekoInput::CTRL
        when 0x12
          return NekoInput::ALT
        when 0x74 # F5
          return NekoInput::F5
        when 0x75 # F6
          return NekoInput::F6
        when 0x76 # F7
          return NekoInput::F7
        when 0x77 # F8
          return NekoInput::F8
        when 0x78 # F9
          return NekoInput::F9
        else
          return -1
      end
    end
  end

end

NekoInput = Input