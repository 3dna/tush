require 'active_support'
require 'deep_clone'

module Tush

  class ModelWrapper

    attr_accessor(:blacklisted_attributes,
                  :model_attributes,
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

      self.blacklisted_attributes = opts[:blacklisted_attributes] || []
      self.model_trace = []
    end

    def original_db_key
      "id"
    end

    def cleaned_model_attributes
      attributes_clone = DeepClone.clone(self.model_attributes)

      attributes_clone.delete(self.original_db_key)

      self.blacklisted_attributes.each do |attr|
        attributes_clone.delete(attr)
      end

      attributes_clone
    end

    def create_copy
      if self.model_class.respond_to?(:custom_save)
        self.new_object = self.model_class.custom_save(self.cleaned_model_attributes)
      else
        copy = self.model_class.new(self.cleaned_model_attributes)
        copy.sneaky_save
        copy.reload

        self.new_model = copy
        self.new_model_attributes = copy.attributes
      end
    end

    def original_db_id
      self.model_attributes[self.original_db_key]
    end

    def add_model_trace_list(list)
      self.model_trace.concat(list)
    end

    def add_model_trace(model_wrapper)
      self.model_trace << [model_wrapper.model_class.to_s,
                           model_wrapper.original_db_id]
    end

    def association_objects
      objects = []
      SUPPORTED_ASSOCIATIONS.each do |association_type|
        object = self.model_class.find(self.model_attributes[self.original_db_key])

        relation_infos =
          AssociationHelpers.relation_infos(association_type,
                                            self.model_class)
        next if relation_infos.empty?

        relation_infos.each do |info|
          object = object.send(info.name)

          if object.is_a?(Array)
            objects.concat(object)
          elsif object
            objects << object
          end
        end
      end

      objects
    end

    def export
      { :model_class => self.model_class.to_s,
      	:model_attributes => self.model_attributes,
        :model_trace => self.model_trace }
    end

  end

end
