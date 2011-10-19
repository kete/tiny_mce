module TinyMCE
  # The base module we include into ActionController::Base
  module Base
    # When this module is included, extend it with the available class methods
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def uses_tiny_mce(options = {})
        before_filter(options) do |controller|
          controller.send(:uses_tiny_mce, options)
        end
      end
    end

    module InstanceMethods
      # The controller declaration to enable tiny_mce on certain actions.
      # Takes options hash, raw_options string, and any normal params you
      # can send to a before_filter (only, except etc)
      def uses_tiny_mce(options = {})
        configuration = TinyMCE::Configuration.new(options.delete(:options), options.delete(:raw_options))

        # Include an option to load the main tiny_mce.js file if the app appears
        # to be using jquery. (And use uncompressed script in development)
        if configuration.uses_jquery?
          configuration.reverse_add_options( {:script_url => (Rails.env.to_s == 'development' ? "/javascripts/tiny_mce/tiny_mce_src.js" : "/javascripts/tiny_mce/tiny_mce.js")} )
        end


        # If the tiny_mce plugins includes the spellchecker, then form a spellchecking path,
        # add it to the tiny_mce_options, and include the SpellChecking module
        if configuration.plugins.include?('spellchecker')
          configuration.reverse_add_options("spellchecker_rpc_url" => "/" + self.controller_name + "/spellchecker")
          self.class_eval { include TinyMCE::SpellChecker }
        end

        # Set instance vars in the current class
        configurations = @tiny_mce_configurations || []
        configurations << configuration
        @tiny_mce_configurations = configurations
        @uses_tiny_mce = true
      end
    end
  end
end
