module TinyMCE
  class Configuration
    attr_accessor :options,:raw_options,:plugins
    
    DEFAULT_OPTIONS = { 'mode' => 'textareas',
                  'editor_selector' => 'mceEditor',
                  'theme' => 'simple',
                  'language' => (defined?(I18n) ? I18n.locale : :en) }
    
    def initialize combined_options={}
      @options = combined_options[:options] || {}
      @raw_options = combined_options[:raw_options] || ''      
      @plugins = Array.new
    end
    
    def self.load_valid_options
      @@valid_options = File.open(valid_options_path) { |f| YAML.load(f.read) }
    end
    
    def to_json options={},raw_options=''
      merged_options = DEFAULT_OPTIONS.merge(options.stringify_keys).merge(@options.stringify_keys)
      merged_raw_options = raw_options + @raw_options unless raw_options.nil?
      
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
      
      json_options << raw_options unless raw_options.blank?
      
      "{\n" + json_options*",\n" + "\n}"
    end
    
    protected
    def self.valid_options_path
      File.join(File.dirname(__FILE__),'valid_tinymce_options.yml')
    end
    
    def valid?(option)
      option = option.to_s
      @@valid_options.include?(option) ||
        (@plugins && @plugins.include?(option.split('_').first)) ||
        option =~ /^theme_advanced_container_\w+$/
    end

    # If we need to get the array of valid options, we can call this method
    def valid_options
      @@valid_options
    end

  end
end
