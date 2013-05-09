require 'deep_clone'

module Tush
	class ImportedModelWrapper

		attr_accessor :model_class, :model_attributes, :original_db_key, :original_db_id, :cloned_hash, :new_object

		def initialize(exported_data)
			self.model_class = exported_data["model_class"].constantize
			self.model_attributes = exported_data["model_instance"]
			self.original_db_key = exported_data["original_db_key"]
			self.original_db_id = exported_data["original_db_id"]
			clean_model_attributes
		end

		def clean_model_attributes
			cloned_hash = DeepClone.clone(self.model_attributes)
			cloned_hash.delete(self.original_db_key)
			self.cloned_hash = cloned_hash
		end

		def create_clone
			self.new_object = self.model_class.create!(self.cloned_hash)
		end
	end
end