class Win32API

  def initialize(dll_name, func_name, arg_types, return_type)
    @dll_name = dll_name
    @func_name = func_name
    @return_type = return_type

    puts "Win32API init #{dll_name}, #{func_name}"
  end

  def call(*rest)

    if @dll_name == 'kernel32'
      if @func_name == 'RtlMoveMemory'
        if rest[1].is_a? String
          rest[0].gsub!(/.*/, rest[1].slice(0, rest[2]))
        else
          rest[0].gsub!(/.*/, SDL::Net.RtlMoveMemory(*rest))
        end

        return rest[2]
      end
    elsif @dll_name == 'user32'
      if @func_name == 'GetAsyncKeyState'
        ret = if rest[0] == 1
                RGSS.mouse_downs[0]
              elsif rest[0] == 2
                RGSS.mouse_downs[2]
              elsif rest[0] == 4
                RGSS.mouse_downs[1]
              else
                Input._press?(Input._win32_to_sdl(rest[0])) ? 1 : 0
              end

        case ret
          when 0
            return 0
          when 1
            return 0x8001
          when 2
            return 0x8000
        end

        return 0
      elsif @func_name == 'GetKeyState'
        ret = if rest[0] == 1
                RGSS.mouse_downs[0]
              elsif rest[0] == 2
                RGSS.mouse_downs[2]
              elsif rest[0] == 4
                RGSS.mouse_downs[1]
              else
                Input._press?(Input._win32_to_sdl(rest[0])) ? 1 : 0
              end

        case ret
          when 0
            return 0
          when 1
            return 0x0001
          when 2
            return 0xffffff80
        end

        return 0
      elsif @func_name == 'GetCursorPos'
        return rest[0].gsub!(/.*/, RGSS.mouse_pt.pack('ll'))
      elsif @func_name == 'ShowCursor'
        SDL.showCursor(rest[0])
      elsif @func_name == 'ScreenToClient'
        return rest[1]
      elsif @func_name == 'GetForegroundWindow'
        return 1
      elsif @func_name == 'GetWindowThreadProcessId'
        return 1
      elsif @func_name == 'GetKeyboardState'
        return SDL::Key::getKeyboardStateWin32(rest[0])
      elsif @func_name == 'GetKeyboardLayout'
        return 4070409
      end
    elsif @dll_name == 'kernel32'
      if @func_name == 'GetCurrentThreadId'
        return 1
      end
    # Winsock 2.0
    elsif @dll_name == 'ws2_32'
      if @func_name == 'socket'
        return SDL::Net.socket(*rest)
      elsif @func_name == 'gethostbyname'
        return SDL::Net.gethostbyname(*rest)
      elsif @func_name == 'bind'
        return SDL::Net.bind(*rest)
      elsif @func_name == 'send'
        return SDL::Net.send(*rest)
      elsif @func_name == 'recv'
        return SDL::Net.recv(*rest)
      elsif @func_name == 'closesocket' || @func_name == 'close'
        return SDL::Net.close(*rest)
      elsif @func_name == 'connect'
        return SDL::Net.connect(*rest)
      elsif @func_name == 'select'
        return SDL::Net.select(*rest)
      elsif @func_name == 'WSAGetLastError'
        return 0
      end
    end

    puts "Win32API call #{@dll_name}, #{@func_name}"

    # DO NOTHING
    return 1 if @return_type == 'I'
    return 1 if @return_type == 'l'
    return nil if @return_type == 'v'
    return true

  end


  def Call(*rest)
    call(*rest)
  end
end

# Ruby 1.8버전과 호환성을 위해 추가한 기능.
class NilClass
  def id
    return self.object_id
  end
  def type
    return self.class
  end
end

if $NEKO_RUBY < 190
  class String
    def force_encoding(enc)
      self
    end
  end
end

class ::String
  alias original_cmpregex =~
  def =~(v)
    if v.is_a?(String)
      return self.index(v)
    else
      return original_cmpregex v
    end
  end
end

class RGSSError < StandardError

end

module Kernel

  alias rgss_kernel_open open

  def load_data(filename)
    begin
      File.open(filename, "rb") { |f|
        next Marshal.load(f)
      }
    rescue
      return Marshal.load(SDL.loadData(filename))
    end
  end

  def save_data(obj, filename)
    File.open(filename, "wb") { |f|
      Marshal.dump(obj, f)
    }
  end

  class << self
    alias rgss_kernel_open open

    def open(*args, &block)
      args[0].gsub!("\\", "/")

      if $DEBUG
        puts "Kernel open #{args[0]}"
      end

      rgss_kernel_open *args, &block
    end
  end
end


class Dir
  class << self
    alias rgss_dir_mkdir mkdir
  end

  def self.mkdir(path)
    if $DEBUG
      puts "Dir mkdir #{path.gsub("\\", "/")}"
    end

    rgss_dir_mkdir path.gsub("\\", "/")
  end
end

class File
  alias rgss_file_initialize initialize

  def initialize(*args)
    args[0].gsub!("\\", "/")
    rgss_file_initialize *args

  end

  class << self
    alias rgss_file_exist? exist?
    alias rgss_file_open open

    def exist?(path)
      #if $DEBUG
      #  puts "File exists? #{path.gsub("\\", "/")}"
      #end

      rgss_file_exist? (path.gsub("\\", "/"))
    end

    alias exists? exist?

    def open(*args, &block)
      args[0].gsub!("\\", "/")

      if $DEBUG
        puts "File open #{args[0]}"
      end

      rgss_file_open *args, &block
    end
  end

end

module FileTest


  class << self
    alias rgss_filetest_exist? exist?

    def exist?(path)
      if $DEBUG
        puts "FileTest exists? #{path.gsub("\\", "/")}"
      end

      rgss_filetest_exist? path.gsub("\\", "/")
    end

    alias exists? exist?

  end
end