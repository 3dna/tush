module Tush

  class ModelWrapper

    attr_accessor :model_instance, :original_db_key, :new_db_key, :original_db_id, :model_class

    def initialize(model_instance, original_db_key='id')
      self.model_class = model_instance.class.name
      self.model_instance = model_instance
      self.original_db_key = original_db_key
      self.original_db_id = self.model_instance.send(self.original_db_key)
    end

    def has_one_objects
      relation_infos = AssociationHelpers.relation_infos(:has_one,
                                                         self.model_instance.class)
      return [] if relation_infos.empty?

      objects = []
      relation_infos.each do |info|
        object = self.model_instance.send(info.name)
        objects << object if object
      end

      objects
    end

    def to_hash
      { :model_class => self.model_class,
      	:model_instance => self.model_instance.attributes,
        :original_db_key => self.original_db_key,
        :new_db_key => self.new_db_key,
        :original_db_id => self.original_db_id }
    end

  end

end
