require 'spec_helper'
require "json"

describe D3Force3d::Simulation do
  let(:file) { File.open "spec/support/node_data.json" }
  let(:data) { JSON.load file }

  context ".force_simulation" do

    it "should return the simulation object" do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"])
      expect(simulation.instance_of? D3Force3d::Simulation).to be_truthy
    end

    it "should has default value for numdimension to be 2 if not given" do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"])
      expect(simulation.num_dimensions).to eq 2
    end

    it "should assign the given numdimension value" do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"], 3)
      expect(simulation.num_dimensions).to eq 3
    end

    it "should assign numDimension value maximum to 3 " do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"], 5)
      expect(simulation.num_dimensions).to eq 3
    end

    it "should assign numDimension value by rounding of given 2.2 to 2" do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"], 2.2)
      expect(simulation.num_dimensions).to eq 2
    end

    it "should assign blank array to nodes if nodes is not given" do
      simulation = D3Force3d::Simulation.force_simulation
      expect(simulation.nodes).to eq []
    end

    it "should assign blank array to nodes if nil is given in nodes" do
      simulation = D3Force3d::Simulation.force_simulation(nil)
      expect(simulation.nodes).to eq []
    end
    
    it "should intialize simulation object with valid data" do
      simulation = D3Force3d::Simulation.force_simulation(data["nodes"], 3)
      nDim = simulation.instance_variable_get(:@nDim)
      nodes = simulation.instance_variable_get(:@nodes)
      initialRadius = simulation.instance_variable_get(:@initialRadius)
      initialAngleRoll = simulation.instance_variable_get(:@initialAngleRoll)
      initialAngleYaw = simulation.instance_variable_get(:@initialAngleYaw)
      alpha = simulation.instance_variable_get(:@alpha)
      alphaMin = simulation.instance_variable_get(:@alphaMin)
      alphaDecay = simulation.instance_variable_get(:@alphaDecay)
      alphaTarget = simulation.instance_variable_get(:@alphaTarget)
      velocityDecay = simulation.instance_variable_get(:@velocityDecay)
      forces = simulation.instance_variable_get(:@forces)
      event = simulation.instance_variable_get(:@event)
      stepper = simulation.instance_variable_get(:@stepper)
      expect(nodes).to eq(data["nodes"])
      expect(nDim).to eq(3)
      expect(initialRadius).to eq(10)
      expect(initialAngleRoll).to eq(2.399963229728653)
      expect(initialAngleYaw).to eq(2.632685497432642)
      expect(alpha).to eq(0.0009999999999999966)
      expect(alphaMin).to eq(0.001)
      expect(alphaDecay).to eq(0.02276277904418933)
      expect(alphaTarget).to eq(0)
      expect(velocityDecay).to eq(0.6)
      expect(forces).to eq({})
      expect(event.instance_of? D3Dispatch::Dispatch).to be_truthy
      expect(stepper.instance_of? D3Timer::Timer).to be_truthy
    end
  end

  context "#num_dimensions" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the numDimension if non given to set" do
      num_dimensions = simulation.num_dimensions
      expect(num_dimensions).to eq 3 
    end

    it "should set the given numDimension value and return the simulation object" do
      num_dimensions = simulation.num_dimensions
      expect(num_dimensions).to eq 3
      new_simulation = simulation.num_dimensions(2)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      num_dimensions = simulation.num_dimensions
      expect(num_dimensions).to eq 2
    end

    it "should set the given numDimension value maximum to 3 " do
      num_dimensions = simulation.num_dimensions(5)
      expect(simulation.num_dimensions).to eq 3
    end

    it "should set the given numDimension value by rounding of given 2.2 to 2" do
      num_dimensions = simulation.num_dimensions(2.2)
      expect(simulation.num_dimensions).to eq 2
    end
  end

  context "#nodes" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the nodes if non given to set" do
      nodes = simulation.nodes
      expect(nodes).to eq data["nodes"]
    end

    it "should set the given nodes value and return the simulation object" do
      new_node = [{id: "41454115141231541231"}]
      new_simulation = simulation.nodes(new_node)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      nodes = simulation.nodes
      expect(nodes).to eq new_node
    end

    it "should set the blank array to nodes if nil is given and return the simulation object" do
      new_simulation = simulation.nodes(nil)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      nodes = simulation.nodes
      expect(nodes).to eq []
    end
  end

  context "#alpha" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the alpha if non given to set" do
      alpha = simulation.alpha
      expect(alpha).to eq 0.0009999999999999966
    end

    it "should set the given alpha value and return the simulation object" do
      new_simulation = simulation.alpha(1.5)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha = simulation.alpha
      expect(alpha).to eq 1.5
    end

    it "should convert to integer and set the given alpha value and return the simulation object" do
      new_simulation = simulation.alpha("3")
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha = simulation.alpha
      expect(alpha).to eq 3
    end
  end

  context "#alpha_min" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the alpha_min if non given to set" do
      alpha_min = simulation.alpha_min
      expect(alpha_min).to eq 0.001
    end

    it "should set the given alpha_min value and return the simulation object" do
      new_simulation = simulation.alpha_min(1.5)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_min = simulation.alpha_min
      expect(alpha_min).to eq 1.5
    end

    it "should convert to integer and set the given alpha_min value and return the simulation object" do
      new_simulation = simulation.alpha_min("3")
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_min = simulation.alpha_min
      expect(alpha_min).to eq 3
    end
  end

  context "#alpha_decay" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the alpha_decay if non given to set" do
      alpha_decay = simulation.alpha_decay
      expect(alpha_decay).to eq 0.02276277904418933
    end

    it "should set the given alpha_decay value and return the simulation object" do
      new_simulation = simulation.alpha_decay(1.5)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_decay = simulation.alpha_decay
      expect(alpha_decay).to eq 1.5
    end

    it "should convert to integer and set the given alpha_decay value and return the simulation object" do
      new_simulation = simulation.alpha_decay("3")
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_decay = simulation.alpha_decay
      expect(alpha_decay).to eq 3
    end
  end

  context "#alpha_target" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the alpha_target if non given to set" do
      alpha_target = simulation.alpha_target
      expect(alpha_target).to eq 0
    end

    it "should set the given alpha_target value and return the simulation object" do
      new_simulation = simulation.alpha_target(1.5)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_target = simulation.alpha_target
      expect(alpha_target).to eq 1.5
    end

    it "should convert to integer and set the given alpha_target value and return the simulation object" do
      new_simulation = simulation.alpha_target("3")
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      alpha_target = simulation.alpha_target
      expect(alpha_target).to eq 3
    end
  end

  context "#velocity_decay" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the velocity_decay if non given to set" do
      velocity_decay = simulation.velocity_decay
      expect(velocity_decay).to eq 0.4
    end

    it "should set the given velocity_decay value and return the simulation object" do
      new_simulation = simulation.velocity_decay(0.3)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      velocity_decay = simulation.velocity_decay
      expect(velocity_decay).to eq 0.3
    end

    it "should convert to integer and set the given velocity_decay value and return the simulation object" do
      new_simulation = simulation.velocity_decay("0.2")
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      velocity_decay = simulation.velocity_decay
      expect(velocity_decay).to eq 0.2
    end
  end

  context "#force" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should set the given force with name and return the simulation object" do
      force = D3Force3d::Link.force_links(data)
      new_simulation = simulation.force("link", force)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
    end

    it "should return the force with given name" do
      force = D3Force3d::Link.force_links(data)
      simulation.force("link", force)
      result_force = simulation.force("link")
      expect(result_force).to eq force
    end

    it "should delete the force with given name if nil is given in second argument and return the simulation object" do
      force = D3Force3d::Link.force_links(data)
      simulation.force("link", force)
      new_simulation = simulation.force("link", nil)
      expect(new_simulation.instance_of? D3Force3d::Simulation).to be_truthy
      result_force = simulation.force("link")
      expect(result_force).to eq nil
    end
  end

  context "#find" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return the closest node for x,y,z co-ordnate between the given radius" do
      correct_node = {"id"=>"b7c70898d90f5bb3a32353817e451b646b40299a", "index"=>3, "vx"=>0.0, "vy"=>0.0, "vz"=>0.0, "x"=>-0.5043044434857213, "y"=>8.775206858050936, "z"=>11.434588052566074}
      result_node = simulation.find(10, 10, 10, 30)
      expect(result_node).to eq(correct_node)
    end

    it "should return nil for x,y,z co-ordnate between the given radius if no node is found" do
      result_node = simulation.find(100, 100, 100, 30)
      expect(result_node).to eq(nil)
    end

    it "should return the closest node for x,y,z co-ordnate and search in Infinite radius if not given" do
      correct_node = {"id"=>"7694d5f733a9ea588909371898679fc618a20dad", "index"=>319, "x"=>29.233033989750652, "y"=>39.168433815370385, "z"=>47.74871818246465, "vx"=>0.0, "vy"=>0.0, "vz"=>0.0}
      result_node = simulation.find(100, 100, 100)
      expect(result_node).to eq(correct_node)
    end
  end

  context "#on" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should return dispatch object if callback is not set for type" do
      result = simulation.on("tick")
      expect(result.instance_of? D3Dispatch::Dispatch).to be_truthy
    end

    it "should set the callback for soecified typename and return simulation object" do
      result = simulation.on("tick"){ puts "Hello" }
      expect(result.instance_of? D3Force3d::Simulation).to be_truthy
      callback = simulation.on("tick")
      expect(callback.instance_of? Proc).to be_truthy
    end

    it "should raise and error if type is not set" do
      expect { simulation.on("start") }.to raise_error(RuntimeError, /unknown type: start/)
    end
  end

  context "#restart" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should call the restart method of D3Timer on timer object and return the simulation object" do
      timer = simulation.instance_variable_get(:@stepper)
      expect(timer).to receive(:restart)
      result = simulation.restart
      expect(result.instance_of? D3Force3d::Simulation).to be_truthy 
    end
  end

  context "#stop" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should call the stop method of D3Timer on timer object and return the simulation object" do
      timer = simulation.instance_variable_get(:@stepper)
      expect(timer).to receive(:stop)
      result = simulation.stop
      expect(result.instance_of? D3Force3d::Simulation).to be_truthy 
    end
  end

  context "#tick" do
    let!(:simulation) { D3Force3d::Simulation.force_simulation(data["nodes"], 3) }

    it "should calculate the force on nodes" do
      simulation.tick(10000)
      nodes = simulation.nodes
      file1 = File.open("spec/support/link_result.json")
      data1 = JSON.load file1
      expect(nodes).to eq(data1["node_result"])
    end
  end
end