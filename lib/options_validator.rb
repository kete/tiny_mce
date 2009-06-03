# The base module we include into ActionController::Base
module TinyMCE
  # We use this to validate whether options passed in by the users are valid
  # tiny mce configuration settings. Also loads which options are valid, and
  # provides an plugins attribute to allow more configuration options dynamicly
  module OptionValidator
    class << self

      # Used to set the array of plugins being used
      cattr_accessor :plugins

      # Parse the options file and load it into an array
      # (this method is called when tiny_mce is initialized - see init.rb)
      def load
        @@valid_options = File.open(File.dirname(__FILE__) + "/../tiny_mce_options.yml") { |f| YAML.load(f.read) }
        self.plugins = Array.new
      end

      # Does the check to see if the option is valid. It checks the valid_options
      # array (see above), checks if the start of the option name is in the plugin list
      # or checks if it's an theme_advanced_container setting
      def valid?(option)
        option = option.to_s
        @@valid_options.include?(option) ||
          (plugins && plugins.include?(option.split('_')[0])) ||
          option =~ /^theme_advanced_container_\w+$/
      end

      # If we need to get the array of valid options, we can call this method
      def options
        @@valid_options
      end
    end
  end
end
