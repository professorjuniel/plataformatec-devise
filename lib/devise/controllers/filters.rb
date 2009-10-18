module Devise
  module Controllers
    module Filters

      def self.included(base)
        base.class_eval do
          helper_method :warden, :signed_in?,
                        *Devise.mappings.keys.map { |m| [:"current_#{m}", :"#{m}_signed_in?"] }.flatten
        end
      end

      # The main accessor for the warden proxy instance
      def warden
        request.env['warden']
      end

      # Attempts to authenticate the given scope by running authentication hooks,
      # but does not redirect in case of failures.
      def authenticate(scope)
        warden.authenticate(:scope => scope)
      end

      # Attempts to authenticate the given scope by running authentication hooks,
      # redirecting in case of failures.
      def authenticate!(scope)
        warden.authenticate!(:scope => scope)
      end

      # Check if the given scope is signed in session, without running
      # authentication hooks.
      def signed_in?(scope)
        warden.authenticated?(scope)
      end

      # Set the warden user with the scope, signing in the resource automatically,
      # without running hooks.
      def sign_in(scope, resource)
        warden.set_user(resource, :scope => scope)
      end

      # Sign out based on scope.
      def sign_out(scope, *args)
        warden.raw_session.inspect # Without this inspect here. The session does not clear.
        warden.logout(scope, *args)
      end

      # Define authentication filters and accessor helpers based on mappings.
      # These filters should be used inside the controllers as before_filters,
      # so you can control the scope of the user who should be signed in to
      # access that specific controller/action.
      # Example:
      #
      #   Maps:
      #     User => :authenticable
      #     Admin => :authenticable
      #
      #   Generated methods:
      #     authenticate_user!  # Signs user in or redirect
      #     authenticate_admin! # Signs admin in or redirect
      #     user_signed_in?     # Checks whether there is an user signed in or not
      #     admin_signed_in?    # Checks whether there is an admin signed in or not
      #     current_user        # Current signed in user
      #     current_admin       # Currend signed in admin
      #     user_session        # Session data available only to the user scope
      #     admin_session       # Session data available only to the admin scope
      #
      #   Use:
      #     before_filter :authenticate_user!  # Tell devise to use :user map
      #     before_filter :authenticate_admin! # Tell devise to use :admin map
      #
      Devise.mappings.each_key do |mapping|
        class_eval <<-METHODS, __FILE__, __LINE__
          def authenticate_#{mapping}!
            warden.authenticate!(:scope => :#{mapping})
          end

          def #{mapping}_signed_in?
            warden.authenticated?(:#{mapping})
          end

          def current_#{mapping}
            @current_#{mapping} ||= warden.user(:#{mapping})
          end

          def #{mapping}_session
            warden.session(:#{mapping})
          end
        METHODS
      end

    protected

      # Helper for use in before_filters where no authentication is required.
      #
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      def require_no_authentication
        redirect_to root_path if warden.authenticated?(resource_name)
      end

      # Checks whether it's a devise mapped resource or not.
      def is_devise_resource? #:nodoc:
        raise ActionController::UnknownAction unless devise_mapping && devise_mapping.allows?(controller_name)
      end

    end
  end
end
