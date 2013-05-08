require 'active_record'

class TestModel < ActiveRecord::Base
  belongs_to :test_model_2
  belongs_to :test_model_3
  has_many :test_model_4
  has_one :test_model_5
end

class TestModel2 < ActiveRecord::Base

end

class TestModel3 < ActiveRecord::Base

end

class TestModel4 < ActiveRecord::Base

end

class TestModel5 < ActiveRecord::Base

end