module TinyMCE
  # The base module we include into ActionController::Base
  module Base
    # When this module is included, extend it with the available class methods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # The controller declaration to enable tiny_mce on certain actions.
      # Takes options hash, raw_options string, and any normal params you
      # can send to a before_filter (only, except etc)
      def uses_tiny_mce(options = {})

        configuration = if options.is_a? TinyMCE::Configuration
          options
        elsif options.respond_to?(:options) && options.respond_to?(:raw_options)
          TinyMCE::Configuration.new :options=>options.options,:raw_options=>options.raw_options
        elsif options.is_a? Hash
          tiny_mce_options = options.delete(:options) || {}
          raw_tiny_mce_options = options.delete(:raw_options) || ''
          TinyMCE::Configuration.new :options=>tiny_mce_options,:raw_options=>raw_tiny_mce_options
        else
          raise "Invalid option type #{options.class}"
        end
        # If the tiny_mce plugins includes the spellchecker, then form a spellchecking path,
        # add it to the tiny_mce_options, and include the SpellChecking module
        if configuration.has_plugins? && configuration.plugins_include?('spellchecker')
          configuration.options.reverse_merge!("spellchecker_rpc_url" => "/" + self.controller_name + "/spellchecker")
          self.class_eval do
            include TinyMCE::SpellChecker
          end
        end

        # Set instance vars in the current class
        proc = Proc.new do |c|
          configurations = c.instance_variable_get :@tiny_mce_configurations
          configurations ||= Array.new
          configurations << configuration
          c.instance_variable_set :@tiny_mce_configurations,configurations
          c.instance_variable_set(:@uses_tiny_mce, true)
        end

        # Run the above proc before each page load this method is declared in
        before_filter(proc, options)
      end

    end

  end
end
