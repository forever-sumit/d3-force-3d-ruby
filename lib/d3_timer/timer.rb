module D3Timer
  class Timer
    @@frame = nil #is an animation frame pending?
    @@timeout = nil # is a timeout pending?
    @@interval = nil # are any timers active?
    @@pokeDelay = 1 #how frequently we check for clock skew , 1sec = 1000ms
    @@clockLast = nil
    @@clockNow = nil
    @@clockSkew = 0
    @@clock = Time
    @@taskTail = nil
    @@taskHead = nil

    attr_accessor :_call, :_time, :_next

    def initialize
      @_call = @_time = @_next = nil
    end

    def self.clear_now
      @@clockNow = nil
    end
    
    def self.now
      @@clockNow || @@clockNow = @@clock.now().to_i + @@clockSkew
    end

    def self.timer(delay = 0, time = now, &block)
      t = Timer.new
      t.restart(delay, time, &block)
      t
    end

    def self.timer_flush
      self.now
      @@frame = @@frame.to_i + 1 #Pretend we’ve set an alarm, if we haven’t already.
      t = @@taskHead
      while (t)
        @_call.call(null, e) if ((e = @@clockNow.to_i - t._time) >= 0)
        t = t._next
      end
      @@frame = nil
    end

    def restart(delay, time, &block)
      time = time + delay
      if (!@_next && @@taskTail != self)
        if (@@taskTail)
          @@taskTail._next = self 
        else
          @@taskHead = self
          @@taskTail = self
        end
      end
      @_call = block
      @_time = time
      timer_sleep
    end

    def stop
      if (@_call)
        @_call = nil
        @_time = Float::INFINITY
        timer_sleep
      end
    end

    private

    def set_timeout(delay = 0.017, &block)
      thread = Thread.new do
        sleep delay.to_i
        yield
      end
      thread.join
      thread
    end

    def clear_timeout(thread)
      Thread.kill(thread)
    end

    def set_interval(time_interval, &block)
      thread = Thread.new do
        loop do
          sleep time_interval.to_i
          yield
        end
      end
      thread.join
      thread
    end

    def clear_interval(thread)
      clear_timeout(thread)
    end

    def wake
      @@clockNow = (@@clockLast = @@clock.now().to_i) + @@clockSkew
      @@frame = @@timeout = nil
      begin
        self.class.timerFlush
      rescue
        #handle the error here
      ensure
        @@frame = nil
        nap
        @@clockNow = nil
      end
    end

    def poke
      now = @@clock.now().to_i
      delay = now - @@clockLast
      if (delay > @@pokeDelay)
        @@clockSkew -= delay
        @@lockLast = now
      end
    end

    def nap
      t1 = @@taskHead
      t0 = t2 = nil
      time = Float::INFINITY
      while (t1)
        if (t1._call)
          time = t1._time if (time > t1._time)
          t0 = t1
          t1 = t1._next
        else
          t2 = t1._next
          t1._next = nil
          t1 = t0 ? t0._next = t2 : @@taskHead = t2
        end
      end
      @@taskTail = t0
      timer_sleep(time)
    end

    def timer_sleep(time = 0)
      return if @@frame
      @@timeout = clear_timeout(@@timeout) if (@@timeout)
      delay = time - @@clockNow; # Strictly less than if we recomputed clockNow.
      if (delay > 24)
        @@timeout = set_timeout(time - @@clock.now().to_i - @@clockSkew){ wake } if (time < Float::INFINITY)
        @@interval = clear_interval(@@interval) if (@@interval)
      else
        if (!@@interval)
          @@clockLast = @@clock.now().to_i
          @@interval = set_interval(@@pokeDelay){ temp_test }
        else
          @@frame = 1
          set_timeout{ wake }
        end
      end
    end

    def temp_test #Need to change the name, right noe it is for testing purpose
      poke
      @@frame = 1
      set_timeout{ wake }
    end
  end
end
