require 'helper'

describe Tush::ModelStore do

  before :all do
    class Willie < ActiveRecord::Base
      belongs_to :jeremiah
    end

    class Jeremiah < ActiveRecord::Base; end
  end


  describe "#push" do

    let!(:jeremiah) { Jeremiah.create }
    let!(:willie) { Willie.create :jeremiah => jeremiah }

    it "doesn't follow attributes for models in copy_only_models" do
      associations = Tush::AssociationHelpers.relation_infos(:belongs_to, willie.class)
      associations.count.should == 1

      model_store = Tush::ModelStore.new(:copy_only_models => [Willie])
      model_store.push(willie)

      model_store.model_wrappers.count.should == 1
      model_store.model_wrappers.first.model_instance.should == willie
    end

  end

end
