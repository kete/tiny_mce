# Require all the necessary files to run TinyMCE
require 'tiny_mce/base'
require 'tiny_mce/option_validator'
require 'tiny_mce/spell_checker'
require 'tiny_mce/helpers'

module TinyMCE
  module Base
    include TinyMCE::OptionValidator
    include TinyMCE::SpellChecker
  end
end

# Load up the available configuration options (we do it here because
# the result doesn't, so we don't want to load it per request)
TinyMCE::OptionValidator.load

# Include the TinyMCE methods and TinyMCE Helpers into ActionController::Base

if defined?(Rails) && defined?(ActionController)
  ActionController::Base.send(:include, TinyMCE::Base)
  ActionController::Base.send(:helper, TinyMCE::Helpers)
end
