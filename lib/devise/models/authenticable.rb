require 'digest/sha1'

module Devise
  module Models

    # Authenticable Module, responsible for encrypting password and validating
    # authenticity of a user while signing in.
    #
    # Configuration:
    #   pepper: encryption key used for creating encrypted password. Each time
    #           password changes, it's gonna be encrypted again, and this key
    #           is added to the password and salt to create a secure hash.
    #
    #   stretches: defines how many times the password will be encrypted.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module Authenticable
      mattr_accessor :pepper, :stretches

      # Pepper for encrypting password
      self.pepper = '23c64df433d9b08e464db5c05d1e6202dd2823f0'

      # Encrypt password as many times as possible
      self.stretches = 10

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          attr_reader :password
          attr_accessor :password_confirmation
          attr_accessible :email, :password, :password_confirmation
        end
      end

      def password=(new_password)
        @password = new_password
        self.password_salt = friendly_token
        self.encrypted_password = password_digest(@password)
      end

      # Verifies whether an incoming_password (ie from login) is the user password
      #
      def valid_password?(incoming_password)
        password_digest(incoming_password) == encrypted_password
      end

      private

        # Gererates a default password digest based on salt, pepper and the
        # incoming password
        #
        def password_digest(password_to_digest)
          digest = pepper
          stretches.times { digest = secure_digest(password_salt, digest, password_to_digest, pepper) }
          digest
        end

        # Generate a SHA1 digest joining args. Generated token is something like
        #
        #   --arg1--arg2--arg3--argN--
        #
        def secure_digest(*tokens)
          ::Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
        end

        # Generate a friendly string randomically to be used as token
        #
        def friendly_token
          ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
        end

      module ClassMethods

        # Authenticate a user based on email and password. Returns the
        # authenticated user if it's valid or nil.
        # Attributes are :email and :password
        #
        def authenticate(attributes={})
          authenticable = self.find_by_email(attributes[:email])
          authenticable if authenticable.try(:valid_password?, attributes[:password])
        end
      end
    end
  end
end
