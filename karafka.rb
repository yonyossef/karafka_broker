# karafka.rb

# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] = ENV['RAILS_ENV']
require ::File.expand_path('../config/environment', __FILE__)
Rails.application.eager_load!

# This lines will make Karafka print to stdout like puma or unicorn
if Rails.env.development?
  Rails.logger.extend(
    ActiveSupport::Logger.broadcast(
      ActiveSupport::Logger.new($stdout)
    )
  )
end

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka.seed_brokers = %w[kafka://127.0.0.1:9092]
    config.client_id = "karafka_example"
    config.backend = :inline
    config.batch_fetching = false
    # Uncomment this for Rails app integration
    # config.logger = Rails.logger
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate if you want to achieve max performance,
  # listen to only what you really need for a given environment.
  # Karafka.monitor.subscribe(Karafka::Instrumentation::StdoutListener)
  # Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener)

  consumer_groups.draw do
    consumer_group :example do
      batch_fetching false

      topic :users do
        consumer UsersConsumer
      end
    end
  end
end

Karafka.monitor.subscribe('app.initialized') do
  # Put here all the things you want to do after the Karafka framework
  # initialization
end

if Karafka::App.env.development?
  Karafka.monitor.subscribe(
    Karafka::CodeReloader.new(
      *Rails.application.reloaders
    )
  )
end

KarafkaApp.boot!