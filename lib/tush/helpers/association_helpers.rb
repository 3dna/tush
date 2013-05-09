module Tush

  class AssociationHelpers

    def self.relation_infos(relation_type, model)
      model.reflect_on_all_associations(relation_type)
    end

  end

end
