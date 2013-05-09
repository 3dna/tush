module Tush

  class ModelWrapper

    attr_accessor :model_instance, :original_db_key, :new_db_key, :original_db_id, :model_class

    def initialize(model_instance, original_db_key='id')
      self.model_class = model_instance.class.name
      self.model_instance = model_instance
      self.original_db_key = original_db_key
      self.original_db_id = self.model_instance.send(self.original_db_key)
    end

    def association_objects
      objects = []
      [:belongs_to, :has_one, :has_many].each do |association_type|
        relation_infos = AssociationHelpers.relation_infos(association_type,
                                                           self.model_instance.class)
        return [] if relation_infos.empty?

        relation_infos.each do |info|
          if association_type == :has_many
            object = self.model_instance.send(info.names)
          else
            object = self.model_instance.send(info.name)
          end

          objects << object if object
        end
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
