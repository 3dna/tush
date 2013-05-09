require 'helper'

describe Tush::AssociationHelpers do

  before :all do
    class Model1 < ActiveRecord::Base
      self.table_name = :table_one
      belongs_to :model_2
      has_one :model_3
      has_many :model_4
    end

    class Model2 < ActiveRecord::Base
      self.table_name = :table_three
    end

    class Model3 < ActiveRecord::Base
      self.table_name = :table_four
    end

    class Model4 < ActiveRecord::Base
      self.table_name = :table_five
    end

  end

  describe "#create_foreign_key_mapping" do

    it "" do
      model_to_foreign_keys =
        Tush::AssociationHelpers.create_foreign_key_mapping([Model1,
                                                             Model2,
                                                             Model3,
                                                             Model4])

      model_to_foreign_keys.should == { Model1 => [{ :foreign_key => "model_2_id",
                                                    :class => Model2 }],
                                        Model2 => [],
                                        Model3 => [{ :foreign_key => "model1_id",
                                                    :class => Model1 }],
                                        Model4 => [{ :foreign_key => "model1_id",
                                                    :class => Model1 }] }
    end

  end

end
