ActiveRecord::Schema.define do

  # Tables for exporter_spec.rb

  create_table :jasons, :force => true do |t|
  end

  create_table :kumies, :force => true do |t|
    t.integer :jason_id
  end

  # Tables for importer_spec.rb

  create_table :bretts, :force => true do |t|
    t.integer :kai_id
    t.string :sample_data
  end

  create_table :kais, :force => true do |t|
    t.string :sample_data
  end

  create_table :byrons, :force => true do |t|
    t.integer :kai_id
    t.string :sample_data
  end

  # Tables for model_wrapper_spec.rb

  create_table :rays, :force => true do |t|
  end

  create_table :alexes, :force => true do |t|
    t.integer :ray_id
  end

  # Tables for importer_spec.rb

  create_table :laurens, :force => true do |t|
    t.integer :dan_id
    t.string :sample_data
  end

  create_table :davids, :force => true do |t|
    t.integer :lauren_id
    t.integer :charlie_id
    t.string :sample_data
  end

  create_table :charlies, :force => true do |t|
    t.integer :lauren_id
    t.string :sample_data
  end

  create_table :dans, :force => true do |t|
    t.string :sample_data
  end

end
