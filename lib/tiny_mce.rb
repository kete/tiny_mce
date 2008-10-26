require 'net/https'
require 'uri'
require 'rexml/document'
  
module TinyMCE
  module ClassMethods
		ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)
	  ASPELL_PATH = "aspell"
    
    def uses_tiny_mce(options = {})
      tiny_mce_options = (options.delete(:options) || {}).clone

      proc = Proc.new do |c|
        c.instance_variable_set(:@tiny_mce_options, tiny_mce_options.reverse_merge(:spellchecker_rpc_url => "/" + self.controller_name + "/spellchecker"))
        c.instance_variable_set(:@uses_tiny_mce, true)
      end
      before_filter(proc, options)

      self.class_eval do
	      def spellchecker
	        return render :nothing => true if params[:params].blank? || params[:params][1].blank? || params[:params][0].blank? || params[:method].blank?
	        puts "params: #{params.inspect}"
	        headers["Content-Type"] = "text/plain"
	        headers["charset"] = "utf-8"
	        suggestions = check_spelling(params[:params][1], params[:method], params[:params][0])
	        results = {"id" => nil, "result" => suggestions, "error" => nil}
	        render :json => results
	      end
	
			  def check_spelling(spell_check_text, command, lang)
			    xml_response_values = Array.new
			    spell_check_text = spell_check_text.join(' ') if command == 'checkWords'
			    spell_check_response = `echo "#{spell_check_text}" | #{ASPELL_PATH} -a -l #{lang}`
			    if (spell_check_response != '')
			      spelling_errors = spell_check_response.split("\n").slice(1..-1)
			      if (command == 'checkWords')
			        for error in spelling_errors
			          error.strip!
			          if (match_data = error.match(ASPELL_WORD_DATA_REGEX))
			            arr = match_data[0].split(' ')
			            xml_response_values << arr[1]
			          end 
			        end 
			      elsif (command == 'getSuggestions') 
			        for error in spelling_errors 
			          error.strip! 
			          if (match_data = error.match(ASPELL_WORD_DATA_REGEX)) 
			            xml_response_values << error.split(',')[1..-1].collect(&:strip!)
			            xml_response_values = xml_response_values.first
			          end
			        end 
			      end 
			    end 
			    return xml_response_values
			  end 
      end
    end

    alias uses_text_editor uses_tiny_mce
      
    def self.included(recipient)
      recipient.extend(InstanceMethods)
    end
  end
  
  module OptionValidator
    class << self
      cattr_accessor :plugins
      
      def load
        @@valid_options = File.open(File.dirname(__FILE__) + "/../tiny_mce_options.yml") { |f| YAML.load(f.read) }
      end
      
      def valid?(option)
        @@valid_options.include?(option.to_s) || (plugins && plugins.include?(option.to_s.split('_')[0])) || option.to_s =~ /theme_advanced_container_/
      end
    
      def options
        @@valid_options
      end
    end
  end
  


  def self.included(base)
    base.extend(ClassMethods)
    base.helper TinyMCEHelper
  end
end
