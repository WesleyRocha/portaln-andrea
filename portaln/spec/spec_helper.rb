# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'webrat'          

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

# ================================================================================================
# Webrat configuration
# ================================================================================================
     
Webrat.configure do |config|
  config.mode = :rails
end

# ================================================================================================
# Spec configuration
# ================================================================================================

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true # true = nao mantem dados no banco; false = mantem
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  config.global_fixtures = :users
  
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
  ActionController::IntegrationTest.fixture_path = "#{RAILS_ROOT}/spec/fixtures"
  
  config.before(:each) do
    FileUtils.rm_rf('public/system')
  end                             
  
end      

# ================================================================================================
# RSpec Configuration
# ================================================================================================

module Spec::Rails::Example
  class IntegrationExampleGroup < ActionController::IntegrationTest
    def initialize(defined_description, options={}, &implementation)
      defined_description.instance_eval do
        def to_s
          self
        end
      end
           
      super(defined_description)
    end
 
    Spec::Example::ExampleGroupFactory.register(:integration, self)
  end
end
 
# ================================================================================================
# Metodos utilitarios
# ================================================================================================

def imagem_test_path
  File.expand_path(File.join(File.dirname(__FILE__),'..','spec','resources', 'default_img.png'))
end

# ================================================================================================
# Inicializa a fabrica de modelos (http://github.com/thoughtbot/factory_girl)
# ================================================================================================

FactoriesBuilder.load












