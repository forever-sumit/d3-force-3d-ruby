require "d3_force_3d/version"
require "d3_force_3d/simulation"

module D3Force3d

  def self.force_simulation(nodes, numDimensions)
    D3Force3d::Simulation.force_simulation(nodes, numDimensions)
  end

  def self.force_link

  end
  class Error < StandardError; end
  
end
