module TinyMCEHelper
  class InvalidOption < Exception
  end

  def using_tiny_mce?
    !@uses_tiny_mce.nil?
  end

	def raw_tiny_mce_init(options = @tiny_mce_options, additional_js = "")
    options ||= {}
    default_options = { :mode => 'textareas',
                        :editor_selector => 'mceEditor',
                        :theme => 'simple' }
    options = default_options.merge(options)
    TinyMCE::OptionValidator.plugins = options[:plugins]

    tinymce_js = "tinyMCE.init({\n"
    options.stringify_keys.sort.each_with_index do |values, index|
      key, value = values[0], values[1]
      raise InvalidOption.new("Invalid option #{key} passed to tinymce") unless TinyMCE::OptionValidator.valid?(key)
      tinymce_js += "#{key} : "
      case value
      when String, Symbol, Fixnum
        tinymce_js += "'#{value.to_s}'"
      when Array
        tinymce_js += '"' + value.join(',') + '"'
      when TrueClass
        tinymce_js += 'true'
      when FalseClass
        tinymce_js += 'false'
      else
        raise InvalidOption.new("Invalid value of type #{value.class} passed for TinyMCE option #{key}")
      end
      if (index < options.size - 1)
        # there are more options in this array
        tinymce_js += ",\n"
      else
        # no more options in this array. Finish it by adding the addition JS
        tinymce_js += ",\n#{additional_js}" unless additional_js.blank?
        tinymce_js += "\n"
      end
    end
    tinymce_js += "\n});"
	end

  def tiny_mce_init(options = @tiny_mce_options, additional_js = "")
    javascript_tag raw_tiny_mce_init(options, additional_js)
  end
  def tiny_mce_init_if_needed(options = @tiny_mce_options, additional_js = "")
    tiny_mce_init(options, additional_js) if using_tiny_mce?
  end

  def include_tiny_mce_js
    javascript_include_tag ((RAILS_ENV == 'development') ? "tiny_mce/tiny_mce_src" : "tiny_mce/tiny_mce")
  end
  def include_tiny_mce_js_if_needed
    include_tiny_mce_js if using_tiny_mce?
  end

  def include_tiny_mce_if_needed(options = @tiny_mce_options, additional_js = "")
    if using_tiny_mce?
      include_tiny_mce_js + tiny_mce_init(options, additional_js)
    end
  end
end
