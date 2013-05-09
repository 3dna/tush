# require 'helper'

# describe Tush::ModelStore do

#   before :all do
#     class Model1 < ActiveRecord::Base
#       self.table_name = :table_one

#       belongs_to :model_2
#       belongs_to :model_3
#       has_many :model_4
#       has_one :model_5
#     end

#     class Model2 < ActiveRecord::Base
#       self.table_name = :table_two
#     end

#     class Model3 < ActiveRecord::Base
#       self.table_name = :table_three
#     end

#     class Model4 < ActiveRecord::Base
#       self.table_name = :table_four
#     end

#     class Model5 < ActiveRecord::Base
#       self.table_name = :table_five
#     end
#   end

#   describe "#set_belongs_to" do
#     it "returns an array with models that belong to ModelStoreTestModel" do
#       model_store = Tush::ModelStore.new(Model1)
#       model_store.belongs_to.should ==
#         { "Model2" => "model_2_id", "Model3" => "model_3_id" }
#     end
#   end

#   describe "#has_many" do
#     it "returns a hash of models and model keys that relate to ModelStoreTestModel" do
#       model_store = Tush::ModelStore.new(Model1)
#       model_store.has_many.should == { "Model4" => "model1_id" }
#     end
#   end

#   describe "#has_one" do
#     it "returns a hash of models and model keys that relate to ModelStoreTestModel" do
#       model_store = Tush::ModelStore.new(Model1)
#       model_store.has_one.should == { "Model5" => "model1_id" }
#     end
#   end

# end
