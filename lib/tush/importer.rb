require 'tush/model_store'
require 'json'

module Tush

  class Importer

    attr_accessor :data

    def initialize(json_path)
      unparsed_json = File.read(path)
      self.data = JSON.parse(unparsed_json)
    end

  end

end
