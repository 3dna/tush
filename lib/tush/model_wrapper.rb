require 'active_record'
require 'active_support'
require 'deep_clone'
require 'sneaky-save'

module Tush

  # This is a class the wraps each model instance that we
  # plan on exporting.
  class ModelWrapper

    attr_accessor(:model_attributes,
                  :model_blacklist,
                  :new_model,
                  :new_model_attributes,
                  :model,
                  :model_class,
                  :model_trace,
                  :original_db_id)

    def initialize(opts={})
      model = opts[:model]

      if model.is_a?(ActiveRecord::Base)
        self.model = model
        self.model_class = model.class
        self.model_attributes = model.attributes || {}
      else
        self.model_class = opts[:model_class].constantize
        self.model_attributes = opts[:model_attributes] || {}
      end

      self.model_trace = []
    end

    def original_db_key
      "id"
    end

    def create_copy
      # Define the custom_create method on a model to save
      # new models in a custom manner.
      if model_class.respond_to?(:custom_create)
        self.new_model = self.model_class.custom_create(model_attributes)
        self.new_model_attributes = self.new_model.attributes
      else
        create_without_validation_and_callbacks
      end
    end

    def filtered_model_attributes
      model_attributes.delete_if do |attribute, value|
        not model_class.columns_hash.keys.include?(attribute)
      end
    end

    def create_without_validation_and_callbacks
      attributes = model_attributes.clone
      attributes.delete(original_db_key)

      copy = model_class.new(filtered_model_attributes)
      copy.sneaky_save
      copy.reload

      self.new_model = copy
      self.new_model_attributes = copy.attributes
    end

    def original_db_id
      model_attributes[self.original_db_key]
    end

    def add_model_trace_list(list)
      model_trace.concat(list)
    end

    def add_model_trace(model_wrapper)
      model_trace << [model_wrapper.model_class.to_s,
                      model_wrapper.original_db_id]
    end

    def association_objects
      objects = []
      SUPPORTED_ASSOCIATIONS.each do |association_type|
        relation_infos =
          AssociationHelpers.relation_infos(association_type,
                                            model_class)
        next if relation_infos.empty?

        relation_infos.each do |info|
          next if model_blacklist && model_blacklist.include?(association_class(association_type, info))
          next unless model.respond_to?(info.name)

          object = model.send(info.name)

          if object.is_a?(Array)
            objects.concat(object)
          elsif object.respond_to?(:to_a)
            objects.concat(object.to_a)
          elsif object
            objects << object
          end
        end
      end

      objects
    end

    def export
      { :model_class => model_class.to_s,
      	:model_attributes => model_attributes,
        :model_trace => model_trace }
    end

    private

    def association_class(association_type, relation_info)
      if association_type == :belongs_to && relation_info.options[:polymorphic]
        self.model_attributes["#{relation_info.name.to_s}_type"].constantize
      else
        relation_info.klass
      end
    end
  end

end
