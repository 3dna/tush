require 'helper'

describe Tush::ModelWrapper do

  before :all do
    class Ray < ActiveRecord::Base
      has_one :alex
    end

    class Alex < ActiveRecord::Base
    end
  end

  describe "#has_one_objects" do
    it "" do
      ray = Ray.create
      alex = Alex.create :ray_id => ray.id

      wrapper = Tush::ModelWrapper.new(ray)
      objects = wrapper.association_objects

      objects.should == [alex]
    end
  end

  describe "setting model trace" do
    it "sets model trace when there is already an exisiting model" do
      wrapper_ray = Tush::ModelWrapper.new(Ray.create)
      wrapper_ray.stub(:model_trace => [['Alex', 2]])
      wrapper_ray.add_model_trace_list([['Alex', 3], ['Alex', 4]])
      wrapper_ray.model_trace.should == [['Alex', 2], ['Alex', 3], ['Alex', 4]]

    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(Ray.create)
      wrapper_ray.add_model_trace_list([['Alex', 3], ['Alex', 4]])
      wrapper_ray.model_trace.should == [['Alex', 3], ['Alex', 4]]
    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(Ray.create)
      alex = Alex.create
      wrapper_ray.add_model_trace(alex)

      wrapper_ray.model_trace.should == [['Alex', alex.id]]
    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(Ray.create)
      alex = Alex.create
      wrapper_ray.stub(:model_trace => [['Alex', 2]])
      wrapper_ray.add_model_trace(alex)

      wrapper_ray.model_trace.should == [['Alex', 2], ['Alex', alex.id]]
    end
  end
end
