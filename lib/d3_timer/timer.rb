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

    def self.now
      @@clockNow || @@clockNow = (@@clock.now().to_f * 1000).to_i + @@clockSkew
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
        e = @@clockNow.to_i - t._time
        if e >= 0
          t._call.call(e)
          t = t._next
        end
      end
      @@frame = nil
    end

    def restart(delay = 0, time = self.class.now, &block)
      raise TypeError.new "callback is not given or callback is not a block" if !block_given?
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
        @@frame = nil
        timer_sleep(@_time)
      end
    end

    private

    def set_timeout(delay = 0.017, &block)
      @@timeout = Thread.new do
        sleep delay
        yield
      end
    end

    def clear_timeout(thread)
      Thread.kill(thread)
      nil
    end

    def set_interval(time_interval, &block)
      @@interval = Thread.new do
        loop do
          sleep time_interval
          yield
        end
      end
    end

    def clear_interval(thread)
      clear_timeout(thread)
    end

    def wake
      @@clockNow = (@@clockLast = (@@clock.now().to_f * 1000).to_i) + @@clockSkew
      @@frame = @@timeout = nil
      begin
        self.class.timer_flush
      rescue
        #handle the error here
      ensure
        @@frame = nil
        nap
        @@clockNow = nil
      end
    end

    def poke
      now = (@@clock.now().to_f * 1000).to_i
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
          time = t1._time if time > t1._time
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
      @@timeout = clear_timeout(@@timeout) if @@timeout
      delay = time - @@clockNow.to_i; # Strictly less than if we recomputed clockNow.
      if (delay > 24)
        set_timeout(time - (@@clock.now().to_f * 1000).to_i - @@clockSkew){ wake } if time < Float::INFINITY
        @@timeout.join if @@timeout
        @@interval = clear_interval(@@interval) if @@interval
      else
        if (!@@interval)
          @@clockLast = (@@clock.now().to_f * 1000).to_i
          call_interval_and_timeout
          @@interval.join
          @@timeout.join if @@timeout
        else
          @@frame = 1
          set_timeout{ wake }
          @@timeout.join
        end
      end
    end

    def call_interval_and_timeout
      set_interval(@@pokeDelay){ poke }
      @@frame = 1
      set_timeout{ wake }
    end

    def clear_now
      @@clockNow = nil
    end
  end
end
