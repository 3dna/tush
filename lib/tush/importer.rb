require 'tush/model_store'
require 'json'

module Tush

  class Importer

    class NonUniqueWrapperError < RuntimeError; end
    class InvalidWrapperError < RuntimeError; end

    attr_accessor :data,
                  :imported_model_wrappers,
                  :model_to_attribute_blacklist

    def initialize(exported_data)
      self.data = exported_data
      self.imported_model_wrappers = []
      self.model_to_attribute_blacklist = {}
    end

    def blacklist_attributes_for_model(model, blacklisted_attributes)
      unless self.model_to_attribute_blacklist.keys.include?(model)
        self.model_to_attribute_blacklist[model] = []
      end

      self.model_to_attribute_blacklist[model].concat(blacklisted_attributes)
      self.model_to_attribute_blacklist[model] =
        self.model_to_attribute_blacklist[model].uniq
    end

    def self.new_from_json(json_path)
      unparsed_json = File.read(json_path)
      self.new(JSON.parse(unparsed_json))
    end

    def self.new_from_unparsed_json(unparsed_json)
      self.new(JSON.parse(unparsed_json))
    end

    def clone_data
      model_stack = self.data["model_stack"]

      model_stack.each do |model_wrapper|
        model_class = model_wrapper["model_class"].constantize
        imported_model_wrapper =
          ImportedModelWrapper.new(model_wrapper,
                                   self.model_to_attribute_blacklist[model_class])

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

      if wrappers.count > 1
        raise NonUniqueWrapperError
      elsif wrappers.empty?
        return nil
      end

      wrappers[0]
    end

    def update_associated_ids
      models = self.imported_model_wrappers.map { |wrapper| wrapper.model_class }
      models = models.uniq
      model_to_foreign_keys = AssociationHelpers.create_foreign_key_mapping(models)

      imported_model_wrappers.each do |wrapper|
        foreign_keys = model_to_foreign_keys[wrapper.model_class]

        foreign_keys.each do |key_hash|
          match = self.find_wrapper_by_class_and_old_id(key_hash[:class],
                                                        wrapper.model_attributes[key_hash[:foreign_key]])

          if match.nil?
            next
          end

          wrapper.new_object.update_attribute(key_hash[:foreign_key],
                                              match.new_object.send(match.original_db_key))
        end
      end
    end
  end
end
