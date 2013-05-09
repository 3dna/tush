require 'json'

module Tush

  class Exporter

    attr_accessor :data

    def initialize(model_instances)
      model_store = ModelStore.new
      model_store.push_array(model_instances)

      self.data = model_store.to_hash
    end

    def save_json(path)
      json_string = self.data.to_json

      file = File.new(path, 'w')
      file.write(json_string)
      file.close
    end

  end

end
