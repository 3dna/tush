require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'shoulda'
require 'pry'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tush'

require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

require 'support/schema'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

def test_root
  File.expand_path '../..', __FILE__
end
