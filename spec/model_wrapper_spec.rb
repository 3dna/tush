require 'helper'
require "set"

describe Tush::ModelWrapper do

  before :all do
    class Ray < ActiveRecord::Base
      has_one :alex
      has_many :jimmy
      has_many :pictures, :as => :imageable
    end

    class Jimmy < ActiveRecord::Base
      belongs_to :ray
      has_one :picture, :as => :imageable
    end

    class Alex < ActiveRecord::Base
      belongs_to :ray
    end

    class Picture < ActiveRecord::Base
      belongs_to :imageable, :polymorphic => true
    end
  end

  describe "#association_objects" do

    it "doesn't return blacklisted objects" do
      alex = Alex.create
      ray = Ray.create :alex => alex

      wrapper = Tush::ModelWrapper.new(:model => ray)
      wrapper.model_blacklist = Set.new([Alex])

      wrapper.association_objects.should == []
    end

    describe "related has_one and belongs_to relations are discovered" do
      let!(:ray) { Ray.create }
      let!(:alex) { Alex.create(:ray => ray) }

      it "catches a has_one relation from the model that doesn't contain the foreign key" do
        wrapper = Tush::ModelWrapper.new(:model => ray)

        wrapper.association_objects.should == [alex]
      end

      it "catches a belongs_to relation from the model that contains the foreign key" do
        wrapper = Tush::ModelWrapper.new(:model => alex)

        wrapper.association_objects.should == [ray]
      end

    end

    describe "related has_many and belongs_to relations are discovered" do
      let!(:ray) { Ray.create }
      let!(:jimmy1) { Jimmy.create(:ray => ray) }
      let!(:jimmy2) { Jimmy.create(:ray => ray) }

      it "catches a has_many relation from the model that doesn't contain the foreign key" do
        wrapper = Tush::ModelWrapper.new(:model => ray)

        wrapper.association_objects.should == [jimmy1, jimmy2]
      end

      it "catches a belongs_to relation from the model that contains the foreign key" do
        wrapper = Tush::ModelWrapper.new(:model => jimmy1)

        wrapper.association_objects.should == [ray]
      end

    end

    describe "related polymorphic relations are discovered" do
      let!(:ray) { Ray.create }
      let!(:jimmy) { Jimmy.create(:ray => ray) }
      let!(:ray_picture1) { Picture.create(:imageable_id => ray.id, :imageable_type => 'Ray')}
      let!(:ray_picture2) { Picture.create(:imageable_id => ray.id, :imageable_type => 'Ray')}
      let!(:jimmy_picture) { Picture.create(:imageable_id => jimmy.id, :imageable_type => 'Jimmy')}

      it "catches a has_many relation" do
        wrapper = Tush::ModelWrapper.new(:model => ray)

        wrapper.association_objects.should  == [jimmy, ray_picture1, ray_picture2]
      end

      it "catches a has_one relation" do
        wrapper = Tush::ModelWrapper.new(:model => jimmy)

        wrapper.association_objects.should  == [ray, jimmy_picture]
      end

      it "catches a belongs_to relation" do
        wrapper1 = Tush::ModelWrapper.new(:model => ray_picture1)
        wrapper2 = Tush::ModelWrapper.new(:model => ray_picture2)
        wrapper3 = Tush::ModelWrapper.new(:model => jimmy_picture)

        wrapper1.model_blacklist = Set.new([Alex])
        wrapper2.model_blacklist = Set.new([Alex])
        wrapper3.model_blacklist = Set.new([Alex])

        wrapper1.association_objects.should  == [ray]
        wrapper2.association_objects.should  == [ray]
        wrapper3.association_objects.should  == [jimmy]
      end
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

  describe "#create_copy" do

    it "saves the model with the custom_create method if it's defined" do
      ray = Ray.create
      wrapper = Tush::ModelWrapper.new(:model => ray)

      custom_ray = Ray.create

      Ray.should_receive(:custom_create).with(ray.attributes).and_return(custom_ray)
      wrapper.create_copy
    end

    it "saves the model using sneaky_save by default" do
      ray = Ray.create
      wrapper = Tush::ModelWrapper.new(:model => ray)

      wrapper.should_receive(:create_without_validation_and_callbacks)

      wrapper.create_copy
    end

  end

  describe "#create_without_validation_and_callbacks" do

    it "should ignore extra columns that don't correspond to attributes'" do
      jimmy = Jimmy.create :ray_id => 3
      real_attributes = jimmy.attributes.clone
      fake_attributes = jimmy.attributes.clone
      fake_attributes["attr_fake"] = 3
      jimmy.stub(:attributes) { fake_attributes }
      wrapper = Tush::ModelWrapper.new(:model => jimmy)

      expect do
        wrapper.create_without_validation_and_callbacks
      end.to_not raise_error

      new_attributes = wrapper.new_model_attributes
      new_attributes.delete("id")
      real_attributes.delete("id")

      new_attributes.should == real_attributes
    end

  end

end
