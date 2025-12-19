require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Soat4KitchenService
  class Application < Rails::Application
    # config.autoload_paths += %W[
    #  #{config.root}/app/domain
    #  #{config.root}/app/domain/production
    #  #{config.root}/app/domain/use_cases
    #  #{config.root}/app/infrastructure
    #  #{config.root}/app/infrastructure/persistence
    #  #{config.root}/app/infrastructure/messaging
    #  #{config.root}/app/infrastructure/workers
    # ]

    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :sidekiq
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
