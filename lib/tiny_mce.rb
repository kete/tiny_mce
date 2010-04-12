# Require all the necessary files to run TinyMCE
require 'tiny_mce/base'
require 'tiny_mce/exceptions'
require 'tiny_mce/configuration'
require 'tiny_mce/spell_checker'
require 'tiny_mce/helpers'

module TinyMCE
  def self.initialize
    return if @intialized
    raise "ActionController is not available yet." unless defined?(ActionController)
    ActionController::Base.send(:include, TinyMCE::Base)
    ActionController::Base.send(:helper, TinyMCE::Helpers)
    TinyMCE.install_or_update_tinymce
    @intialized = true
  end

  def self.install_or_update_tinymce
    require 'fileutils'
    orig = File.join(File.dirname(__FILE__), 'tiny_mce', 'assets', 'tiny_mce')
    dest = File.join(Rails.root.to_s, 'public', 'javascripts', 'tiny_mce')
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

    tiny_mce_yaml_filepath = File.join(Rails.root.to_s, 'config', 'tiny_mce.yml')
    unless File.exists?(tiny_mce_yaml_filepath)
      File.open(tiny_mce_yaml_filepath, 'w') do |f|
        f.puts '# Here you can specify default options for TinyMCE across all controllers'
        f.puts '#'
        f.puts '# theme: advanced'
        f.puts '# plugins:'
        f.puts '#  - table'
        f.puts '#  - fullscreen'
      end
      puts "Written configuration example to #{tiny_mce_yaml_filepath}"
    end
  end

  module Base
    include TinyMCE::SpellChecker
  end
end

# Finally, lets include the TinyMCE base and helpers where
# they need to go (support for Rails 2 and Rails 3)
if defined?(Rails::Railtie)
  require 'tiny_mce/railtie'
else
  TinyMCE.initialize
end
