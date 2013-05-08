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

  	def push(model_instance)
  	  model_stack.push ModelWrapper.new(model_instance)
  	end

  	def pop
  	  model_stack.pop
  	end

  	def set_has_many
      associations = model.reflect_on_all_associations(:has_many)
      if associations.any?
	    classes = associations.map(&:class_name)
	    class_keys = associations.map(&:foreign_key)
	    self.has_many = Hash[classes.zip(class_keys)]
	  end 
  	end

  	def set_belongs_to 
  	  associations = model.reflect_on_all_associations(:belongs_to)
  	  if associations.any?
  	    self.belongs_to = associations.map(&:foreign_key)
  	  end
  	end

  	def set_has_one
  	  associations = model.reflect_on_all_associations(:has_one)
  	  if associations.any?
	    classes = associations.map(&:class_name)
	    class_keys = associations.map(&:foreign_key)
	    self.has_one = Hash[classes.zip(class_keys)]
	  end 
  	end


  end
end