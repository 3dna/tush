require 'tush/model_store'
require 'json'

module Tush

  class Importer

    attr_accessor :data, :imported_model_wrappers

    def initialize(json_path)
      unparsed_json = File.read(json_path)
      self.data = JSON.parse(unparsed_json)
      self.imported_model_wrappers = []
    end

    def clone_data
      model_stack = self.data["model_stack"]

      model_stack.each do |model_wrapper|
        imported_model_wrapper = ImportedModelWrapper.new(model_wrapper)
        imported_model_wrapper.create_clone
        self.imported_model_wrappers << imported_model_wrapper
      end
    end

    def find_wrapper_by_class_and_old_id(klass, old_id)
      wrappers = self.imported_model_wrappers.select do |wrapper|
        wrapper.model_class == klass
      end

      wrappers = wrappers.select do |wrapper|
        wrapper.original_db_id == old_id
      end

      puts 'ERROR' if wrappers.count > 1

      wrappers[0]
    end

    def update_associated_ids
      models = self.imported_model_wrappers.map { |wrapper| wrapper.model_class }
      models = models.uniq
      model_to_foreign_keys = AssociationHelpers.create_foreign_key_mapping(models)

      imported_model_wrappers.each do |wrapper|
        foreign_keys = model_to_foreign_keys[wrapper.model_class]

        foreign_keys.each do |key_hash|
          match = self.find_wrapper_by_class_and_old_id(key_hash["class"],
                                                        wrapper.model_attributes[key_hash["foreign_key"]])
          wrapper.new_object.update_attribute(key_hash["foreign_key"],
                                              match.new_object.send(:original_db_key))
        end
      end
    end
  end
end
