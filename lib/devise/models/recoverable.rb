module Devise
  module Recoverable
    require 'devise/models/perishable'

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include ::Devise::Perishable
      end
    end

    # Update password
    #
    def reset_password(new_password, new_password_confirmation)
      self.password = new_password
      self.password_confirmation = new_password_confirmation
    end

    # Update password saving the record
    #
    def reset_password!(new_password, new_password_confirmation)
      reset_password(new_password, new_password_confirmation) and save
    end

    # Resets perishable token and send reset password instructions by email
    #
    def send_reset_password_instructions
      reset_perishable_token!
      ::Notifier.deliver_reset_password_instructions(self)
    end

    module ClassMethods

      # Attempt to find a user by it's email. If a record is found, send new
      # password instructions to it. If not user is found, returns a new user
      # with an email not found error.
      # Options must contain the user email
      #
      def send_reset_password_instructions(options={})
        recoverable = find_or_initialize_by_email(options[:email])
        unless recoverable.new_record?
          recoverable.send_reset_password_instructions
        else
          recoverable.errors.add(:email, :not_found, :default => 'not found')
        end
        recoverable
      end

      # Attempt to find a user by it's perishable_token to reset it's password.
      # If a user is found, reset it's password and automatically try saving the
      # record. If not user is found, returns a new user containing an error
      # in perishable_token attribute.
      # Options must contain perishable_token, password and confirmation
      #
      def reset_password!(options={})
        recoverable = find_or_initialize_with_error_by_perishable_token(options[:perishable_token])
        recoverable.reset_password!(options[:password], options[:password_confirmation]) unless recoverable.new_record?
        recoverable
      end
    end
  end
end
