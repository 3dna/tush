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

end
