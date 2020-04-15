require 'spec_helper'
require "json"

describe D3Force3d::Link do
  let(:file) { File.open "spec/support/node_data.json" }
  let(:data) { JSON.load file }

  context ".force_links" do

    it "should return the link object" do
      link = D3Force3d::Link.force_links(data)
      expect(link.instance_of? D3Force3d::Link).to be_truthy
    end

    it "should assign blank array to links if links is not given" do
      link = D3Force3d::Link.force_links
      expect(link.links).to eq []
    end

    it "should assign blank array to links if nil is given in links" do
      link = D3Force3d::Link.force_links(nil)
      expect(link.links).to eq []
    end
  end

  context "#id" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should return the default id block if non given" do
      id = link.id
      expect(id.instance_of? Proc).to be_truthy
    end

    it "should assign the given block to id and return the link object" do
      data = {id: "Id Tested", index: "Index Tested"}
      id = link.id
      expect(id.call(data)).to eq("Index Tested")
      new_link = link.id{ |d| d[:id] || d["id"] }
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      id = link.id
      expect(id.call(data)).to eq("Id Tested")
    end
  end

  context "#iterations" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should return the default value of iterations which is 1 if non given" do
      iterations = link.iterations
      expect(iterations).to eq 1
    end

    it "should assign the given value of iterations and return the link object" do
      new_link = link.iterations(100)
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      iterations = link.iterations
      expect(iterations).to eq(100)
    end
  end

  context "#strength" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should return the default strength method if non given" do
      strength = link.strength
      expect(strength.kind_of? Method).to be_truthy
    end

    it "should assign the given block to strength and return the link object" do
      new_link = link.strength{|d| d * 10}
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      strength = link.strength
      expect(strength.instance_of? Proc).to be_truthy
      expect(strength.call(10)).to eq(100)
    end

    it "should assign a Proc to strength which return the given value if proc is not given and return the link object" do
      new_link = link.strength(50)
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      strength = link.strength
      expect(strength.instance_of? Proc).to be_truthy
      expect(strength.call).to eq(50)
    end
  end

  context "#distance" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should return the default distance block if non given" do
      distance = link.distance
      expect(distance.instance_of? Proc).to be_truthy
    end

    it "should assign the given block to distance and return the link object" do
      new_link = link.distance{|d| d * 10}
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      distance = link.distance
      expect(distance.instance_of? Proc).to be_truthy
      expect(distance.call(10)).to eq(100)
    end

    it "should assign a Proc to distance which return the given value if proc is not given and return the link object" do
      new_link = link.distance(50)
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      distance = link.distance
      expect(distance.instance_of? Proc).to be_truthy
      expect(distance.call).to eq(50)
    end
  end

  context "#links" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should return the links block if non given" do
      links = link.links
      expect(links).to eq(data)
    end

    it "should assign the given links to links and return the link object with links valid data" do
      link.id{ |d| d[:id] || d["id"] }
      link.intialize_force_with_nodes(data["nodes"], 3)
      new_link = link.links(data["links"])
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      links = link.links
      file1 = File.open("spec/support/link_result.json")
      data1 = JSON.load file1
      expect(links).to eq(data1["link_result"])
    end

    it "should assign the blank array to links if nil is given and return the link object" do
      new_link = link.links(nil)
      expect(new_link.instance_of? D3Force3d::Link).to be_truthy
      links = link.links
      expect(links).to eq([])
    end
  end

  context "#force" do
    let(:link) { D3Force3d::Link.force_links(data) }

    it "should calculate the force on each node" do
      link.id{ |d| d[:id] || d["id"] }
      link.intialize_force_with_nodes(data["nodes"], 3)
      link.links(data["links"])
      link.force(1.5)
      file1 = File.open("spec/support/link_result.json")
      data1 = JSON.load file1
      expect(link.links).to eq(data1["link_result"])
    end
  end
end