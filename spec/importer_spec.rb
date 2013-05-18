require 'helper'
require 'tempfile'
require 'json'
require 'sneaky-save'

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
        {"model_wrappers"=>
        [{"model_class"=>"Kai",
           "model_instance"=>{"id"=>10, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Brett",
           "model_instance"=>{"id"=>1, "kai_id"=>10, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Kai",
           "model_instance"=>{"id"=>2, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>2},
         {"model_class"=>"Brett",
           "model_instance"=>{"id"=>2, "kai_id"=>2, "sample_data"=>"data string"},
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

    PREFILLED_ROWS = 11

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

      PREFILLED_ROWS.times do
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

    let!(:exported) { Tush::Exporter.new([lauren1, lauren2, david, charlie, dan]).export_json }
    let!(:imported) { Tush::Importer.new(JSON.parse(exported)) }

    it "imports a few database rows into the same database correctly" do
      imported.clone_data
      imported.update_associated_ids

      existing_rows = PREFILLED_ROWS + 1

      Dan.count.should == existing_rows + 1
      Lauren.count.should == existing_rows + 3
      Charlie.count.should == existing_rows + 1
      David.count.should == existing_rows + 1

      Dan.last.lauren.map { |lauren| lauren.id } == [14, 15]
      David.last.charlie.id.should == 13
      David.last.lauren_id.should == 14
      Charlie.last.lauren.id.should == 15
    end
  end

end
