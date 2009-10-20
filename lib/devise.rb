begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

module Devise
  ALL = [:authenticable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze
end

require 'devise/warden'
require 'devise/routes'

# Ensure to include Devise modules only after Rails initialization.
# This way application should have already defined Devise mappings and we are
# able to create default filters.
Rails.configuration.after_initialize do
  ActiveRecord::Base.extend Devise::ActiveRecord
end
