module Devise
  module OmniAuth
    class Config
      attr_accessor :strategy
      attr_reader :args

      def initialize(provider, args)
        @provider = provider
        @args     = args
        @strategy = nil
      end

      # open_id strategy can have configurable name
      def strategy_name
        options = @args.last.is_a?(Hash) && @args.last
        options && options[:name] ? options[:name] : @provider
      end

      def strategy_class
        # NOTE: this could be bad if a third-party plugin does not define its strategy 
        # under the OmniaAuth::Strategies namespace. May be better to search through 
        # OmniAuth.strategies instead of autoloading.
        ::OmniAuth::Strategies.const_get("#{::OmniAuth::Utils.camelize(@provider.to_s)}")
      end
    end
  end
end     
