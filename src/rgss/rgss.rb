# encoding: utf-8

require 'logger'
begin
  if $NEKO_RUBY >= 190
    require 'neko_ruby19'
  else
    require 'minisdl_ext'
  end
rescue LoadError
  puts $!
  puts 'minisdl_ext is not exist. ignore it.'
end

# The following built-in functions are defined in RGSS.

module RGSS

  Log        = Logger.new(STDOUT)
  @resources = []
  @dirty = false
  @load_path = []
  @mouse_pt = [0, 0]

  class << self
    # 标题
    attr_accessor :title

    # get_file的读取路径，目录字符串的数组
    attr_accessor :load_path

    # get_file的自动补全扩展名，以点开头的扩展名字符串的数组
    attr_accessor :load_ext

    # 屏幕上显示的资源，Drawable的数组
    attr_accessor :resources
    attr_accessor :dirty

    # 显示帧率
    attr_accessor :show_fps

    attr_reader :mouse_pt
    attr_reader :mouse_downs


    def title=(title) # :NODOC:
      @title = 'Kernys RGSS'#title
      SDL::WM.set_caption(title)
      @show_fps = false
      @fps = 0
    end

    # 在load_path指定的目录中查找文件，会自动补全Autoload_Extname里指定的扩展面给，默认为 .png, .jpg, .gif, .bmp, .ogg, .wma, .mp3, .wav, .mid
    #
    # 在Audio和Bitmap的内部自动调用
    #
    # 如果找不到文件，将返回filename本身

    def get_file(filename)
      ([nil] + RGSS.load_path).each do |directory|

        if directory.is_a? String
          directory = directory.force_encoding('UTF-8')
        end

        ([''] + RGSS.load_ext).each do |extname|
          path = (filename + extname).force_encoding('UTF-8')
          path = File.expand_path path, directory

          if File.exist? path
            return path
          end
        end
      end
      filename
    end

    # 初始化RGSS引擎，将会在rgss_main内部自动调用

    def init
      SDL.init SDL::INIT_VIDEO|SDL::INIT_AUDIO|SDL::INIT_TIMER
      Graphics.entity = SDL::Renderer.open(Graphics.width, Graphics.height, 0)
      SDL::Mixer.open(SDL::Mixer::DEFAULT_FREQUENCY, SDL::Mixer::DEFAULT_FORMAT, SDL::Mixer::DEFAULT_CHANNELS, 1536)
      SDL::Mixer.setVolume -1, 128
      SDL::Mixer.setVolumeMusic 128

      SDL::TTF.init
      self.title = @title

      Graphics.setup

      @mouse_downs = [0, 0, 0]

    end

    # 指定是否显示帧率

    def show_fps=(show_fps)
      if show_fps
        SDL::WM.set_caption("#{title} - #{Graphics.real_fps}fps")
      else
        SDL::WM.set_caption(title)
      end

      @show_fps = show_fps
    end

    #
    def _update
      if @show_fps and @fps != Graphics.real_fps
        SDL::WM.set_caption("#{title} - #{Graphics.real_fps}fps")
        @fps = Graphics.real_fps
      end

      while (event = SDL::Event.poll)
        #puts event
        case event
          when SDL::Event::Quit
            SDL.quit
            exit
          when SDL::Event::MouseButtonDown
            unless RGSS.is_mobile?
              if event.button == SDL::BUTTON_LEFT
                @mouse_downs[0] = 1
              elsif event.button == SDL::BUTTON_MIDDLE
                @mouse_downs[1] = 1
              elsif event.button == SDL::BUTTON_RIGHT
                @mouse_downs[2] = 1
              end
            end
          #  SDL.handlePadTouch event.which, event.x, event.y, 0
          when SDL::Event::MouseButtonUp
            unless RGSS.is_mobile?
              if event.button == SDL::BUTTON_LEFT
                @mouse_downs[0] = 2
              elsif event.button == SDL::BUTTON_MIDDLE
                @mouse_downs[1] = 2
              elsif event.button == SDL::BUTTON_RIGHT
                @mouse_downs[2] = 2
              end
            end
          #  SDL.handlePadTouch event.which, event.x, event.y, 1
          when SDL::Event::MouseMotion
            @mouse_pt = [event.x, event.y]
          #  SDL.handlePadTouch event.which, event.x, event.y, 2 if event.state & SDL::BUTTON_LMASK

          when SDL::Event::FingerDown

            # x = 5 if 10 < 7 식으로 줄여서 쓸수 없음!
            if RGSS.is_mobile? and !SDL.handlePadTouch(event.fingerId, event.x, event.y, 0)
              @mouse_downs[0] = 1
            end

          when SDL::Event::FingerUp
            if RGSS.is_mobile? and !SDL.handlePadTouch(event.fingerId, event.x, event.y, 1)
              @mouse_downs[0] = 2
            end

          when SDL::Event::FingerMotion
            SDL.handlePadTouch event.fingerId, event.x, event.y, 2 if RGSS.is_mobile?
          when SDL::Event::KeyDown, SDL::Event::KeyUp
            Input.events << event
          when SDL::Event::Neko
            $neko.handleCommand event.data1 if $neko
          else #when
               #Log.debug "unhandled event: #{event}"
        end
      end
    end

    def is_mobile?
      ENV['OS'] and not ENV['OS'].start_with?('Windows')
    end
  end

  def update(*args)

  end

  self.load_ext  = ['.png', '.jpg', '.gif', '.bmp', '.ogg', '.wma', '.mp3', '.wav', '.mid']
  self.load_path = []
  # Evaluates the provided block one time only.
  #
  # Detects a reset within a block with a press of the F12 key and returns to the beginning if reset.
  #  rgss_main { SceneManager.run }

  def rgss_main
    RGSS.init
    begin
      yield
    rescue RGSSReset
      RGSS.resources.clear
      retry
    end
  end

  # Stops script execution and only repeats screen refreshing. Defined for use in script introduction.
  #
  # Equivalent to the following.
  #
  #  loop { Graphics.update }

  def rgss_stop

  end

  # Outputs the arguments to the message box. If a non-string object has been supplied as an argument, it will be converted into a string with to_s and output.
  #
  # Returns nil.
  #
  # <b>(Not Implemented in OpenRGSS)</b>
  def msgbox(msg)
    if RUBY_PLATFORM['mingw'] or RUBY_PLATFORM['mswin']
      puts msg
    else
      SDL.showAlert msg
      puts msg
    end
  end

  # Outputs obj to the message box in a human-readable format. Identical to the following code (see Object#inspect):
  #
  #  msgbox obj.inspect, "\n", obj2.inspect, "\n", ...
  #
  # Returns nil.
  #
  # <b>(Not Implemented in OpenRGSS)</b>
  def msgbox_p(*args)
    msgbox args.collect { |obj| obj.inspect }.join("\n")
  end

  module Drawable
    attr_accessor :created_at

    def initialize(*args)
      super

      @created_at  = Time.now.to_f
      RGSS.resources << self
    end

    # def >(other)
    #   # 왜 viewport 가 있는 것이 뒤로 밀릴 까 ?
    #   #return super if defined?(super)
    #
    #   if self.viewport == other.viewport
    #     if self.z == other.z
    #       if self.y == other.y
    #         return self.created_at<other.created_at
    #       end
    #
    #       return self.y>other.y
    #     end
    #
    #     return self.z>other.z
    #   end
    #
    #   my_z = self.viewport && self.viewport.z || self.z
    #   other_z = other.viewport && other.viewport.z || other.z
    #
    #   if my_z == other_z
    #     if self.y == other.y
    #       return self.created_at<other.created_at
    #     end
    #
    #     return self.y>other.y
    #   end
    #
    #   return my_z > other_z
    # end

    # #$a=0
    # def <=>(v)
    #   (self>v) ? 1 : -1
    # end

    def disposed?
      @disposed
    end

    def dispose
      @disposed = true
      RGSS.resources.delete self
      RGSS.dirty = true

      super
    end

    def visible=(v)
      return if self.visible == v
      super

      if v
        RGSS.resources << self
      else
        RGSS.resources.delete self
      end

      RGSS.dirty = true
    end

    #def draw(destination=Graphics)
    #  raise NotImplementedError
    #end

  end
end

NekoRGSS = RGSS