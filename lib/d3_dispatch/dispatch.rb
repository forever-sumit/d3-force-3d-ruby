module D3Dispatch
  class Dispatch

    attr_accessor :_

    @@noop = {value: Proc.new { Hash.new } }

    def initialize(_)
      @_ = _
    end

    def self.dispatch(*args)
      i = 0
      n = args.length
      _ = {}
      t = nil
      loop do
        break if i >= n
        raise ("illegal type: #{t}") if ((t = args[i].to_s).empty? || (_.include?(t)) || /[\s.]/.match?(t))
        _[t] = []
        i += 1
      end
      Dispatch.new(_)
    end

    def on(typename, *args ,&block)
      _ = self._
      types_array = parse_typenames(typename.to_s, _)
      t = nil
      i = -1
      n = types_array.length
      # If no callback was specified, return the callback of the given type and name.
      if (args.empty? && !block_given?)
        while ((i += 1) < n)
          return t if ((t = (typename = types_array[i])[:type]) && (t = get(_[t], typename[:name])))
        end
      end
      #If a type was specified, set the callback for the given type and name.
      #Otherwise, if a null callback was specified, remove callbacks of the given name. 
      raise ("invalid callback: #{args[0]} ") if (!block_given? && !args.empty? && !args[0].nil?)
      while ((i += 1) < n)
        if((t = (typename = types_array[i])[:type]) && block_given?)
          self._[t] = set(_[t], typename[:name], &block)
        elsif(!args.empty? && args[0].nil?)
          type = typename[:type]
          # _.each do |key, value|
            self._[type] = set(self._[type], typename[:name])
          # end
        end
      end
      self
    end

    def copy
      copy = {}
      _ = self._
      _.each do |key, value|
        copy[key] = value.dup
      end
      Dispatch.new(copy)
    end

    def call(type, that = nil, *args)
      apply(type, that, *args)
    end

    def apply(type, that = nil, *args)
      raise ("unknown type: #{type}") if (!self._.include?(type))
      t = self._[type]
      i = 0
      n = t.length
      while(i < n)
        t[i][:value].call(that, args)
        i += 1
      end
    end

    private

    def parse_typenames(typenames, types)
      typenames.strip.split(/^|\s+/).map do |t|
        name = ""
        i = t.index(".")
        if (i && i >= 0)
          name = t.slice(i + 1, t.length - 1)
          t = t.slice(0, i)
        end
        raise ("unknown type: #{t}") if (t.empty? || !types.include?(t))
        {type: t, name: name}
      end
    end

    def get(type, name)
      i = 0
      n = type.nil? ? 0 : type.length
      c = nil
      loop do
        break if i >= n
        if ((c = type[i])[:name] === name)
          break
        end
        i += 1
      end
      c.nil? ? c : c[:value]
    end

    def set(type, name, &block)
      i = 0
      n = type.length
      loop do
        break if i >= n
        if(type[i][:name] === name)
          type[i] = @@noop
          type = type.slice(0, i).concat(type.slice(i + 1, type.length - 1))
          break
        end
        i += 1
      end
      type.push({name: name, value: block}) if (block_given?) 
      type
    end
  end  
end