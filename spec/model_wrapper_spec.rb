require 'helper'

describe Tush::ModelWrapper do

  before :all do
    class Model1 < ActiveRecord::Base
      self.table_name = :table_six
      has_one :model_2
    end

    class Model2 < ActiveRecord::Base
      self.table_name = :table_seven
    end
  end

  describe "#has_one_objects" do
    it "" do
      test_model_1 = Model1.create
      test_model_2 = Model2.create :model1_id => test_model_1.id

      wrapper = Tush::ModelWrapper.new(test_model_1)
      objects = wrapper.has_one_objects

      objects.should == [test_model_2]
    end
  end

end
