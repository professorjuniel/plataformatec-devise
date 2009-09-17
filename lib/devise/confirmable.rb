module Devise
  module Confirmable

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        before_create :generate_confirmation_token
      end
    end

    # Confirm a user by setting it's confirmed_at to actual time. If the user
    # is already confirmed, add en error to email field
    #
    def confirm!
      unless confirmed?
        update_attribute(:confirmed_at, Time.now)
      else
        errors.add(:email, :already_confirmed, :default => 'already confirmed')
        false
      end
    end

    # Verifies whether a user is confirmed or not
    #
    def confirmed?
      !new_record? && confirmed_at?
    end

    private

      # Generates a new random token for confirmation, based on actual Time and salt
      #
      def generate_confirmation_token
        self.confirmation_token = secure_digest(Time.now.utc, random_string, password)
      end

    module ClassMethods

      # Find a user by it's confirmation token and try to confirm it.
      # If no user is found, returns a new user
      # If the user is already confirmed, create an error for the user
      def find_and_confirm(confirmation_token)
        user = find_or_initialize_by_confirmation_token(confirmation_token)
        unless user.new_record?
          user.confirm!
        else
          user.errors.add(:confirmation_token, :invalid, :default => "invalid confirmation")
        end
        user
      end
    end
  end
end

