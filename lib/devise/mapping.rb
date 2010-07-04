module Devise
  # Responsible for handling devise mappings and routes configuration. Each
  # resource configured by devise_for in routes is actually creating a mapping
  # object. You can refer to devise_for in routes for usage options.
  #
  # The required value in devise_for is actually not used internally, but it's
  # inflected to find all other values.
  #
  #   map.devise_for :users
  #   mapping = Devise.mappings[:user]
  #
  #   mapping.name #=> :user
  #   # is the scope used in controllers and warden, given in the route as :singular.
  #
  #   mapping.as   #=> "users"
  #   # how the mapping should be search in the path, given in the route as :as.
  #
  #   mapping.to   #=> User
  #   # is the class to be loaded from routes, given in the route as :class_name.
  #
  #   mapping.modules  #=> [:authenticatable]
  #   # is the modules included in the class
  #
  class Mapping #:nodoc:
    attr_reader :singular, :plural, :path, :controllers, :path_names, :path_prefix, :class_name
    alias :name :singular

    # Loop through all mappings looking for a map that matches with the requested
    # path (ie /users/sign_in). If a path prefix is given, it's taken into account.
    def self.find_by_path(request)
      Devise.mappings.each_value do |mapping|
        route, extra = request.path_info.split("/")[mapping.segment_position, 2]
        next unless route

        if !extra && (format = request.params[:format])
          route.sub!(/\.#{format}$/, '')
        end
        return mapping if mapping.path == route.to_sym
      end
      nil
    end

    # Receives an object and find a scope for it. If a scope cannot be found,
    # raises an error. If a symbol is given, it's considered to be the scope.
    def self.find_scope!(duck)
      case duck
      when String, Symbol
        return duck
      when Class
        Devise.mappings.each_value { |m| return m.name if duck <= m.to }
      else
        Devise.mappings.each_value { |m| return m.name if duck.is_a?(m.to) }
      end

      raise "Could not find a valid mapping for #{duck}"
    end

    def initialize(name, options) #:nodoc:
      @plural   = (options[:as] ? "#{options.delete(:as)}_#{name}" : name).to_sym
      @singular = (options.delete(:singular) || @plural.to_s.singularize).to_sym

      @class_name = (options.delete(:class_name) || name.to_s.classify).to_s
      @ref = ActiveSupport::Dependencies.ref(@class_name)

      @path = (options.delete(:path) || name).to_sym
      @path_prefix = "/#{options.delete(:path_prefix)}/".squeeze("/")

      if @path_prefix =~ /\(.*\)/ && Devise.ignore_optional_segments != true
        raise ScriptError, "It seems that you are scoping devise_for with an optional segment #{@path_prefix.inspect} " <<
          "which Devise does not support. Please remove the optional segment or alternatively, if you are *sure* of " <<
          "what you are doing, you can set config.ignore_optional_segments = true in your devise initializer."
      end

      mod = options.delete(:module) || "devise"
      @controllers = Hash.new { |h,k| h[k] = "#{mod}/#{k}" }
      @controllers.merge!(options.delete(:controllers) || {})

      @path_names  = Hash.new { |h,k| h[k] = k.to_s }
      @path_names.merge!(:registration => "")
      @path_names.merge!(options.delete(:path_names) || {})
    end

    # Return modules for the mapping.
    def modules
      @modules ||= to.respond_to?(:devise_modules) ? to.devise_modules : []
    end

    # Gives the class the mapping points to.
    def to
      @ref.get
    end

    def strategies
      @strategies ||= STRATEGIES.values_at(*self.modules).compact.uniq.reverse
    end

    def routes
      @routes ||= ROUTES.values_at(*self.modules).compact.uniq
    end

    # Keep a list of allowed controllers for this mapping. It's useful to ensure
    # that an Admin cannot access the registrations controller unless it has
    # :registerable in the model.
    def allowed_controllers
      @allowed_controllers ||= begin
        canonical = CONTROLLERS.values_at(*self.modules).compact
        @controllers.values_at(*canonical)
      end
    end

    # Returns in which position in the path prefix devise should find the as mapping.
    def segment_position
      self.path_prefix.count("/")
    end

    # Returns fullpath for route generation.
    def fullpath
      @path_prefix + @path.to_s
    end

    def authenticatable?
      @authenticatable ||= self.modules.any? { |m| m.to_s =~ /authenticatable/ }
    end

    # Create magic predicates for verifying what module is activated by this map.
    # Example:
    #
    #   def confirmable?
    #     self.modules.include?(:confirmable)
    #   end
    #
    def self.add_module(m)
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{m}?
          self.modules.include?(:#{m})
        end
      METHOD
    end
  end
end
