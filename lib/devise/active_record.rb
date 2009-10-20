module Devise
  module ActiveRecord
    # Shortcut method for including all devise modules inside your model.
    # You can give some extra options while declaring devise in your model:
    #
    # * except: let's you add all devise modules, except the ones you setup here:
    #
    #    devise :all, :except => :rememberable
    #
    # * pepper: setup a pepper to generate de encrypted password. By default no
    #   pepper is used:
    #
    #    devise :all, :pepper => 'my_pepper'
    #
    # * stretches: configure how many times you want the password is reencrypted.
    #
    #    devise :all, :stretches => 20
    #
    # You can refer to Authenticable for more information about writing your own
    # method to setup pepper and stretches
    #
    # Examples:
    #
    #   # include only authenticable module (default)
    #   devise
    #
    #   # include authenticable + confirmable modules
    #   devise :confirmable
    #
    #   # include authenticable + recoverable modules
    #   devise :recoverable
    #
    #   # include authenticable + rememberable modules
    #   devise :rememberable
    #
    #   # include authenticable + validatable modules
    #   devise :validatable
    #
    #   # include authenticable + confirmable + recoverable + rememberable + validatable
    #   devise :confirmable, :recoverable, :rememberable, :validatable
    #
    #   # shortcut to include all modules (same as above)
    #   devise :all
    #
    #   # include all except recoverable
    #   devise :all, :except => :recoverable
    #
    def devise(*modules)
      options  = modules.extract_options!
      options.assert_valid_keys(:except, :stretches, :pepper)

      modules  = Devise::ALL             if modules.include?(:all)
      modules -= Array(options[:except]) if options.key?(:except)
      modules |= [:authenticable]

      modules.each do |m|
        devise_modules << m.to_sym
        include Devise::Models.const_get(m.to_s.classify)
      end

      if options.key?(:stretches) || options.key?(:pepper)
        class_eval <<-END_EVAL, __FILE__, __LINE__
          def stretches; #{options[:stretches]}; end if options.key?(:stretches)
          def pepper;   '#{options[:pepper]}';   end if options.key?(:pepper)
        END_EVAL
      end
    end

    # Stores all modules included inside the model, so we are able to verify
    # which routes are needed.
    def devise_modules
      @devise_modules ||= []
    end
  end
end
