
#require 'ruby-prof'
#
## Profile the code
#RubyProf.start

module Graphics
  FPS_COUNT               = 30
  @frame_rate             = 40 # faster mode
  @frame_count            = 0
  @frame_count_recent     = 0
  @skip                   = 0
  @ticks                  = 0
  @fps_ticks              = 0
  @brightness             = 255
  @width                  = 640
  @height                 = 480
  @graphics_render_target = nil # need rebuild when resize.
  @freeze                 = false                # or true?
  @tilemap = nil

  class <<self
    attr_reader :width, :height
    attr_accessor :entity
    attr_accessor :frame_rate, :frame_count, :brightness

    attr_reader :real_fps
    attr_accessor :tilemap

    def setup
      return if @graphics_render_target

      @ticks = SDL.getTicks
      @fps_ticks = SDL.getTicks
    end

    def resize_screen(width, height)
      @width  = width
      @height = height

      @entity.setSize(width, height) if @entity
    end

    def update

      RGSS._update
      Input._update

      $profiler.step '#0.9'

      @frame_count += 1
      #if @skip >= 10 or SDL.getTicks < @ticks + 1000 / @frame_rate

        if RGSS.dirty # Maybe here can make a dirty mark
          RGSS.resources.uniq!
          RGSS.dirty = false
        end
        #
        unless @freezed # redraw only when !freezed

          @entity.clear
          @tilemap.draw if @tilemap

          #puts " --------------------------"
          for resource in RGSS.resources
            resource.draw
          end
        end

        @entity.flushSprites

      if RGSS.is_mobile?
        SDL.drawPad
      end

        @entity.updateRect if @entity

        if $DEBUG && !RGSS.is_mobile?
          sleeptime = @ticks + 1000 / @frame_rate - SDL.getTicks
          sleep sleeptime.to_f / 1000 if sleeptime > 0
          @ticks = SDL.getTicks
        end
      #
      #  @skip  = 0
      #else
      #  @skip += 1
      #end

      $profiler.step '#1'


      @frame_count_recent += 1
      if SDL.getTicks - @fps_ticks >= 5000
        @real_fps = (@frame_count_recent.to_f / (SDL.getTicks - @fps_ticks) * 1000).to_i
        @frame_count_recent = 0

        puts "FPS = #{@real_fps}, resources = #{RGSS.resources.length}"
        @fps_ticks = SDL.getTicks

        #result = RubyProf.stop
        ##
        #printer = RubyProf::FlatPrinter.new(result)
        #printer.print($stdout)
        ##
        #RubyProf.start
      end

      #if @frame_count_recent >= FPS_COUNT
      #  @frame_count_recent = 0
      #  now                 = SDL.getTicks
      #  @real_fps           = FPS_COUNT * 1000 / (now - @fps_ticks)
      #  @fps_ticks          = now
      #end

      $profiler.show
    end

    def wait(duration)
      #duration.times { update }
    end

    def fadeout(duration)
      # TODO
      #step=255/duration
      #duration.times { |i| @brightness=255-i*step; update }
      #@brightness=0
    end

    def fadein(duration)
      # TODO
      #step=255/duration
      #duration.times { |i| @brightness=i*step; update }
      #@brightness=255
    end

    def freeze
      @freezed=true
    end

    def transition(duration=10, filename=nil, vague=40)

      SDL::Renderer.clearTextureCache

      @freezed = false
      return

      if (duration==0)
        @freezed=false; return;
      end
      if (filename.nil?) #
        imgmap=Array.new(@width) { Array.new(@height) { 255 } }
      else #
        b     =Bitmap.new(filename); pfb = b.entity.format
        imgmap=Array.new(@width) { |x| Array.new(@height) { |y| [pfb.get_rgb(b.entity[x, y])[0], 1].max } }
                         #TODO : free
      end
      step      =255/duration
      new_frame = Bitmap.new(@width, @height)
      @old_resources=RGSS.resources.clone
      new_frame.entity.fill_rect(0, 0, @width, @height, new_frame.entity.map_rgba(0, 0, 0, 255))
      new_frame.entity.set_alpha(SDL::SRCALPHA, 255)
      RGSS.resources.each { |resource| resource.draw(new_frame) }
                                                                                                     # draw frame to bitmap

      pf = new_frame.entity.format
      new_frame.entity.lock
      picmap=Array.new(@width) { |x| Array.new(@height) { |y| pf.getRGBA(new_frame.entity[x, y]) } } # better to use bit calculate
      new_frame.entity.unlock
      maker = Bitmap.new(@width, @height)
                                                                                                     # create pre-render layoyt
      maker.entity.fill_rect(0, 0, @width, @height, new_frame.entity.map_rgba(0, 0, 0, 255))
      maker.entity.put @graphics_render_target.entity, 0, 0
                                                                                                     # transition layout
      new_frame.entity.lock
      @width.times { |x| @height.times { |y|
        if (imgmap[x][y]!=0)
          new_frame.entity[x, y]=pf.map_rgba(picmap[x][y][0], picmap[x][y][1], picmap[x][y][2], [255/(duration/(255.0/imgmap[x][y])), 255].min)
          #TODO : alpha will be 255 after many render.it's different fron RPG Maker
        else
          new_frame.entity[x, y]=pf.map_rgba(picmap[x][y][0], picmap[x][y][1], picmap[x][y][2], 255)
        end
      } }
      new_frame.entity.unlock
        duration.times { |i|
        #@entity.fill_rect(0, 0, @width, @height, 0x000000)
        @entity.fill_rect(0, 0, @width, @height, new_frame.entity.map_rgba(0, 0, 0, 255))
        maker.entity.put new_frame.entity, 0, 0 # alpha
        @entity.put maker.entity, 0, 0
        @entity.update_rect(0, 0, 0, 0)
      }
                                                                                                     # TODO: free
      @graphics_render_target.entity.set_alpha(0, 255); @freezed=false; @brightness=255; update
    end

    def snap_to_bitmap
      return Bitmap.new(32, 32)
    end

    def frame_reset

    end

    def play_movie(filename)

    end

    def brightness=(brightness)
      @brightness = brightness < 0 ? 0 : brightness > 255 ? 255 : brightness
      #gamma       = @brightness.to_f / 255
      #SDL::Screen.set_gamma(5,1,1)
      #seems SDL::Screen.set_gamma and SDL::Screen.set_gamma_rmap doesn't work
    end
  end
end
