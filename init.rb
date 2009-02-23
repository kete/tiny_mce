# Require all the necessary files to run TinyMCE
require 'tiny_mce'
require 'options_validator'
require 'spellchecker'
require 'tiny_mce_helpers'

# Load up the available configuration options (we do it here because
# the result doesn't, so we don't want to load it per request)
TinyMCE::OptionValidator.load

# Include the TinyMCE methods and TinyMCE Helpers into ActionController::Base
ActionController::Base.send(:include, TinyMCE)
ActionController::Base.send(:helper, TinyMCEHelpers)
