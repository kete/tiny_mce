# Require all the necessary files to run TinyMCE
require 'tiny_mce/base'
require 'tiny_mce/option_validator'
require 'tiny_mce/spell_checker'
require 'tiny_mce/helpers'

module TinyMCE
  def self.install_or_update_tinymce
    require 'fileutils'
    orig = File.join(File.dirname(__FILE__), 'tiny_mce', 'assets', 'tiny_mce')
    dest = File.join(Rails.public_path, 'javascripts', 'tiny_mce')
    tiny_mce_js = File.join(dest, 'tiny_mce.js')

    unless File.exists?(tiny_mce_js) && FileUtils.identical?(File.join(orig, 'tiny_mce.js'), tiny_mce_js)
      if File.exists?(tiny_mce_js)
        # upgrade
        begin
          puts "Removing directory #{dest}..."
          FileUtils.rm_rf dest
          puts "Creating directory #{dest}..."
          FileUtils.mkdir_p dest
          puts "Copying TinyMCE to #{dest}..."
          FileUtils.cp_r "#{orig}/.", dest
          puts "Successfully updated TinyMCE."
        rescue
          puts 'ERROR: Problem updating TinyMCE. Please manually copy '
          puts orig
          puts 'to'
          puts dest
        end
      else
        # install
        begin
          puts "Creating directory #{dest}..."
          FileUtils.mkdir_p dest
          puts "Copying TinyMCE to #{dest}..."
          FileUtils.cp_r "#{orig}/.", dest
          puts "Successfully installed TinyMCE."
        rescue
          puts "ERROR: Problem installing TinyMCE. Please manually copy "
          puts orig
          puts "to"
          puts dest
        end
      end
    end
  end

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
  TinyMCE.install_or_update_tinymce
end
