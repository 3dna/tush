module Tush

  class ModelWrapper

    attr_accessor :model_instance,
                  :original_db_key,
                  :new_db_key,
                  :original_db_id,
                  :model_class,
                  :model_trace

    def initialize(model_instance, original_db_key='id')
      self.model_class = model_instance.class.name
      self.model_instance = model_instance
      self.original_db_key = original_db_key
      self.original_db_id = self.model_instance.send(self.original_db_key)
      self.model_trace = []
    end

    def add_model_trace_list(list)
    	self.model_trace.concat(list)
    end

    def add_model_trace(model_instance)
    	self.model_trace << [model_instance.class.to_s, model_instance.id]
    end

    def association_objects
      objects = []
      SUPPORTED_ASSOCIATIONS.each do |association_type|
        relation_infos =
          AssociationHelpers.relation_infos(association_type,
                                            self.model_instance.class)
        next if relation_infos.empty?

        relation_infos.each do |info|
          object = self.model_instance.send(info.name)

          if object.is_a?(Array)
            objects.concat(object)
          else
            objects << object if object
          end
        end
      end

      objects
    end

    def to_hash
      { :model_class => self.model_class,
      	:model_instance => self.model_instance.attributes,
        :original_db_key => self.original_db_key,
        :new_db_key => self.new_db_key,
        :original_db_id => self.original_db_id,
        :model_trace => self.model_trace }
    end

  end

end
