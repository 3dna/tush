require 'helper'
require 'tempfile'

describe Tush::Exporter do

  before :all do
    class Jason < ActiveRecord::Base
      has_one :kumie
    end

    class Kumie < ActiveRecord::Base; end
  end

  let!(:jason1) { Jason.create }
  let!(:jason2) { Jason.create }
  let!(:kumie1) { Kumie.create :jason_id => jason1.id }
  let!(:kumie2) { Kumie.create :jason_id => jason2.id }

  let!(:exporter) { Tush::Exporter.new([jason1, jason2]) }

  describe "#data" do

    it "should store data correctly" do
      exporter.data.should ==
        {:model_wrappers=>
          [{:model_class=>"Jason", :model_attributes=>{"id"=>1}, :model_trace=>[]},
           {:model_class=>"Kumie", :model_attributes=>{"id"=>1, "jason_id"=>1}, :model_trace=>[["Jason", 1]]},
           {:model_class=>"Jason", :model_attributes=>{"id"=>2}, :model_trace=>[]},
           {:model_class=>"Kumie", :model_attributes=>{"id"=>2, "jason_id"=>2}, :model_trace=>[["Jason", 2]]}]}
    end

  end

  describe "#export_json" do

    it "should export its data in json" do
      exporter.export_json.should ==
        "{\"model_wrappers\":[{\"model_class\":\"Jason\",\"model_attributes\":{\"id\":1},\"model_trace\":[]},{\"model_class\":\"Kumie\",\"model_attributes\":{\"id\":1,\"jason_id\":1},\"model_trace\":[[\"Jason\",1]]},{\"model_class\":\"Jason\",\"model_attributes\":{\"id\":2},\"model_trace\":[]},{\"model_class\":\"Kumie\",\"model_attributes\":{\"id\":2,\"jason_id\":2},\"model_trace\":[[\"Jason\",2]]}]}"
    end

  end

end
