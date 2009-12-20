require 'devise/hooks/activatable'

module Devise
  module Models
    # This module implements the default API required in activatable hook. 
    module Activatable
      def active?
        raise NotImplementedError
      end

      def inactive_message
        :inactive
      end
    end
  end
end