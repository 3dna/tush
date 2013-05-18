require 'json'

module Tush

  class Exporter

    attr_accessor :data, :blacklisted_models, :copy_only_models

    def initialize(model_instances,
                   blacklisted_models,
                   copy_only_models)
      self.blacklisted_models = blacklisted_models || []
      self.copy_only_models = copy_only_models

      model_store = ModelStore.new(blacklisted_models,
                                   copy_only_models)

      model_store.push_array(model_instances)

      self.data = model_store.to_hash
    end

    def export_json
      self.data.to_json
    end

    def save_json(path)
      json_string = self.data.to_json

      file = File.new(path, 'w')
      file.write(json_string)
      file.close
    end

  end

end
