require 'helper'
require 'tempfile'

describe Tush::Importer do

  before :all do
    class Model1 < ActiveRecord::Base
      self.table_name = :table_six
      has_one :model_2
    end

    class Model2 < ActiveRecord::Base
      self.table_name = :table_seven
    end
  end

  it "imports data" do
    file = File.read("#{test_root}/spec/support/exported_data.json")
    imported = Tush::Importer.new("#{test_root}/spec/support/exported_data.json")
    imported.clone_data
    binding.pry
  end

end
