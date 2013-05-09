require 'helper'
require 'tempfile'
require 'json'

describe Tush::Importer do

  before :all do
    class Model1 < ActiveRecord::Base
      self.table_name = :table_six
      has_one :model_2
    end

    class Model2 < ActiveRecord::Base
      self.table_name = :table_seven
    end

    class Model3 < ActiveRecord::Base
      self.table_name = :table_eight
      belongs_to :model_1
    end

  end

  let(:file) { File.read("#{test_root}/spec/support/exported_data.json") }
  let(:imported) { Tush::Importer.new_from_json("#{test_root}/spec/support/exported_data.json") }

  describe "#clone_data" do

    it "imports data" do
      imported.clone_data
      imported.data.should ==
        {"model_stack"=>
        [{"model_class"=>"Model1",
           "model_instance"=>{"id"=>10},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Model2",
           "model_instance"=>{"id"=>1, "model1_id"=>10},
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

  describe "#find_wrapper_by_class_and_old_id" do

    it "returns a matching wrapper" do
      imported.clone_data
      match = imported.find_wrapper_by_class_and_old_id(Model1, 1)

      match.model_class.should == Model1
      match.original_db_id.should == 1
      match.original_db_key.should == "id"
      match.new_object.should == Model1.first
    end

  end

  describe "#update_associated_ids" do

    before :all do
      class Lauren < ActiveRecord::Base
        has_one :david
      end

      class David < ActiveRecord::Base
        belongs_to :charlie
      end

      class Charlie < ActiveRecord::Base
        belongs_to :lauren
      end

      class Dan < ActiveRecord::Base
        has_many :lauren
      end

      11.times do
        Lauren.create
        Charlie.create
        David.create
        Dan.create
      end

    end

    let(:dan) { Dan.create }
    let(:lauren1) { Lauren.create :dan_id => dan.id }
    let(:lauren2) { Lauren.create :dan_id => dan.id }
    let(:charlie) { Charlie.create :lauren_id => lauren2.id }
    let(:david) { David.create :lauren_id => lauren1.id, :charlie_id => charlie.id }

    let(:exported) { Tush::Exporter.new([lauren1, lauren2, david, charlie, dan]).export_json }
    let(:imported) { Tush::Importer.new(JSON.parse(exported)) }

    it "" do
      imported.clone_data
      imported.update_associated_ids
      require 'awesome_print'
      ap lauren1
      ap lauren2
      ap charlie
      ap david
      ap dan
      imported.imported_model_wrappers.map {|wrapper| ap wrapper.new_object }
    end
  end

end
