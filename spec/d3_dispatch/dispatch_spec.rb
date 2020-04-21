require 'spec_helper'

describe D3Dispatch::Dispatch do
  let!(:dispatch){ D3Dispatch::Dispatch }

  context(".dispatch") do
    it("should returns a dispatch object with the specified types") do
      d = dispatch.dispatch("foo", "bar")
      expect(d.instance_of? dispatch).to be_truthy
    end

    it("should not throw an error if a specified type name collides with a dispatch method") do
      d = dispatch.dispatch("on")
      expect(d.instance_of? dispatch).to be_truthy
    end

    it("should throws an error if a specified type name is illegal") do
      expect{ dispatch.dispatch("") }.to raise_error(RuntimeError, /illegal type:/)
      expect{ dispatch.dispatch("foo bar") }.to raise_error(RuntimeError, /illegal type:/)
      expect{ dispatch.dispatch("foo\tbar") }.to raise_error(RuntimeError, /illegal type:/)
    end

    it("should throws an error if a specified type name is a duplicate") do
      expect{ dispatch.dispatch("foo", "foo") }.to raise_error(RuntimeError, /illegal type:/)
    end

    it("should throws an error if a specified type name is a duplicate") do
      expect{ dispatch.dispatch("foo", "foo") }.to raise_error(RuntimeError, /illegal type:/)
    end
  end

  context("#call") do
    it("should invokes callbacks of the specified type") do
      foo = 0
      bar = 0
      d = dispatch.dispatch("foo", "bar")
      d.on("foo"){ foo += 1 }
      d.on("bar"){ bar += 1 }
      d.call("foo");
      expect(foo).to eq(1)
      expect(bar).to eq(0)
      d.call("foo");
      d.call("bar");
      expect(foo).to eq(2)
      expect(bar).to eq(1)
    end

    it("should invokes callbacks with specified arguments and context") do
      results = []
      foo = {}
      bar = {}
      d = dispatch.dispatch("foo").on("foo"){ |this, args| results.push({this: this, arguments: args}) }
      d.call("foo", foo, bar);
      expect(results).to eq([{this: foo, arguments: [bar]}])
      d.call("foo", bar, foo, 42, "baz");
      expect(results).to eq([{this: foo, arguments: [bar]}, {this: bar, arguments: [foo, 42, "baz"]}])
    end

    it("should invokes callbacks in the order they were added") do
      results = []
      d = dispatch.dispatch("foo");
      d.on("foo.a"){ results.push("A") }
      d.on("foo.b"){ results.push("B") }
      d.call("foo")
      d.on("foo.c"){ results.push("C") }
      d.on("foo.a"){ results.push("A") }
      d.call("foo")
      expect(results).to eq(["A", "B", "B", "C", "A"])
    end

    it("should returns nil") do
      d = dispatch.dispatch("foo")
      expect(d.call("foo")).to eq nil
    end
  end
  context("#apply") do
    it("should invokes callbacks of the specified type") do
      foo = 0
      bar = 0
      d = dispatch.dispatch("foo", "bar")
      d.on("foo"){ foo += 1 }
      d.on("bar"){ bar += 1 }
      d.apply("foo");
      expect(foo).to eq(1)
      expect(bar).to eq(0)
      d.apply("foo");
      d.apply("bar");
      expect(foo).to eq(2)
      expect(bar).to eq(1)
    end

    it("should invokes callbacks with specified arguments and context") do
      results = []
      foo = {}
      bar = {}
      d = dispatch.dispatch("foo").on("foo"){ |this, args| results.push({this: this, arguments: args}) }
      d.apply("foo", foo, bar);
      expect(results).to eq([{this: foo, arguments: [bar]}])
      d.apply("foo", bar, foo, 42, "baz");
      expect(results).to eq([{this: foo, arguments: [bar]}, {this: bar, arguments: [foo, 42, "baz"]}])
    end

    it("should invokes callbacks in the order they were added") do
      results = []
      d = dispatch.dispatch("foo");
      d.on("foo.a"){ results.push("A") }
      d.on("foo.b"){ results.push("B") }
      d.apply("foo")
      d.on("foo.c"){ results.push("C") }
      d.on("foo.a"){ results.push("A") }
      d.apply("foo")
      expect(results).to eq(["A", "B", "B", "C", "A"])
    end

    it("should returns nil") do
      d = dispatch.dispatch("foo")
      expect(d.apply("foo")).to eq nil
    end
  end

  context("#on") do
    it("should returns the dispatch object") do
      d = dispatch.dispatch("foo")
      result = d.on("foo"){}
      expect(result.instance_of? dispatch).to be_truthy
    end

    it("should returns the dispatch object") do
      d = dispatch.dispatch("foo")
      result = d.on("foo"){}
      expect(result.instance_of? dispatch).to be_truthy
    end

    it("on(type., …) is equivalent to on(type, …)") do
      d = dispatch.dispatch("foo")
      foos = 0
      d.on("foo."){ foos +=1 }
      d.call("foo")
      expect(foos).to eq(1)
    end

    it("on(type, nil) should removes an existing callback, if present and if nil is passed in place of callback") do
      foo = 0
      d = dispatch.dispatch("foo", "bar")
      d.on("foo"){ foo += 1 }
      d.call("foo")
      expect(foo).to eq(1)
      d.on("foo", nil)
      d.call("foo")
      expect(foo).to eq(1)
    end

    it("on(type, nil) removing a missing callback has no effect") do
      a = 0
      d = dispatch.dispatch("foo")
      d.on("foo"){ a += 1 }
      d.on("foo", nil).on("foo", nil)
      d.call("foo")
      expect(a).to eq 0
    end

    it("on(type, nil) during a callback does not invoke the old callback") do
      b = 0
      d = dispatch.dispatch("foo")
      d.on("foo.A"){ d.on("foo.B", nil) }
      d.on("foo.B"){ b += 1 }
      d.call("foo")
      expect(b).to eq(0)
    end

    it("on(type, nil) coerces type to a string") do
      expected_result = Proc.new{ "test" }
      d = dispatch.dispatch(1)
      d.on(1, &expected_result)
      expect(d.on(1)).to eq(expected_result) 
    end

    it("should adds a callback for both types") do
      foos = 0
      proc = Proc.new{ foos += 1 }
      d = dispatch.dispatch("foo", "bar").on("foo bar", &proc);
      expect(d.on("foo")).to eq(proc)
      expect(d.on("bar")).to eq(proc)
      d.call("foo")
      expect(foos).to eq(1)
      d.call("bar")
      expect(foos).to eq(2)
    end

    it("should adds a callback for both typenames") do
      foos = 0
      proc = Proc.new{ foos += 1 }
      d = dispatch.dispatch("foo").on("foo.one foo.two", &proc);
      expect(d.on("foo.one")).to eq(proc)
      expect(d.on("foo.two")).to eq(proc)
      d.call("foo")
      expect(foos).to eq(2)
    end

    it("should returns the callback for either type") do
      proc = Proc.new{ "test" }
      d = dispatch.dispatch("foo", "bar")
      d.on("foo", &proc)
      expect(d.on("foo bar")).to eq(proc)
      expect(d.on("bar foo")).to eq(proc)
      d.on("foo", nil).on("bar", &proc)
      expect(d.on("foo bar")).to eq(proc)
      expect(d.on("bar foo")).to eq(proc)
    end

    it("should throws an error if callback is not a block") do
      d = dispatch.dispatch("foo")
      expect{ d.on("foo", 42) }.to raise_error(RuntimeError, /invalid callback:/)
    end

    it("on(type, f) throws an error if the type is unknown") do
      proc = Proc.new{ "error" }
      d = dispatch.dispatch("foo")
      expect{ d.on("bar", &proc) }.to raise_error(RuntimeError, /unknown type:/)
    end

    it("on(type) should throws an error if the type is unknown") do
      d = dispatch.dispatch("foo")
      expect{ d.on("bar") }.to raise_error(RuntimeError, /unknown type:/)
    end

    it("on(.name) should throws an error if the type is unknown") do
      d = dispatch.dispatch("foo").on("foo.a"){}
      expect{ d.on(".a") }.to raise_error(RuntimeError, /unknown type:/)
    end
  end

  context("#copy") do
    it("should returns an isolated copy") do
      foo = Proc.new{}
      bar = Proc.new{}
      d0 = dispatch.dispatch("foo", "bar").on("foo", &foo).on("bar", &bar)
      d1 = d0.copy
      expect(d1.on("foo")).to eq(foo)
      expect(d1.on("bar")).to eq(bar)
    
      # Changes to d1 don’t affect d0.
      expect(d1.on("bar", nil)).to eq(d1)
      expect(d1.on("bar")).to eq(d1)
      expect(d0.on("bar")).to eq(bar)
    
      # Changes to d0 don’t affect d1.
      expect(d0.on("foo", nil)).to eq(d0)
      expect(d0.on("foo")).to eq(d0)
      expect(d1.on("foo")).to eq(foo)
    end
  end
end