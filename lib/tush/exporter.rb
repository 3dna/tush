require 'json'

module Tush

  class Exporter

    attr_accessor :data

    def initialize(model_instances, opts={})
      blacklisted_models = opts[:blacklisted_models] || []
      copy_only_models = opts[:copy_only_models] || []

      model_store = ModelStore.new(:blacklisted_models => blacklisted_models,
                                   :copy_only_models => copy_only_models)
      model_store.push_array(model_instances)

      self.data = model_store.to_hash
    end

    def export_json
      self.data.to_json
    end

  end

end
