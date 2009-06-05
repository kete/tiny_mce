# The helper module we include into ActionController::Base
module TinyMCEHelpers

  # Setup a couple of Exception classes that we use later on
  class TinyMCEInvalidOption < Exception; end
  class TinyMCEInvalidOptionType < Exception; end

  # Has uses_tiny_mce method been declared in the controller for this page?
  def using_tiny_mce?
    !@uses_tiny_mce.blank?
  end

  # Parse @tiny_mce_options and @raw_tiny_mce_options to create a raw JS string
  # used by TinyMCE. Returns errors if the option or options type is invalid
	def raw_tiny_mce_init(options = {}, raw_options = '')
    # first we set some defaults, then we merge in the controller level options
    # and finally merge in the view level options (to give presidence)
	  @tiny_mce_options ||= {}
    default_options = { 'mode' => 'textareas',
                'editor_selector' => 'mceEditor',
                'theme' => 'simple',
                'language' => (defined?(I18n) ? I18n.locale : :en) }
    options = default_options.merge(@tiny_mce_options.stringify_keys).merge(options.stringify_keys)
    raw_options = @raw_tiny_mce_options + raw_options unless @raw_tiny_mce_options.nil?

    unless options['plugins'].nil?
      raise TinyMCEInvalidOptionType.new("Invalid value of type #{options['plugins'].class} passed for TinyMCE option plugins") unless options['plugins'].kind_of?(Array)
      
      # Append the plugins we have enabled for this field to the OptionsValidator
      TinyMCE::OptionValidator.plugins += options['plugins']
    end

    tinymce_js = "tinyMCE.init({\n"
    options.sort.each_with_index do |values, index|
      key, value = values[0], values[1]
      raise TinyMCEInvalidOption.new("Invalid option #{key} passed to tinymce") unless TinyMCE::OptionValidator.valid?(key)
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
        raise TinyMCEInvalidOptionType.new("Invalid value of type #{value.class} passed for TinyMCE option #{key}")
      end
      if (index < options.size - 1)
        # there are more options in this array
        tinymce_js += ",\n"
      else
        # no more options in this array. Finish it by adding the addition JS
        tinymce_js += ",\n#{raw_options}" unless raw_options.blank?
        tinymce_js += "\n"
      end
    end
    tinymce_js += "\n});"
	end

  # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
  def tiny_mce_init(options = {}, raw_options = '')
    javascript_tag raw_tiny_mce_init(options, raw_options)
  end
  # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
  # (only if tiny mce is actually being used)
  def tiny_mce_init_if_needed(options = {}, raw_options = '')
    tiny_mce_init(options, raw_options) if using_tiny_mce?
  end

  # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
  def include_tiny_mce_js
    javascript_include_tag (Rails.env.development? ? "tiny_mce/tiny_mce_src" : "tiny_mce/tiny_mce")
  end
  # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
  # (only if tiny mce is actually being used)
  def include_tiny_mce_js_if_needed
    include_tiny_mce_js if using_tiny_mce?
  end

  # Form a JS include tag for the TinyMCE JS src, and form the raw JS and wrap
  # in in a <script> tag for inclusion in the <head> for inclusion in the <head>
  # (only if tiny mce is actually being used)
  def include_tiny_mce_if_needed(options = {}, raw_options = '')
    if using_tiny_mce?
      include_tiny_mce_js + tiny_mce_init(options, raw_options)
    end
  end

end
