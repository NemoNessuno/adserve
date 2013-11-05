# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require_relative 'spec_constants'
require_relative '../app/helpers/campaigns_helper.rb'
require 'capybara/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  
  # Allow Access to paths 
  config.include Rails.application.routes.url_helpers
  
  # Add support for the Capybara DSL
  config.include Capybara::DSL

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

class TestCouchbaseServer
  attr_accessor :host, :port, :num_nodes

  def initialize(params = {})
#    @host, @port = ENV['COUCHBASE_SERVER'].split(':')
    @host = "127.0.0.1"
    @port = 8091
#    @port = @port.to_i

    if @host.nil? || @host.empty? || @port == 0
      raise ArgumentError, "Check COUCHBASE_SERVER variable. It should be hostname:port"
    end
  end

  def start
    # flush testbucket
    connection = Couchbase.new(:hostname => @host,
                               :port => @port,
                               :bucket => "testadserve")
    
    i = 0
    while i < 11 do
      begin
        i = i + 1
        connection.flush
        break
      rescue
        sleep(1.0)
      end
    end

    connection.set("categories", YAML.load_file("#{File.expand_path('../', __FILE__)}/categories.yml"))
    connection.disconnect
  end
end


