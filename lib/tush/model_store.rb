module Tush
  class ModelStore

    attr_accessor :model, :model_stack, :belongs_to, :has_many, :has_one

    def initialize(model)
      self.model = model
      self.model_stack = []
      self.has_many = {}
      self.belongs_to = []
      self.has_one = {}
    end

    def push_array_to_model_stack(model_array)
      self.model_stack.concat model_array.map { |model_instance| 
                                                ModelWrapper.new(model_instance) }
    end

    def push(model_instance)
      model_stack.push ModelWrapper.new(model_instance)
    end

    def pop
      model_stack.pop
    end



    def model_association
      instance = self.pop
      
    end


  end
end