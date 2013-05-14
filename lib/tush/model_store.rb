require 'tush/helpers/association_helpers'

module Tush

  class ModelStore

    attr_accessor :model_stack, :blacklisted_models

    def initialize(blacklisted_models)
      self.blacklisted_models = blacklisted_models
      self.model_stack = []
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

      model_stack.push(model_wrapper)

      model_wrapper.association_objects.each { |object| self.push(object, model_wrapper) }
    end

    def pop
      model_stack.pop
    end

    def object_in_stack?(model_instance)
      self.model_stack.each do |model_wrapper|
        return true if model_instance == model_wrapper.model_instance
      end

      return false
    end

    def to_hash
      { :model_stack => self.model_stack.map { |model_wrapper| model_wrapper.to_hash } }
    end

  end

end
