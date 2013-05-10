require 'helper'
require 'tempfile'
require 'json'

describe Tush::Importer do

  before :all do
    class Kai < ActiveRecord::Base
      has_one :brett
    end

    class Brett < ActiveRecord::Base; end

    class Byron < ActiveRecord::Base
      belongs_to :kai
    end

  end

  let!(:exported_data_path) { "#{test_root}/spec/support/exported_data.json" }
  let(:file) { File.read(exported_data_path) }
  let(:imported) { Tush::Importer.new_from_json(exported_data_path) }

  describe "#clone_data" do

    it "imports data" do
      imported.clone_data
      imported.data.should ==
        {"model_stack"=>
        [{"model_class"=>"Kai",
           "model_instance"=>{"id"=>10},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Brett",
           "model_instance"=>{"id"=>1, "kai_id"=>10},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Kai",
           "model_instance"=>{"id"=>2},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>2},
         {"model_class"=>"Brett",
           "model_instance"=>{"id"=>2, "kai_id"=>2},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>2}]}
    end

  end

  describe "#find_wrapper_by_class_and_old_id" do

    it "returns a matching wrapper" do
      imported.clone_data
      match = imported.find_wrapper_by_class_and_old_id(Kai, 1)

      match.model_class.should == Kai
      match.original_db_id.should == 1
      match.original_db_key.should == "id"
      match.new_object.should == Kai.first
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

    let!(:dan) { Dan.create }
    let!(:lauren1) { Lauren.create :dan_id => dan.id }
    let!(:lauren2) { Lauren.create :dan_id => dan.id }
    let!(:charlie) { Charlie.create :lauren_id => lauren2.id }
    let!(:david) { David.create :lauren_id => lauren1.id, :charlie_id => charlie.id }

    let!(:exported) { Tush::Exporter.new([lauren1, lauren2, david, charlie, dan], []).export_json }
    let!(:imported) { Tush::Importer.new(JSON.parse(exported)) }

    it "" do
      imported.clone_data
      imported.update_associated_ids
    end
  end

end
