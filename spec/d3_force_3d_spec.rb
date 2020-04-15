require 'spec_helper'
require "json"

describe D3Force3d do
  let(:file) { File.open "spec/support/node_data.json" }
  let(:data) { JSON.load file }

  context ".force_simulation" do

    it "should return the simulation object" do
      simulation = D3Force3d.force_simulation(data["nodes"])
      expect(simulation.instance_of? D3Force3d::Simulation).to be_truthy
    end

    it "should has default value for numdimension to be 2 if not given" do
      simulation = D3Force3d.force_simulation(data["nodes"])
      expect(simulation.num_dimensions).to eq 2
    end

    it "should assign the given numdimension value" do
      simulation = D3Force3d.force_simulation(data["nodes"], 3)
      expect(simulation.num_dimensions).tO eq 3
    end

    it "should assign blank array to nodes if nodes is not given" do
      simulation = D3Force3d.force_simulation
      expect(simulation.nodes).to eq []
    end

    it "should assign blank array to nodes if nil is given in nodes" do
      simulation = D3Force3d.force_simulation(nil)
      expect(simulation.nodes).to eq []
    end
  end

  context ".force_links" do

    it "should return the link object" do
      link = D3Force3d.force_links(data)
      expect(link.instance_of? D3Force3d::Link).to be_truthy
    end

    it "should assign blank array to links if links is not given" do
      link = D3Force3d.force_links
      expect(link.links).to eq []
    end

    it "should assign blank array to links if nil is given in links" do
      link = D3Force3d.force_links(nil)
      expect(link.links).to eq []
    end
  end
end