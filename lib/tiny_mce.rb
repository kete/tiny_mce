module TinyMCE
  def self.included(base)
    base.extend(ClassMethods)
    base.helper TinyMCEHelper
  end

  module ClassMethods
    def uses_tiny_mce(options = {})
      tiny_mce_options = options.delete(:options) || {}
      raw_tiny_mce_options = options.delete(:raw_options) || {}
      if !tiny_mce_options[:plugins].blank? && tiny_mce_options[:plugins].include?('spellchecker')
        tiny_mce_options.reverse_merge!(:spellchecker_rpc_url => "/" + self.controller_name + "/spellchecker")
        self.class_eval do
          include TinyMCE::SpellChecker
        end
      end
      proc = Proc.new do |c|
        c.instance_variable_set(:@tiny_mce_options, tiny_mce_options)
        c.instance_variable_set(:@raw_tiny_mce_options, raw_tiny_mce_options)
        c.instance_variable_set(:@uses_tiny_mce, true)
      end
      before_filter(proc, options)
    end
  end

  module OptionValidator
    class << self
      cattr_accessor :plugins

      def load
        @@valid_options = File.open(File.dirname(__FILE__) + "/../tiny_mce_options.yml") { |f| YAML.load(f.read) }
      end

      def valid?(option)
        option = option.to_s
        @@valid_options.include?(option) || (plugins && plugins.include?(option.split('_')[0])) || option =~ /theme_advanced_container_/
      end

      def options
        @@valid_options
      end
    end
  end

  module SpellChecker
    require 'net/https'
    require 'uri'
    require 'rexml/document'

    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

    # Attempt to determine where Aspell is
    # Might be slow and a horrible way to do it, but it works!
    aspell_path = nil
    ['/usr/bin/aspell', '/usr/local/bin/aspell'].each do |path|
      if File.exists?(path)
        aspell_path = path
        break
      end
    end
    ASPELL_PATH = aspell_path || "aspell" # fall back to a pathless call

    def spellchecker
      language, words, method = params[:params][0], params[:params][1], params[:method] unless params[:params].blank?
      return render :nothing => true if language.blank? || words.blank? || method.blank?
      headers["Content-Type"] = "text/plain"
      headers["charset"] = "utf-8"
      suggestions = check_spelling(words, method, language)
      results = {"id" => nil, "result" => suggestions, "error" => nil}
      render :json => results
    end

    def check_spelling(spell_check_text, command, lang)
      xml_response_values = Array.new
      spell_check_text = spell_check_text.join(' ') if command == 'checkWords'
      logger.debug("Spellchecking via:  echo \"#{spell_check_text}\" | #{ASPELL_PATH} -a -l #{lang}")
      spell_check_response = `echo "#{spell_check_text}" | #{ASPELL_PATH} -a -l #{lang}`
      return xml_response_values if spell_check_response.blank?
      spelling_errors = spell_check_response.split("\n").slice(1..-1)
      for error in spelling_errors
        error.strip!
        if (match_data = error.match(ASPELL_WORD_DATA_REGEX))
          if (command == 'checkWords')
            arr = match_data[0].split(' ')
            xml_response_values << arr[1]
          elsif (command == 'getSuggestions')
            xml_response_values << error.split(',')[1..-1].collect(&:strip!)
            xml_response_values = xml_response_values.first
          end
        end
      end
      return xml_response_values
    end
  end

end
