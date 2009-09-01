module TinyMCE
end

# Require all the necessary files to run TinyMCE
require 'tiny_mce/controller.rb'
require 'tiny_mce/options_validator'
require 'tiny_mce/spellchecker'
require 'tiny_mce/helpers'

# Load up the available configuration options (we do it here because
# the result doesn't, so we don't want to load it per request)
TinyMCE::OptionValidator.load

# Include the TinyMCE methods and TinyMCE Helpers into ActionController::Base

if defined?(Rails) && defined?(ActionController)
  ActionController::Base.send(:include, TinyMCE::Controller)
  ActionController::Base.send(:helper, TinyMCEHelpers)
end
