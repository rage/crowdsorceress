# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
Sidekiq::Web.set :sessions,       Rails.application.config.session_options
