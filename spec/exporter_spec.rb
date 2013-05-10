require 'helper'
require 'tempfile'

describe Tush::Exporter do

  before :all do
    class Jason < ActiveRecord::Base
      has_one :kumie
    end

    class Kumie < ActiveRecord::Base
    end
  end

  let!(:jason1) { Jason.create }
  let!(:jason2) { Jason.create }
  let!(:kumie1) { Kumie.create :jason_id => jason1.id }
  let!(:kumie2) { Kumie.create :jason_id => jason2.id }

  it "creates a nice little usable hash" do
    exporter = Tush::Exporter.new([jason1, jason2], [])
    exporter.data.should ==
      { :model_stack => [{ :model_class => "Jason",
                           :model_instance => { "id" => 1 },
                           :original_db_key => "id",
                           :new_db_key => nil,
                           :original_db_id => 1 },
                         { :model_class => "Kumie",
                           :model_instance => { "id" => 1, "jason_id" => 1 },
                           :original_db_key => "id",
                           :new_db_key => nil,
                           :original_db_id => 1},
                         { :model_class => "Jason",
                           :model_instance => { "id"=>2 },
                           :original_db_key => "id",
                           :new_db_key => nil,
                           :original_db_id => 2},
                         { :model_class => "Kumie",
                           :model_instance => {"id" => 2, "jason_id" => 2},
                           :original_db_key => "id",
                           :new_db_key => nil,
                           :original_db_id => 2 }] }
  end

  it "saves exported data as json to a specified file" do
    exporter = Tush::Exporter.new([jason1, jason2], [])
    file = Tempfile.new('exported_data')
    exporter.save_json(file.path)

    saved_file = File.read(file.path)
    data = JSON.parse(saved_file)
    data.should ==
      {"model_stack"=>
      [{"model_class"=>"Jason",
         "model_instance"=>{"id"=>1},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>1},
       {"model_class"=>"Kumie",
         "model_instance"=>{"id"=>1, "jason_id"=>1},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>1},
       {"model_class"=>"Jason",
         "model_instance"=>{"id"=>2},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>2},
       {"model_class"=>"Kumie",
         "model_instance"=>{"id"=>2, "jason_id"=>2},
         "original_db_key"=>"id",
         "new_db_key"=>nil,
         "original_db_id"=>2}]}
  end


end
