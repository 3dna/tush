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
  let(:importer) { Tush::Importer.new_from_json_file(exported_data_path) }

  describe "#create_models!" do

    it "imports data" do
      importer.create_models!
      importer.data.should ==
        {"model_wrappers"=>
        [{"model_class"=>"Kai",
           "model_attributes"=>{"id"=>10, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Brett",
           "model_attributes"=>{"id"=>1, "kai_id"=>10, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>1},
         {"model_class"=>"Kai",
           "model_attributes"=>{"id"=>2, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>2},
         {"model_class"=>"Brett",
           "model_attributes"=>{"id"=>2, "kai_id"=>2, "sample_data"=>"data string"},
           "original_db_key"=>"id",
           "new_db_key"=>nil,
           "original_db_id"=>2}]}
    end

  end

  describe "#find_wrapper_by_class_and_old_id" do

    it "returns a matching wrapper" do
      importer.create_models!
      match = importer.find_wrapper_by_class_and_old_id(Kai, 10)

      match.model_class.should == Kai
      match.original_db_id.should == 10
      match.original_db_key.should == "id"
      match.new_model.should == Kai.first
    end

  end

  describe "#update_foreign_keys!" do

    PREFILLED_ROWS = 11

    before :all do
      class Lauren < ActiveRecord::Base
        has_one :david
        def self.custom_create(attributes)
          Lauren.find_or_create_by_sample_data(attributes["sample_data"])
        end
      end

      class David < ActiveRecord::Base
        belongs_to :charlie
      end

      class Charlie < ActiveRecord::Base
        belongs_to :lauren
      end

      class Miguel < ActiveRecord::Base
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
    let!(:lauren1) { Lauren.create :dan_id => dan.id, :sample_data => "sample data" }
    let!(:lauren2) { Lauren.create :dan_id => dan.id, :sample_data => "a;sdlfad" }
    let!(:charlie) { Charlie.create :lauren_id => lauren2.id }
    let!(:david) { David.create :lauren_id => lauren1.id, :charlie_id => charlie.id }

    let!(:exported) { Tush::Exporter.new([lauren1, lauren2, david, charlie, dan]).export_json }
    let!(:importer) { Tush::Importer.new(JSON.parse(exported)) }

    it "imports a few database rows into the same database correctly" do
      importer.create_models!
      importer.update_foreign_keys!

      existing_rows = PREFILLED_ROWS + 1

      Dan.count.should == existing_rows + 1
      Lauren.count.should == existing_rows + 1
      Charlie.count.should == existing_rows + 1
      David.count.should == existing_rows + 1

      Dan.last.lauren.map { |lauren| lauren.id }.should == [12, 13]
      David.last.charlie.id.should == 13
      David.last.lauren_id.should == 12
      Charlie.last.lauren.id.should == 13
    end

    describe "when a model wrapper doesn't exist" do

      it "removes foreign keys if a model wrapper doesn't exist for an association" do
        lauren = Lauren.create
        charlie = Charlie.create :lauren => lauren

        exported = Tush::Exporter.new([charlie], :blacklisted_models => [Lauren]).export_json
        importer = Tush::Importer.new(JSON.parse(exported))

        importer.create_models!
        importer.update_foreign_keys!

        importer.imported_model_wrappers.count.should == 1
        importer.imported_model_wrappers[0].new_model.lauren_id.should == nil
      end

      it "Doesn't remove foreign keys if the column has a not null restraint" do
        lauren = Lauren.create
        miguel = Miguel.create :lauren => lauren

        exported = Tush::Exporter.new([miguel], :blacklisted_models => [Lauren]).export_json
        importer = Tush::Importer.new(JSON.parse(exported))

        importer.create_models!
        importer.update_foreign_keys!

        importer.imported_model_wrappers.count.should == 1
        importer.imported_model_wrappers[0].new_model.lauren_id.should == lauren.id
      end

    end

  end

  describe ".new_from_json" do

    it "parses json and stores it in the data attribute" do
      test_hash = { 'data' => 'data' }
      importer = Tush::Importer.new_from_json(test_hash.to_json)

      importer.data.should == test_hash
    end

  end

  describe '#rollback' do

    it 'it deletes all previously created objects' do
      importer = Tush::Importer.new([])
      model = double
      model_wrapper = double
      model_wrapper.stub(new_model: model)
      model.should_receive(:delete)
      importer.stub(:imported_model_wrappers) { [model_wrapper] }
      importer.rollback
    end

  end

end
