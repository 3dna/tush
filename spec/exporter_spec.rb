require 'helper'
require 'tempfile'

describe Tush::Exporter do

  before :all do
    class Model1 < ActiveRecord::Base
      self.table_name = :table_six
      has_one :model_2
    end

    class Model2 < ActiveRecord::Base
      self.table_name = :table_seven
    end
  end

  it "creates a nice little usable hash" do
    test_model_1a = Model1.create
    test_model_1b = Model1.create
    test_model_2a = Model2.create :model1_id => test_model_1a.id
    test_model_2b = Model2.create :model1_id => test_model_1b.id

    exporter = Tush::Exporter.new([test_model_1a, test_model_1b])
    exporter.data.should == {:model_stack=>[
                                            {:model_class=>"Model1",
                                              :model_instance=>{"id"=>1},
                                              :original_db_key=>"id",
                                              :new_db_key=>nil, :original_db_id=>1},
                                            {:model_class=>"Model2",
                                              :model_instance=>{"id"=>1, "model1_id"=>1},
                                              :original_db_key=>"id", :new_db_key=>nil,
                                              :original_db_id=>1},
                                            {:model_class=>"Model1",
                                              :model_instance=>{"id"=>2},
                                              :original_db_key=>"id",
                                              :new_db_key=>nil, :original_db_id=>2},
                                            {:model_class=>"Model2",
                                              :model_instance=>{"id"=>2, "model1_id"=>2},
                                              :original_db_key=>"id", :new_db_key=>nil,
                                              :original_db_id=>2}
                                           ]
    }
  end

  it "saves exported data as json to a specified file" do
    test_model_1a = Model1.create
    test_model_1b = Model1.create
    test_model_2a = Model2.create :model1_id => test_model_1a.id
    test_model_2b = Model2.create :model1_id => test_model_1b.id

    exporter = Tush::Exporter.new([test_model_1a, test_model_1b])
    file = Tempfile.new('exported_data')
    exporter.save_json(file.path)

    saved_file = File.read(file.path)
    puts saved_file
    data = JSON.parse(saved_file)
    data.should == {"model_stack"=>
      [{"model_class"=>"Model1",
         "model_instance"=>{"id"=>1},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>1},
       {"model_class"=>"Model2",
         "model_instance"=>{"id"=>1, "model1_id"=>1},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>1},
       {"model_class"=>"Model1",
         "model_instance"=>{"id"=>2},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>2},
       {"model_class"=>"Model2",
         "model_instance"=>{"id"=>2, "model1_id"=>2},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>2}]}
  end


end
