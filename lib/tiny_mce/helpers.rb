module TinyMCE
  # The helper module we include into ActionController::Base
  module Helpers

    # Has uses_tiny_mce method been declared in the controller for this page?
    def using_tiny_mce?
      !@uses_tiny_mce.blank?
    end

    # Parse @tiny_mce_options and @raw_tiny_mce_options to create a raw JS string
    # used by TinyMCE. Returns errors if the option or options type is invalid
    def raw_tiny_mce_init(options = {}, raw_options = nil)
      tinymce_js = ""

      @tiny_mce_configurations ||= [Configuration.new]
      @tiny_mce_configurations.each do |configuration|
        configuration.add_options(options, raw_options)
        tinymce_js += "tinyMCE.init("
        tinymce_js += configuration.to_json
        tinymce_js += ");"
      end

      tinymce_js
    end

    # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
    def tiny_mce_init(options = {}, raw_options = nil)
      javascript_tag raw_tiny_mce_init(options, raw_options)
    end
    # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def tiny_mce_init_if_needed(options = {}, raw_options = nil)
      tiny_mce_init(options, raw_options) if using_tiny_mce?
    end

    # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
    def include_tiny_mce_js
      javascript_include_tag (Rails.env.to_s == 'development' ? "tiny_mce/tiny_mce_src" : "tiny_mce/tiny_mce")
    end
    # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def include_tiny_mce_js_if_needed
      include_tiny_mce_js if using_tiny_mce?
    end

    # Form a JS include tag for the TinyMCE JS src, and form the raw JS and wrap
    # in in a <script> tag for inclusion in the <head> for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def include_tiny_mce_if_needed(options = {}, raw_options = nil)
      if using_tiny_mce?
        include_tiny_mce_js + tiny_mce_init(options, raw_options)
      end
    end
  end
end
