require 'tush/model_store'
require 'json'

module Tush

  # This class takes in a tush export and imports it into ActiveRecord.
  class Importer

    class NonUniqueWrapperError < RuntimeError; end
    class InvalidWrapperError < RuntimeError; end

    attr_accessor(:data,
                  :imported_model_wrappers,
                  :model_to_attribute_blacklist)

    def initialize(exported_data)
      self.data = exported_data
      self.imported_model_wrappers = []
      self.model_to_attribute_blacklist = {}
    end

    def self.new_from_json(json_path)
      unparsed_json = File.read(json_path)
      self.new(JSON.parse(unparsed_json))
    end

    def self.new_from_unparsed_json(unparsed_json)
      self.new(JSON.parse(unparsed_json))
    end

    def create_models!
      model_wrappers = self.data["model_wrappers"]

      model_wrappers.each do |model_wrapper|
        model_class = model_wrapper["model_class"].constantize
        imported_model_wrapper =
          ModelWrapper.new(:model_class => model_class.to_s,
                           :model_attributes => model_wrapper["model_attributes"],
                           :blacklisted_attributes => self.model_to_attribute_blacklist[model_class])

        imported_model_wrapper.create_copy

        self.imported_model_wrappers << imported_model_wrapper
      end
    end

    def find_wrapper_by_class_and_old_id(klass, old_id)
      wrappers = self.imported_model_wrappers.select do |wrapper|
        (wrapper.model_class == klass) and (wrapper.original_db_id == old_id)
      end

      wrappers[0]
    end

    # This method updates stale foreign keys after the new models have been created.
    def update_foreign_keys!
      models = self.imported_model_wrappers.map { |wrapper| wrapper.model_class }
      model_to_foreign_keys = AssociationHelpers.create_foreign_key_mapping(models)

      imported_model_wrappers.each do |wrapper|
        foreign_keys = model_to_foreign_keys[wrapper.model_class]

        foreign_keys.each do |foreign_key_info|
          match = self.find_wrapper_by_class_and_old_id(foreign_key_info[:class],
                                                        wrapper.model_attributes[foreign_key_info[:foreign_key]])

          if match
            new_id = match.new_model.send(match.original_db_key)
          else
            # If we don't have a model wrapper (like in the case of a copy only model),
            # remove the id
            new_id = nil
            wrapper.new_model_attributes[foreign_key_info[:foreign_key]] = nil
          end

          wrapper.new_model.update_column(foreign_key_info[:foreign_key],
                                          new_id)
        end
      end
    end
  end

end
