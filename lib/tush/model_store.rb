require 'tush/helpers/association_helpers'
require "set"

module Tush

  # This holds the collection of models that will be exported.
  class ModelStore

    attr_accessor :model_wrappers, :blacklisted_models, :copy_only_models, :model_instances

    def initialize(opts={})
      self.blacklisted_models = Set.new(opts[:blacklisted_models] || [])
      self.copy_only_models = Set.new(opts[:copy_only_models] || [])
      self.model_wrappers = Set.new
      self.model_instances = Set.new
    end

    def push_array(model_array)
      model_array.each { |model_instance| self.push(model_instance) }
    end

    def push(model_instance, parent_wrapper=nil)
      return if self.object_in_stack?(model_instance)
      return if self.blacklisted_models.include?(model_instance.class)

      if model_instance.respond_to?(:copy_with_tush?)
        return unless model_instance.copy_with_tush?
      end

      model_wrapper = ModelWrapper.new(:model => model_instance)
      model_wrapper.model_blacklist = blacklisted_models

      unless Tush.disable_model_trace
        if parent_wrapper and parent_wrapper.model_trace.any?
          model_wrapper.add_model_trace_list(parent_wrapper.model_trace)
          model_wrapper.add_model_trace(parent_wrapper)
        elsif parent_wrapper
          model_wrapper.add_model_trace(parent_wrapper)
        end
      end

      model_wrappers << model_wrapper
      model_instances << [model_wrapper.model_class, model_wrapper.model_attributes["id"]]

      return if self.copy_only_models.include?(model_instance.class)

      model_wrapper.association_objects.each do |object|
        self.push(object, model_wrapper)
      end
    end

    def object_in_stack?(model_instance)
      model_instances.include?([model_instance.class, model_instance.attributes["id"]])
    end

    def export
      { :model_wrappers => self.model_wrappers.map { |model_wrapper| model_wrapper.export } }
    end

  end

end
