ActiveRecord::Schema.define do
	
  create_table :test_models, :force => true do |t|
  	t.integer :test_model_2_id
  	t.integer :test_model_3_id
  end

  create_table :test_model_2s, :force => true do |t|

  end

  create_table :test_model_3s, :force => true do |t|
  	t.integer :test_model_id
  end

  create_table :test_model_4s, :force => true do |t|
  	t.integer :test_model_id
  end

  create_table :test_model_5s, :force => true do |t|
  	t.integer :test_model_id
  end

end