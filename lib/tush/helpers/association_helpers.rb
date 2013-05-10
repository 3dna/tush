module Tush

  class AssociationHelpers

    def self.relation_infos(relation_type, model)
      model.reflect_on_all_associations(relation_type)
    end

    def self.model_to_relation_infos(models)
      model_to_relation_infos_hash = {}

      models.each do |model|
        model_to_relation_infos_hash[model] = {}
        SUPPORTED_ASSOCIATIONS.each do |association_type|
          model_to_relation_infos_hash[model][association_type] =
            self.relation_infos(association_type, model)
        end
      end

      model_to_relation_infos_hash
    end

    def self.create_foreign_key_mapping(models)
      model_to_foreign_keys = {}
      models.each do |model|
        model_to_foreign_keys[model] = []
      end

      model_to_relation_infos(models).each do |model, relation_infos|
        SUPPORTED_ASSOCIATIONS.each do |association_type|

          associations = relation_infos[association_type]

          associations.each do |association|
            klass = if association_type == :belongs_to
                      model
                    else
                      association.class_name.constantize
                    end

            unless model_to_foreign_keys[klass].include?(association.foreign_key)
              class_for_foreign_key = if association_type == :belongs_to
                                        association.class_name.constantize
                                      else
                                        model
                                      end
              association_hash = { :foreign_key => association.foreign_key,
                                   :class => class_for_foreign_key }

              model_to_foreign_keys[klass] << association_hash
            end
          end
        end
      end

      model_to_foreign_keys
    end

  end

end
