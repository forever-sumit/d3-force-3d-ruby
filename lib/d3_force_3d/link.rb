require 'pry'
require "d3_force_3d/jiggle"

module D3Force3d

  include D3Force3d::Jiggle 

  class Link
    def self.index(d = {})
      d[:index]
    end
    
    def find(nodeById, nodeId)
      node = nodeById[nodeId]
      raise ("node not found: " + nodeId) if (!node) 
      node
    end

    def self.constant(x)
      Proc.new { x }
    end

    def self.force_links(links = nil)
      @@id = method(:index)
      @@strength = method(:default_strength)
      # binding.pry
      @@distance = constant(30)
      @@iterations = 1
      @@count = []
      @@links = links.nil? ? [] : links
      # method(:force)
      Link.new(nil, nil)
    end

    def self.default_strength(link)
      1 / Math.min(@@count[link[:source][:index]], @@count[link[:target][:index]])
    end

    def self.force(alpha)
      k = 0
      n = @@links.length
      loop do
        break if k >= iterations
        i = x = y = z = 0
        loop do
          break if i >= n
          link = links[i]
          source = link[:source]
          target = link[:target]
          y = target[:y] + target[:vy] - source[:y] - source[:vy] || jiggle if (@@nDim > 1)
          z = target[:z] + target[:vz] - source[:z] - source[:vz] || jiggle if (@@nDim > 2)
          l = Math.sqrt(x * x + y * y + z * z)
          l = (l - @@distances[i]) / l * alpha * @@strengths[i];
          x *= l
          y *= l
          z *= l
          target[:vx] -= x * (b = @@bias[i])
          target[:vy] -= y * b if @@nDim > 1
          target[:vz] -= z * b if @@nDim > 2
          source[:vx] += x * (b = 1 - b)
          source[:vy] += y * b if @@nDim > 1
          source[:vz] += z * b if @@nDim > 2
          i += 1
        end
        k += 1
      end
    end
    
    def self.initialize
      return if (!@@nodes)
      n = @@nodes.length
      m = @@links.length
      nodeById = nodes.map{|d, i| [@@id.call(d), d]}
      i = 0
      @@count = Array.new(n)
      loop do
        break if i >= m
        link = @@links[i]
        link[:index] = i
        link[:source] = find(nodeById, link[:source]) if (!(link[:source].kind_of? Hash)) 
        link[:target] = find(nodeById, link[:target]) if (!(link[:target].kind_of? Hash))
        @@count[link[:source][:index]] = (@@count[link[:source][:index]] || 0) + 1
        @@count[link[:target][:index]] = (@@count[link[:target][:index]] || 0) + 1
        i += 1
      end
      i = 0
      @@bias = Array.new(m)
      loop do
        break if i >= m
        link = @@links[i]
        @@bias[i] = @@count[link[:source][:index]] / (@@count[link[:source][:index]] + @@count[link[:target][:index]])
        i += 1
      end
      @@strengths = Array.new(m)
      initialize_strength
      @@distances = Array.new(m)
      initialize_distance
    end

    def initialize_strength
      return if (!@@nodes)
      i = 0
      n = @@links.length
      loop do
        break if i >= n
        @@strengths[i] = @@strength.call(@@links[i])
        i += 1
      end
    end

    def initialize_distance
      return if (!@@nodes)
      i = 0
      n = @@links.length
      loop do
        break if i >= n
        @@distances[i] = @@distance.call(@@links[i])
        i += 1
      end
    end

    def initialize(initNodes, numDimensions)
      @@nodes = initNodes
      @@nDim = numDimensions
      self.class.initialize
    end

    def links(*args)
      if args.length > 0
        @@links = args[0]
        self.class.initialize
        force
      else
        binding.pry
        @@links
      end
    end

    def id(*args)
      if args.length > 0
        @@id = args[0]
        force
      else
        @@id
      end
    end

    def iterations(*args)
      if args.length > 0
        @@iterations = args[0]
        force
      else
        @@iterations
      end
    end

    def strength(*args)
      if args.length > 0
        @@strength = args[0].kind_of? Method ? args[0] : self.class.constant(args[0])
        initialize_strength
        force
      else
        @@strength
      end
    end
  
    def distance(*args)
      if args.length > 0
        @@distance = args[0].kind_of? Method ? args[0] : self.class.constant(args[0])
        initialize_distance
        force
      else
        @@distance
      end
    end
  end
end