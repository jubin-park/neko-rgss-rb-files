# The module that carries out music and sound processing.
module Audio
  @music = nil
  @@cache = {}
  
  class <<self

    # Prepares MIDI playback by DirectMusic.
    #
    # A method of the processing at startup in RGSS2 for enabling execution at any time.
    #
    # MIDI playback is possible without calling this method, but in Windows Vista or later, a delay of 1 to 2 seconds will result at playback.

    def setup_midi

    end

    # Starts BGM playback. Specifies the file name, volume, pitch, and playback starting position in that order.
    #
    # The playback starting position (RGSS3) is only valid for ogg or wav files.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.

    def bgm_play(filename, volume=100, pitch=100, pos=0)

      return if @bgm_name == filename

      bgm_stop

      print "bgm_play #{filename}\n"

      music = SDL::Mixer::Music.load(RGSS.get_file(filename)) rescue puts($!)
      #SDL::Mixer.playMusic(music, -1) rescue puts($!)

      @bgm_name = filename
    end

    # Stops BGM playback.

    def bgm_stop
      SDL::Mixer.haltMusic
      @bgm_name = nil
    end

    # Starts BGM fadeout. time is the length of the fadeout in milliseconds.

    def bgm_fade(time)
      SDL::Mixer.fadeOutMusic(time)
      @bgm_name = nil
    end

    # Gets the playback position of the BGM. Only valid for ogg or wav files. Returns 0 when not valid.

    def bgm_pos

    end

    # Starts BGS playback. Specifies the file name, volume, pitch, and playback starting position in that order.
    #
    # The playback starting position (RGSS3) is only valid for ogg or wav files.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.

    def bgs_play(filename, volume=100, pitch=100, pos=0)
      bgs_stop

      print "bgs_play #{filename}\n"

      @bgs_channel = SDL::Mixer.playChannel(-1, SDL::Mixer::Wave.load(RGSS.get_file(filename)), -1) rescue puts($!)
    end

    # Stops BGS playback.

    def bgs_stop

      SDL::Mixer.halt(@bgs_channel) if @bgs_channel
    end

    # Starts BGS fadeout. time is the length of the fadeout in milliseconds.

    def bgs_fade(time)
      SDL::Mixer.fadeOut(@bgs_channel, time) if @bgs_channel
    end

    # Gets the playback position of the BGS. Only valid for ogg or wav files. Returns 0 when not valid.

    def bgs_pos

    end

    # Starts ME playback. Sets the file name, volume, and pitch in turn.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.
    #
    # When ME is playing, the BGM will temporarily stop. The timing of when the BGM restarts is slightly different from RGSS1.

    def me_play(filename, volume=100, pitch=100)

      print "me_play #{filename}\n"

      wave = @@cache[filename] if @@cache.include?(filename)
      wave = SDL::Mixer::Wave.load(RGSS.get_file(filename))  rescue puts($!) if not wave
      @@cache[filename] = wave

      @me_channel = SDL::Mixer.playChannel(-1, wave, 0) rescue puts($!)
    end

    # Stops ME playback.

    def me_stop
      SDL::Mixer.halt(@me_channel) if @me_channel
    end

    # Starts ME fadeout. time is the length of the fadeout in milliseconds.

    def me_fade(time)
      SDL::Mixer.fadeOut(@me_channel, time) if @me_channel
    end

    # Starts SE playback. Sets the file name, volume, and pitch in turn.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.
    #
    # When attempting to play the same SE more than once in a very short period, they will automatically be filtered to prevent choppy playback

    def se_play(filename, volume=100, pitch=100)

      print "se_play #{filename}\n"

      wave = @@cache[filename] if @@cache.include?(filename)
      wave = SDL::Mixer::Wave.load(RGSS.get_file(filename))  rescue puts($!) if not wave
      @@cache[filename] = wave

      @se_channel = SDL::Mixer.playChannel(-1, wave, 0) rescue puts($!)
    end

    # Stops all SE playback.
    def se_stop
      SDL::Mixer.halt(@se_channel) if @me_channel
    end
  end
end