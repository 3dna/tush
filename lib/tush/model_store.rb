require 'tush/helpers/association_helpers'

module Tush

  class ModelStore

    attr_accessor :model_stack

    def initialize
      self.model_stack = []
    end

    def push_array(model_array)
      model_array.each { |model_instance| self.push(model_instance) }
    end

    def push(model_instance)
      return if object_in_stack?(model_instance)

      model_wrapper = ModelWrapper.new(model_instance)
      model_stack.push(model_wrapper)

      model_wrapper.has_one_objects.each { |object| self.push(object) }
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

    def from_hash

    end

  end

end
