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

      wrapper = Tush::ModelWrapper.new(:model => ray)

      wrapper.association_objects.should == [alex]
    end
  end

  describe "setting model trace" do
    it "sets model trace when there is already an exisiting model" do
      wrapper_ray = Tush::ModelWrapper.new(:model => Ray.create)
      wrapper_ray.stub(:model_trace => [['Alex', 2]])
      wrapper_ray.add_model_trace_list([['Alex', 3], ['Alex', 4]])
      wrapper_ray.model_trace.should == [['Alex', 2], ['Alex', 3], ['Alex', 4]]

    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(:model => Ray.create)
      wrapper_ray.add_model_trace_list([['Alex', 3], ['Alex', 4]])
      wrapper_ray.model_trace.should == [['Alex', 3], ['Alex', 4]]
    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(:model => Ray.create)
      wrapper_alex = Tush::ModelWrapper.new(:model => Alex.create)

      wrapper_ray.add_model_trace(wrapper_alex)

      wrapper_ray.model_trace.should == [['Alex', wrapper_alex.original_db_id]]
    end

    it "sets model trace without it previously being set" do
      wrapper_ray = Tush::ModelWrapper.new(:model => Ray.create)
      wrapper_alex = Tush::ModelWrapper.new(:model => Alex.create)
      wrapper_ray.stub(:model_trace => [['Alex', 2]])

      wrapper_ray.add_model_trace(wrapper_alex)

      wrapper_ray.model_trace.should == [['Alex', 2], ['Alex', wrapper_alex.original_db_id]]
    end
  end

end
