require 'active_support'
require 'deep_clone'

module Tush

  class ModelWrapper

    attr_accessor(:model_attributes,
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
      if self.model_class.respond_to?(:custom_save)
        self.new_model = self.model_class.custom_save(self.model_attributes)
        self.new_model_attributes = self.new_model.attributes
      elsif self.model_class.respond_to?(:custom_create)
        self.new_model = self.model_class.custom_create(self.model_attributes)
        self.new_model_attributes = self.new_model.attributes
      else
        copy = self.model_class.new(self.model_attributes)
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
        relation_infos =
          AssociationHelpers.relation_infos(association_type,
                                            self.model_class)
        next if relation_infos.empty?

        relation_infos.each do |info|
          object = self.model.send(info.name)

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
