module D3Timer
  class Timer
    @@frame = nil #is an animation frame pending?
    @@timeout = nil # is a timeout pending?
    @@interval = nil # are any timers active?
    @@pokeDelay = 1000 #how frequently we check for clock skew
    @@clockLast = nil
    @@clockNow = nil
    @@clockSkew = 0
    @@clock = Time

    attr_accessor :_call, :_time, :_next

    def initialize
      @_call = @_time = @_next = nil
    end

    def self.clear_now
      @@clockNow = nil
    end
    
    def self.now
      @@clockNow || (
        set_timeout(17){ clear_now }
        @@clockNow = @@clock.now().to_i + @@clockSkew
      )
    end

    def self.timer(delay = 0, time = now, &block)
      t = new Timer
      t.restart(delay, time, &block)
      t
    end

    def self.timer_flush() {
      self.now
      # @@frame = @@frame.to_i + 1 #Pretend we’ve set an alarm, if we haven’t already.
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
      sleep
    end

    def stop
      if (@_call)
        @_call = nil
        @_time = Float::INFINITY
        sleep
      end
    end
    
    def set_timeout(delay, &block)

    end
    private

    def wake
      @@clockNow = (@@clockLast = @@clock.now().to_i) + @@clockSkew
      @@frame = @@timeout = nil
      begin
        timerFlush
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
      sleep(time)
    end

    def sleep(time = 0) {
      if (!@@frame)
        @@timeout = clearTimeout(@@timeout) if (@@timeout)
        delay = time - @@clockNow; # Strictly less than if we recomputed clockNow.
        if (delay > 24)
          @@timeout = setTimeout(wake, time - @@clock.now().to_i - @@clockSkew) if (time < Float::INFINITY)
          @@interval = clearInterval(interval) if (@@interval) 
        else
          if (!@@interval)
            @@clockLast = @@clock.now().to_i
            @@interval = setInterval(poke, @@pokeDelay);
          end
          @@frame = 1
          set_timeout(17){ wake }
        end
      end
    end
  end
end
