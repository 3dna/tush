require 'tush/model_store'
require 'json'

module Tush

  class Importer

    attr_accessor :data, :imported_model_wrappers

    def initialize(json_path)
      unparsed_json = File.read(json_path)
      self.data = JSON.parse(unparsed_json)
      self.imported_model_wrappers = []
      self.updated_objects = {model_name => id}
    end

    def clone_data
    	model_stack = self.data["model_stack"]
    
    	model_stack.each do |model_wrapper|
    		imported_model_wrapper = ImportedModelWrapper.new(model_wrapper)
    		imported_model_wrapper.create_clone
    		self.imported_model_wrappers << imported_model_wrapper
    	end
    end

    def update_assoicated_ids
    	imported_model_wrapper.each do |wrapper|
    		new object => EventPage
    		find all associations => eventicketlevel
    		array = eventicketlevel.where id => old_id
    		array.each do {a.save}

    	end
    end

    def update_assoicated_ids
    	model_to_foreign_keys

    	imported_model_wrappers.each do |wrapper|
    		foreign_keys = model_to_foreign_keys[wrapper.model_class]

    		foreign_keys.each do |foreign_key|
    			model_type = type_of_class(foreign_key)
    			matches = self.imported_model_wrappers.select do |imported_model_wrapper|
    				imported_model_wrapper.model_class == model_type && imported_model_wrapper.original_db_id == wrapper.model_attributes[foreign_key]
    			end

    			assert matches.count == 1

    			wrapper.new_object.update_attribute(foreign_key, matches[0].new_object.id)
    		end
    	end
    end

  end

end
