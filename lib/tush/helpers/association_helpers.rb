module Tush

  class AssociationHelpers

    def self.relation_infos(relation_type, model)
      model.reflect_on_all_associations(relation_type)
    end

    def self.model_to_relation_infos(models)
      model_to_relation_infos = {}

      models.each do |model|
        model_to_relation_infos[model] =
          { :belongs_to => self.relation_infos(:belongs_to, model),
            :has_one => self.relation_infos(:has_one, model),
            :has_many => self.relation_infos(:has_many, model) }
      end

      model_to_relation_infos
    end

    # { ClassName => [:foreign_key_1, ...], ...}
    def self.create_foreign_key_mapping(models)
      model_to_foreign_keys = {}
      models.each do |model|
        model_to_foreign_keys[model] = []
      end

      model_to_relation_infos(models).each do |model, relation_infos|
        [:belongs_to, :has_one, :has_many].each do |association_type|

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
