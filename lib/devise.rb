module Devise
  ALL = [:authenticatable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticatable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  STRATEGIES  = [:rememberable, :authenticatable].freeze
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  # Maps the messages types that comes from warden to a flash type.
  FLASH_MESSAGES = {
    :unauthenticated => :success,
    :unconfirmed => :failure
  }

  # Models configuration
  mattr_accessor :pepper, :stretches, :remember_for, :confirm_within

  # Mappings
  mattr_accessor :mappings
  self.mappings = {}

  class << self
    # Default way to setup Devise. Run script/generate devise_install to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
    end

    def mail_sender=(value) #:nodoc:
      ActiveSupport::Deprecation.warn "Devise.mail_sender= is deprecated, use Devise.mailer_sender instead"
      DeviseMailer.sender = value
    end

    # Sets the sender in DeviseMailer.
    def mailer_sender=(value)
      DeviseMailer.sender = value
    end
    alias :sender= :mailer_sender=

    # Sets warden configuration using a block that will be invoked on warden
    # initialization.
    #
    #  Devise.initialize do |config|
    #    config.confirm_within = 2.days
    #
    #    config.warden do |manager|
    #      # Configure warden to use other strategies, like oauth.
    #      manager.oauth(:twitter)
    #    end
    #  end
    def warden(&block)
      @warden_config = block
    end

    # Configure default url options to be used within Devise and ActionController.
    def default_url_options(&block)
      Devise::Mapping.metaclass.send :define_method, :default_url_options, &block
    end

    # A method used internally to setup warden manager from the Rails initialize
    # block.
    def configure_warden_manager(manager) #:nodoc:
      manager.default_strategies *Devise::STRATEGIES
      manager.failure_app = Devise::Failure
      manager.silence_missing_strategies!

      # If the user provided a warden hook, call it now.
      @warden_config.try :call, manager
    end
  end
end

require 'devise/warden'
require 'devise/rails'
