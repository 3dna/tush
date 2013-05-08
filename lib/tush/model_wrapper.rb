class ModelWrapper

  attr_accessor :model_instance, :original_db_key, :new_db_key
  
  def initialize(model_instance, original_db_key='id')
  	self.model_instance = model_instance.attributes
  	self.original_db_key = original_db_key
  end

end