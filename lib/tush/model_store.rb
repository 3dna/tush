require 'tush/helpers/association_helpers'

module Tush

  # This holds the collection of models that will be exported.
  class ModelStore

    attr_accessor :model_wrappers, :blacklisted_models, :copy_only_models

    def initialize(opts={})
      self.blacklisted_models = opts[:blacklisted_models] || []
      self.copy_only_models = opts[:copy_only_models] || []
      self.model_wrappers = []
    end

    def push_array(model_array)
      model_array.each { |model_instance| self.push(model_instance) }
    end

    def push(model_instance, parent_wrapper=nil)
      return if self.object_in_stack?(model_instance)
      return if self.blacklisted_models.include?(model_instance.class)

      model_wrapper = ModelWrapper.new(:model => model_instance)

      if parent_wrapper and parent_wrapper.model_trace.any?
        model_wrapper.add_model_trace_list(parent_wrapper.model_trace)
        model_wrapper.add_model_trace(parent_wrapper)
      elsif parent_wrapper
        model_wrapper.add_model_trace(parent_wrapper)
      end

      model_wrappers.push(model_wrapper)

      return if self.copy_only_models.include?(model_instance.class)

      model_wrapper.association_objects.each do |object|
        self.push(object, model_wrapper)
      end
    end

    def object_in_stack?(model_instance)
      self.model_wrappers.each do |model_wrapper|
        next if model_instance.class != model_wrapper.model_class
        next if model_instance.attributes["id"] != model_wrapper.model_attributes["id"]
        return true
      end

      return false
    end

    def export
      { :model_wrappers => self.model_wrappers.map { |model_wrapper| model_wrapper.export } }
    end

  end

end
