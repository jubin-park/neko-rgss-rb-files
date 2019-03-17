class MiniProfiler

  def initialize
    clear
    @show_time = Time.new
  end

  def clear
    @begin_time = Time.new
    @times = []
    @frame_count = 0
  end

  def step(id)
    dt = Time.new - @begin_time
    @begin_time = Time.new

    found = false
    for v in @times
      if v[0] == id
        found = true
        v[1] += dt
      end
    end

    @times << [id, dt] unless found
  end

  def show
    @frame_count += 1
    if Time.new - @show_time < 1.0
      return
    end

    if $DEBUG
      puts ' Profiler ---- '
      sum = 0
      for v in @times.each
        print " ##{v[0]} : #{(v[1]/@frame_count*1000.0).to_i}ms\n"
        sum += v[1]
      end

      total = (sum/@frame_count*1000.0).to_i
      print " Total : #{total}ms\n"
    end

    clear
    @show_time = Time.new
  end

end