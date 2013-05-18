require 'tush/helpers/association_helpers'

module Tush

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
      return if self.blacklisted_models.include?(model_instance.class)
      return if object_in_stack?(model_instance)

      model_wrapper = ModelWrapper.new(model_instance)

      if parent_wrapper and parent_wrapper.model_trace.any?
        model_wrapper.add_model_trace_list(parent_wrapper.model_trace)
        model_wrapper.add_model_trace(parent_wrapper.model_instance)
      elsif parent_wrapper
        model_wrapper.add_model_trace(parent_wrapper.model_instance)
      end

      model_wrappers.push(model_wrapper)

      return if self.copy_only_models.include?(model_instance.class)

      model_wrapper.association_objects.each { |object| self.push(object, model_wrapper) }
    end

    def object_in_stack?(model_instance)
      self.model_wrappers.each do |model_wrapper|
        return true if model_instance == model_wrapper.model_instance
      end

      return false
    end

    def to_hash
      { :model_wrappers => self.model_wrappers.map { |model_wrapper| model_wrapper.to_hash } }
    end

  end

end
