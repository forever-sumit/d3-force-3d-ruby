require 'spec_helper'

describe D3Timer::Timer do
  let!(:timer){ D3Timer::Timer }
  let(:t) { D3Timer::Timer.new }

  context("#restart") do
    it("should raise error if callback is not block") do
      expect{ t.restart }.to raise_error(TypeError, /callback is not given or callback is not a block/)
    end


    it("should implicitly uses zero delay and the current time if not given") do
      _elapsed = 0
      callback = Proc.new do |elapsed|
        _elapsed = elapsed
        t.stop
      end
      t.restart(&callback)
      expect(_elapsed).to be_between(17 - 5, 17 + 5)
    end

    it("should invokes the callback about every 1s") do
      _then = timer.now
      count = 0
      callback = Proc.new do
        count += 1
        t.stop
      end
      t.restart(&callback)
      expect(timer.now - _then).to be_between((17 - 5) * count, (17 + 5) * count)
    end

    it("should invokes the callback until the timer is stopped") do
      count = 0
      callback = Proc.new do
        count += 1
        if count > 2
          t.stop
        end
      end
      t.restart(&callback)
    end

    it("should passes the callback the elapsed time") do
      _then = timer.now
      _elapsed = 0
      callback = Proc.new do |elapsed|
        _elapsed = elapsed
        t.stop
      end
      t.restart(&callback)
      result = timer.now - _then
      expect(timer.now - _then).to be_between(result - 2, result + 2)
    end

    it("should invokes the callback after the specified delay") do
      delay = 10
      _then = timer.now
      callback = Proc.new do
        t.stop
      end
      t.restart(delay, &callback)
      expect(timer.now - _then).to be_between(delay - 10, delay + 10)
    end

    it("should computes the elapsed time relative to the delay") do
      delay = 10
      _elapsed = 0
      callback = Proc.new do |elapsed|
        _elapsed = elapsed
        t.stop
      end
      t.restart(delay, &callback)
      expect(_elapsed).to be_between(0,10)
    end

    it("should invokes callbacks in scheduling order during synchronous flush") do
      results = []
      t.restart{ results.push(1) && t.stop }
      t1 = timer.new 
      t1.restart{ results.push(2) && t1.stop }
      t2 = timer.new
      t2.restart{ results.push(3) && t2.stop }
      timer.timer_flush
      expect(results).to eq([1, 2, 3])
    end
  end
  
  context("#stop") do
    it("should immediately stops the timer") do
      count = 0
      t.restart do
        count += 1
        t.stop
      end
      expect(count).to eq(1)
    end
  end

  context(".now") do
    it("should returns a old clockNow time") do
      time = timer.now
      sleep 2
      expect(timer.now).to eq(time)
    end
  end

  context(".initialize") do
    it("should initialize object with correct data") do
      expect(t._call).to eq(nil)
      expect(t._time).to eq(nil)
      expect(t._next).to eq(nil)
    end
  end

  context(".timer_flush") do
    it("should immediately invokes any eligible timers") do
      count = 0
      callback = Proc.new do
        count += 1 
        t.stop
      end
      t.restart(&callback)
      timer.timer_flush
      timer.timer_flush
      expect(count).to eq(1)
    end

    it("within timerFlush() still executes all eligible timers") do
      count = 0
      callback = Proc.new do
        count += 1 
        if (count >= 3) 
          t.stop
          timer.timerFlush
        end
      end
      t.restart(&callback)
      timer.timer_flush
      expect(count).to eq(3)
    end
  end
end