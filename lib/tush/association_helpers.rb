module Tush
  class AssociationHelpers
    def self.set_has_many
      associations = model.reflect_on_all_associations(:has_many)
      if associations.any?
      classes = associations.map(&:class_name)
      class_keys = associations.map(&:foreign_key)
      self.has_many = Hash[classes.zip(class_keys)]
    end 
    end

    def set_belongs_to 
      associations = model.reflect_on_all_associations(:belongs_to)
      if associations.any?
        self.belongs_to = associations.map(&:foreign_key)
      end
    end

    def set_has_one
      associations = model.reflect_on_all_associations(:has_one)
      if associations.any?
        classes = associations.map(&:class_name)
        class_keys = associations.map(&:foreign_key)
        self.has_one = Hash[classes.zip(class_keys)]
      end 
    end
  end
end