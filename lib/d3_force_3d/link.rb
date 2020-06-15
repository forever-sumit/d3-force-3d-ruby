require "d3_force_3d/jiggle"

module D3Force3d
  class Link

    include D3Force3d::Jiggle 

    def initialize(links = [], initNodes = nil, numDimensions = nil)
      @links = links.nil? ? [] : links
      @nodes = initNodes
      @nDim = numDimensions
      @id = Proc.new{|d| d[:id] || d["id"] || d[:url] || d["url"] || d[:index] || d["index"]   }
      @strength = method(:default_strength)
      @distance = constant(30)
      @iterations = 1
      @count = []
      initialize_link_force
    end

    def intialize_force_with_nodes(initNodes, numDimensions)
      @nodes = initNodes
      @nDim = numDimensions
      initialize_link_force
    end

    def self.force_links(links = [])
      Link.new(links)
    end

    def force(alpha)
      k = 0
      n = @links["links"].length
      loop do
        break if k >= iterations
        i = x = y = z = 0
        loop do
          break if i >= n
          link = @links["links"][i]
          if link
            source = link["source"]
            target = link["target"]
            if target["y"] && target["vy"] && source["y"] && source["vy"]
              y = target["y"] + target["vy"] - source["y"] - source["vy"] || jiggle if (@nDim > 1)
            end
            if target["z"] && target["vz"] && source["z"] && source["vz"]
              z = target["z"] + target["vz"] - source["z"] - source["vz"] || jiggle if (@nDim > 2)
            end
            l = Math.sqrt(x * x + y * y + z * z)
            l = (l - @distances[i]) / l * alpha * @strengths[i].to_i
            x *= l
            y *= l
            z *= l
            target["vx"] -= x * (b = @bias[i]) if target["vx"]
            target["vy"] -= y * b if target["vy"] && @nDim > 1
            target["vz"] -= z * b if target["vz"] && @nDim > 2
            source["vx"] += x * (b = 1 - b) if source["vx"]
            source["vy"] += y * b if source["vy"] && @nDim > 1
            source["vz"] += z * b if source["vz"] && @nDim > 2
            target["vx"]=0 if (target["vx"].abs)<0.0001
            target["vy"]=0 if (target["vy"].abs)<0.0001 && @nDim > 1
            target["vz"]=0 if (target["vz"].abs)<0.0001 && @nDim > 2
            source["vx"]=0 if (source["vx"].abs)<0.0001
            source["vy"]=0 if (source["vy"].abs)<0.0001 && @nDim > 1
            source["vz"]=0 if (source["vz"].abs)<0.0001 && @nDim > 2
          end
          i += 1
        end
        k += 1
      end
    end

    def links(*args)
      if args.length > 0
        @links = args[0].nil? ? [] : args[0]
        initialize_link_force
        self
      else
        @links
      end
    end

    def id(&block)
      if block_given?
        @id = block
        self
      else
        @id
      end
    end

    def iterations(*args)
      if args.length > 0
        @iterations = args[0].to_i
        self
      else
        @iterations
      end
    end

    def strength(*args, &block)
      if args.length > 0 || block_given? 
        @strength = check_for_block_and_method_given(*args, &block)
        initialize_strength
        self
      else
        @strength
      end
    end
  
    def distance(*args, &block)
      if args.length > 0 || block_given?
        @distance = check_for_block_and_method_given(*args, &block)
        initialize_distance
        self
      else
        @distance
      end
    end

    private

    def check_for_block_and_method_given(*args, &block)
      if block_given?
        block
      else
        constant(args[0].to_i)
      end
    end
    
    def find(nodeById, nodeId)
      node = nodeById[nodeId]
      raise ("node not found: " + nodeId) if (!node)
      node
    end

    def constant(x)
      Proc.new{ x }
    end
        
    def initialize_link_force
      return if (!@nodes)
      n = @nodes.length
      m = @links["links"].length
      nodeById = {}
      @nodes.each do |d|
        d.transform_keys!(&:to_s)
        nodeById[@id.call(d)] = d
      end
      i = 0
      @count = Array.new(n)
      loop do
        break if i >= m
        link = @links["links"][i]
        if link
          link.transform_keys!(&:to_s)
          link["index"] = i
          link["source"] = find(nodeById, link["source"]) if (link["source"] && !link["source"].kind_of?(Hash)) 
          link["target"] = find(nodeById, link["target"]) if (link["target"] && !link["target"].kind_of?(Hash))
          @count[link["source"]["index"]] = (@count[link["source"]["index"]] || 0) + 1 if link["source"] && link["source"]["index"]
          @count[link["target"]["index"]] = (@count[link["target"]["index"]] || 0) + 1 if link["target"] && link["target"]["index"]
        end
        i += 1
      end
      i = 0
      @bias = Array.new(m)
      loop do
        break if i >= m
        link = @links["links"][i]
        if link && link["source"] && link["target"] && link["source"]["index"] && link["target"]["index"]
          @bias[i] = @count[link["source"]["index"]] / (@count[link["source"]["index"]] + @count[link["target"]["index"]])
        end
        i += 1
      end
      @strengths = Array.new(m)
      initialize_strength
      @distances = Array.new(m)
      initialize_distance
    end

    def initialize_strength
      return if (!@nodes)
      i = 0
      n = @links["links"].length
      loop do
        break if i >= n
        @strengths[i] = @strength.call(@links["links"][i])
        i += 1
      end
    end

    def initialize_distance
      return if (!@nodes)
      i = 0
      n = @links["links"].length
      loop do
        break if i >= n
        @distances[i] = @distance.call(@links["links"][i])
        i += 1
      end
    end

    def default_strength(link)
      if link && link["source"] && link["target"] && link["value"]
        # 1 / Math.min(@count[link["source"]["index"]], @count[link["target"]["index"]])
        link["value"].to_f
      end
    end
  end
end