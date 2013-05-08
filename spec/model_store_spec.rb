require 'helper'

describe Tush::ModelStore do

  before :all do
    class TestModel < ActiveRecord::Base
      belongs_to :test_model_2
      belongs_to :test_model_3
      has_many :test_model_4
      has_one :test_model_5
    end

    class TestModel2 < ActiveRecord::Base; end
    class TestModel3 < ActiveRecord::Base; end
    class TestModel4 < ActiveRecord::Base; end
    class TestModel5 < ActiveRecord::Base; end
  end

  describe "#set_belongs_to" do
  	it "returns an array with models that belong to TestModel" do
      model_store = Tush::ModelStore.new(TestModel)
  	  model_store.set_belongs_to
    	model_store.belongs_to.should == ['test_model_2_id', 'test_model_3_id']
    end
  end

  describe "#has_many" do
    it "returns a hash of models and model keys that relate to TestModel" do
      model_store = Tush::ModelStore.new(TestModel)
      model_store.set_has_many
      model_store.has_many.should == {'TestModel4' => 'test_model_id'}
    end
  end

  describe "#has_one" do
    it "returns a hash of models and model keys that relate to TestModel" do
      model_store = Tush::ModelStore.new(TestModel)
      model_store.set_has_one
      model_store.has_one.should == {'TestModel5' => 'test_model_id'}
    end
  end

end

