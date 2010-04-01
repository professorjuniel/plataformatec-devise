require "action_controller/metal"

module Devise
  # Failure application that will be called every time :warden is thrown from
  # any strategy or hook. Responsible for redirect the user to the sign in
  # page based on current scope and mapping. If no scope is given, redirect
  # to the default_url.
  class FailureApp < ActionController::Metal
    include ActionController::RackDelegation
    include ActionController::UrlFor
    include ActionController::Redirecting

    def self.call(env)
      action(:respond).call(env)
    end

    def self.default_url_options(*args)
      ApplicationController.default_url_options(*args)
    end

    def respond
      if http_auth?
        self.status = 401
        self.headers["WWW-Authenticate"] = %(Basic realm=#{Devise.http_authentication_realm.inspect})
        self.content_type = request.format.to_s
        self.response_body = http_auth_body
      elsif action = warden_options[:recall]
        default_message :invalid
        env["PATH_INFO"] = attempted_path
        params.merge!(query_string_params)
        self.response = recall_controller.action(action).call(env)
      else
        scope = warden_options[:scope]
        store_location!(scope)
        redirect_to send(:"new_#{scope}_session_path", query_string_params)
      end
    end

  protected

    def message
      @message ||= warden.message || warden_options[:message] || default_message
    end

    def default_message(message=nil)
      @default_message = message if message
      @default_message ||= :unauthenticated
    end

    def http_auth?
      request.authorization
    end

    def http_auth_body
      body = if message.is_a?(Symbol)
        I18n.t "devise.sessions.#{message}", :default => message.to_s
      else
        message.to_s
      end

      method = :"to_#{request.format.to_sym}"
      {}.respond_to?(method) ? { :error => body }.send(method) : body
    end

    # Build the proper query string based on the given message.
    def query_string_params
      case message
      when Symbol
        { message => "true" }
      when String
        { :message => message }
      else
        {}
      end
    end

    def recall_controller
      "#{params[:controller].camelize}Controller".constantize
    end

    def warden
      env['warden']
    end

    def warden_options
      env['warden.options']
    end

    def attempted_path
      warden_options[:attempted_path]
    end

    # Stores requested uri to redirect the user after signing in. We cannot use
    # scoped session provided by warden here, since the user is not authenticated
    # yet, but we still need to store the uri based on scope, so different scopes
    # would never use the same uri to redirect.
    def store_location!(scope)
      session[:"#{scope}.return_to"] = attempted_path if request && request.get?
    end
  end
end
