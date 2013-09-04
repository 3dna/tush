require 'tush/model_store'
require 'tush/model_wrapper'
require 'tush/exporter'
require 'tush/importer'

module Tush

  SUPPORTED_ASSOCIATIONS = [:belongs_to,
                            :has_one,
                            :has_many]

  class << self
    attr_accessor(:disable_model_trace)
  end

end
