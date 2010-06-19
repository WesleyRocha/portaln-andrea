# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "pg",                :version => "~> 0.8.0"
  config.gem "devise",            :version => "~> 1.0.4"
  config.gem "stringex",          :version => '~> 1.1.0'
  config.gem "will_paginate",     :version => '~> 2.3.12'
  config.gem "paperclip"                               
  config.gem "mime-types",        :version => "~> 1.16",
                                  :lib     => 'mime/types'
  config.gem "workflow",          :version => '~> 0.3.0'
  config.gem "aegis",             :version => '~> 1.1.7',  
                                  :source  => 'http://gemcutter.org'
                                 
  config.gem "thinking-sphinx",   :version => '~> 1.3.11', 
                                  :source  => "http://gemcutter.org", 
                                  :lib     => 'thinking_sphinx'
                                 
  config.gem "delayed_job",       :version => '<2'
                                 
  config.gem "ts-delayed-delta",  :version => '~> 1.0.4', 
                                  :source  => 'http://gemcutter.org', 
                                  :lib     => 'thinking_sphinx/deltas/delayed_delta'
  
  config.gem "factory_girl",      :version => '~> 1.2.4',  
                                  :source  => "http://gemcutter.org"
                                 
  config.gem "tlsmail",           :version => '~> 0.0.1'

  config.gem "rmagick",           :version => '~> 2.13.1'
  
  # Agendador de tarefas via cron
  config.gem "whenever",          :version => '~> 0.4.2'
  
  config.gem 'sitemap_generator', :version => '~> 0.3.3',
                                  :lib => false
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
                            
  # Email
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_content_type = "text/html"
  config.action_mailer.default_charset = "utf-8"
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    :domain          => "portaln.com",
    :address         => 'smtp.gmail.com',
    :port            => 587,
    :tls             => true,
    :authentication  => :login,
    :user_name       => '',
    :password        => ''
  }

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'UTC'
  config.time_zone = 'Brasilia'
  config.active_record.default_timezone = 'Brasilia'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.i18n.default_locale = :pt_BR
end

require 'tlsmail'
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)