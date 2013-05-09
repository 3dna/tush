ActiveRecord::Schema.define do

  # Tables for model_store_spec.rb

  create_table :table_one, :force => true do |t|
    t.integer :table_2_id
    t.integer :table_3_id
  end

  create_table :table_two, :force => true do |t|
  end

  create_table :table_three, :force => true do |t|
    t.integer :table_id
  end

  create_table :table_four, :force => true do |t|
    t.integer :table_id
  end

  create_table :table_five, :force => true do |t|
    t.integer :table_id
  end

  # Tables for model_wrapper_spec.rb

  create_table :table_six, :force => true do |t|
  end

  create_table :table_seven, :force => true do |t|
    t.integer :model1_id
  end

end
