module TinyMCE
  class Configuration
    # We use this to combine options and raw_options into one class and validate 
    # whether options passed in by the users are valid tiny mce configuration settings. 
    # Also loads which options are valid, and provides an plugins attribute to allow 
    # more configuration options dynamicly

    attr_accessor :options,:raw_options,:plugins

    DEFAULT_OPTIONS = { 'mode' => 'textareas',
                  'editor_selector' => 'mceEditor',
                  'theme' => 'simple',
                  'language' => (defined?(I18n) ? I18n.locale : :en) }

    def initialize combined_options={}
      @options = combined_options[:options] || {}
      @options.stringify_keys!
      @raw_options = [combined_options[:raw_options]]
      @plugins = Array.new
    end

    # Parse the options file and load it into an array
    # (this method is called when tiny_mce is initialized - see init.rb)
    def self.load_valid_options
      @@valid_options = File.open(valid_options_path) { |f| YAML.load(f.read) }
    end

    # Merge additional options, but don't overwrite existing
    def reverse_merge_options options
      @options = options.merge(@options)
    end

    # Merge additional options and raw_options
    def add_options combined_options={}      
      options = combined_options[:options] || {}
      raw_options = combined_options[:raw_options]
      @options.merge!(options.stringify_keys)
      @raw_options << raw_options unless raw_options.blank?
    end

    def has_plugins?
      !@options.stringify_keys["plugins"].blank?
    end

    def plugins_include? plugin
      @options.stringify_keys["plugins"].include? plugin
    end

    # Validate and merge options and raw_options into a string
    # to be used for tinyMCE.init() in the raw_tiny_mce_init helper
    def to_json options={},raw_options=''
      merged_options = DEFAULT_OPTIONS.merge(options.stringify_keys).merge(@options.stringify_keys)

      unless merged_options['plugins'].nil?
        raise TinyMCEInvalidOptionType.invalid_type_of merged_options['plugins'],:for=>:plugins unless merged_options['plugins'].is_a?(Array)

        # Append the plugins we have enabled for this field to the OptionsValidator
        @plugins += merged_options['plugins']
      end

      json_options = []
      merged_options.each_pair do |key,value|
        raise TinyMCEInvalidOption.invalid_option key unless valid?(key)
        json_options << "#{key} : " + case value
        when String, Symbol, Fixnum
          "'#{value.to_s}'"
        when Array
          '"' + value.join(',') + '"'
        when TrueClass
          'true'
        when FalseClass
          'false'
        else
          raise TinyMCEInvalidOptionType.invalid_type_of value,:for=>:plugins
        end
      end

      json_options.sort!

      @raw_options.compact!
      json_options += @raw_options unless @raw_options.blank?
      json_options << raw_options unless raw_options.blank?

      "{\n" + json_options*",\n" + "\n\n}"
    end

    def self.valid_options_path
      File.join(File.dirname(__FILE__),'valid_tinymce_options.yml')
    end
    
    # Does the check to see if the option is valid. It checks the valid_options
    # array (see above), checks if the start of the option name is in the plugin list
    # or checks if it's an theme_advanced_container setting
    def valid?(option)
      option = option.to_s
      @@valid_options.include?(option) ||
        (@plugins && @plugins.include?(option.split('_').first)) ||
        option =~ /^theme_advanced_container_\w+$/
    end

    # If we need to get the array of valid options, we can call this method
    def self.valid_options
      @@valid_options
    end
  end
end
