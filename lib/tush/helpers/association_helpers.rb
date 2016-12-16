module Tush

  class AssociationHelpers

    def self.relation_infos(relation_type, klass)
      if klass.is_a?(String)
        klass = klass.constantize
      end

      klass.reflect_on_all_associations(relation_type)
    end

    def self.model_relation_info(model)
      relation_infos = {}

      SUPPORTED_ASSOCIATIONS.each do |association_type|
        relation_infos[association_type] = self.relation_infos(association_type, model)
      end

      relation_infos
    end

    def self.model_to_relation_infos(models)
      models = models.uniq
      model_to_relation_infos_hash = {}

      models.each do |model|
        model_to_relation_infos_hash[model] = self.model_relation_info(model)
      end

      model_to_relation_infos_hash
    end

    # Determine the class that actually has the foreign key.
    def self.class_with_foreign_key(association_info)
      if association_info.macro == :belongs_to
        association_info.active_record
      else
        # has_one and has_many keys are stored in a model that's
        # different than the one they're declared in.
        association_info.class_name.constantize
      end
    end

    # This method locates all foreign key columns for a a list of model classes
    # for foreign keys declared within the list of models classes.
    def self.create_foreign_key_mapping(model_wrappers)
      model_classes = model_wrappers.map{ |wrapper| wrapper.model_class }
      model_to_foreign_keys = {}
      model_classes.each do |model_class|
        model_to_foreign_keys[model_class] = []
      end

      model_to_model_wrapper = {}
      model_wrappers.each do |model_wrapper|
        model_to_model_wrapper[model_wrapper.model_class] = model_wrapper
      end

      model_to_relation_infos(model_classes).each do |model, relation_infos|
        SUPPORTED_ASSOCIATIONS.each do |association_type|

          associations = relation_infos[association_type]

          associations.each do |association|
            klass = self.class_with_foreign_key(association)

            # An association with a class that wasn't
            # included in our list of model_classes might be found.
            unless model_to_foreign_keys.keys.include?(klass)
              model_to_foreign_keys[klass] = []
            end

            association_hash = { :foreign_key => association.foreign_key,
                                 :class => model_to_model_wrapper[model].foreign_key_target_class(association) }

            unless model_to_foreign_keys[klass].include?(association_hash)
              model_to_foreign_keys[klass] << association_hash
            end
          end
        end

      end

      model_to_foreign_keys
    end

  end

end
