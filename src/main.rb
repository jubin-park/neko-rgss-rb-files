# encoding: utf-8


# ruby version
############################
$NEKO_RUBY = RUBY_VERSION.split('.')[0,3].join.to_i

if $NEKO_RUBY >= 190
#  Encoding.default_external = Encoding::UTF_8
#  Encoding.default_internal = Encoding::UTF_8
end

if RUBY_PLATFORM['mingw'] or RUBY_PLATFORM['mswin'] or RUBY_PLATFORM['darwin']
  if $NEKO_RUBY >= 190
    $LOAD_PATH.unshift '../ruby19/'
  else
    $LOAD_PATH.unshift '../ruby/'
  end

  $LOAD_PATH.unshift '../src/'
end

require 'zlib'
require 'inifile'
require 'mini_profiler'


# Global settings
############################
$DEBUG = false

# Check game is RPG2003
if File.exists? 'RPG_RT.ini'
  RGSS2003.run
  exit
end


# load config
############################
# $RGSS_CONFIG   = IniFile.load('Game.ini')['Game'] #how to detect charset?
f = File.open('Game.ini', 'r')
data = f.read
f.close
$RGSS_CONFIG = {
    'Library' => data.scan(/Library\s*\=\s*(.+)$/)[0][0].strip,
    'Scripts' => data.scan(/Scripts\s*\=\s*(.+)$/)[0][0].strip
}

$KCODE = 'u'

# set title
############################

#d etect RGSS version
$RGSS_VERSION = if index = ['.rxdata', '.rvdata' '.rvdata2'].index(File.extname($RGSS_CONFIG['Scripts']))
  index + 1
elsif $RGSS_CONFIG['Library'] and $RGSS_CONFIG['Library'] =~ /RGSS(\d)\d\d\w?\.dll/i
  $1.to_i
else
  puts "warning: can't detect rgss version"
  1
end

# load RGSS
require 'rgss'
require 'rgss/compatibility'
include RGSS
RGSS.title    = 'Game'#$RGSS_CONFIG['Title']

# load RPG module
case $RGSS_VERSION
when 1
  require 'rpg/rpgxp'
when 2
  require 'rpg/rpgvx'
when 3
  require 'rpg/rpgva'
end

# set screen size.
if $RGSS_VERSION == 1
  Graphics.resize_screen(640, 480)
else
  Graphics.resize_screen(544, 416)
end

#load RTP on all platform
# if $RGSS_VERSION == 1
#   [$RGSS_CONFIG['RTP1'], $RGSS_CONFIG['RTP2'], $RGSS_CONFIG['RTP3']].each do |rtp|
#     RGSS.load_path << ENV["RGSS_RTP_#{rtp}"]
#   end
# else
#   RGSS.load_path << ENV["RGSS#{$RGSS_VERSION}_RTP_#{$RGSS_CONFIG['RTP']}"]
# end
#
# #load RTP on windows
# if RUBY_PLATFORM['mingw'] or RUBY_PLATFORM['mswin']
#   ENV['AV_APPDATA'] = '.'
#   require 'win32/registry'
#   registry = Win32::Registry::HKEY_LOCAL_MACHINE
#   if $RGSS_VERSION == 1
#     registry.open('Software\Enterbrain\RGSS\RTP') do |reg|
#       [$RGSS_CONFIG['RTP1'], $RGSS_CONFIG['RTP2'], $RGSS_CONFIG['RTP3']].each do |rtp|
#         (RGSS.load_path << reg[rtp]) rescue puts $!
#       end
#     end
#   else
#     registry.open("Software\\Enterbrain\\RGSS#{$RGSS_VERSION}\\RTP") do |reg|
#       (RGSS.load_path << reg[$RGSS_CONFIG['RTP']]) rescue puts $!
#     end
#   end
# end

# Setup profiler
$profiler = MiniProfiler.new()

#
$i = 0
def save_script(filename, data)

  File.open("Scripts/" + filename.gsub(/\*/, '@star@').gsub(/\?/, '@quest@') \
              .gsub(/▼/, '@down@').gsub(/</, '@lefta@').gsub(/>/, '@righta@') \
              .gsub(/\//, '@slash@').gsub(/\|/, '@bar@') + ".rb", "wb") do |f|
#    File.open("Scripts/#{$i}.rb", "wb") do |f|
   f.write("# encoding: utf-8\n")
   f.write("# filename: #{filename}\n")
   f.write(data)
    end
end
#
def get_script(filename)
	File.open("Scripts/" + filename.gsub(/\*/, '@star@').gsub(/\?/, '@quest@').gsub(/▼/, '@down@') + ".rb", "rb") do |f|
    f.read()
	end
end

# Load need library
# TODO socket 들어가야함!
if $NEKO_RUBY < 190
  require 'socket'
end

require 'neko_real'

#run scripts
$RGSS_SCRIPTS = load_data $RGSS_CONFIG['Scripts'].gsub('\\', '/')
begin
if $RGSS_VERSION <= 2
  rgss_main { $RGSS_SCRIPTS.each { |script|
    #save_script(script[1], Zlib::Inflate.inflate(script[2]))
    eval Zlib::Inflate.inflate(script[2]).force_encoding('UTF-8'), TOPLEVEL_BINDING, script[1], 0
  }}
  #rgss_main { $RGSS_SCRIPTS.each { |script|
  #  #path = File.join(File.dirname(__FILE__), "../SampleGame/Scripts/#{script[1].gsub(/\*/, '@star@').gsub(/\?/, '@quest@')}.rb" )
  #  path = File.join(File.dirname(__FILE__), "../SampleGame/Scripts/#{$i}.rb" )
  #  eval "require '#{path}'"
  #  $i += 1
  #}}
else
  $i = 0
  $RGSS_SCRIPTS.each { |script|
    text = Zlib::Inflate.inflate(script[2]).force_encoding('UTF-8')
    eval "# encoding: utf-8\n#{text}", TOPLEVEL_BINDING, script[1], 0
  }
  #$RGSS_SCRIPTS.each { |script|
    #save_script($i.to_s, Zlib::Inflate.inflate(script[2]))
    #path = File.join(File.dirname(__FILE__), "../SampleGame/Scripts/#{script[1].gsub(/\*/, '@star@').gsub(/\?/, '@quest@')}.rb" )
    #filename = script[1].gsub(/\*/, '@star@').gsub(/\?/, '@quest@').gsub(/▼/, '@down@') + ".rb"
    #path = File.join(File.dirname(__FILE__), "../Game.va2/Scripts/#{$i}.rb" )
    #eval "require '#{path}'"
  #  $i += 1
  #}
end
rescue SystemExit

rescue Exception => exception
  if RUBY_PLATFORM['mingw'] or RUBY_PLATFORM['mswin']
    text = "#{$!.to_s}\n\n#{$!.backtrace.join("\n")}"
    msgbox text
  else
    text = "#{$!.to_s}\n\n#{$!.backtrace.join("\n")}"
    SDL.showAlert text
    puts text

    sleep 60000000
  end
end
