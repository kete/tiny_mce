VERSION = '3.2.0.2'

namespace :tiny_mce do
  desc 'Install the TinyMCE scripts into the public/javascripts directory of this application'
  task :install => ['tiny_mce:add_or_replace_tiny_mce']

  desc 'Update the TinyMCE scripts installed at public/javascripts/tiny_mce for this application'
  task :update => ['tiny_mce:add_or_replace_tiny_mce']

  task :add_or_replace_tiny_mce do
    require 'fileutils'
    dest = "#{RAILS_ROOT}/public/javascripts/tiny_mce"
    if File.exists?(dest)
      # upgrade
      begin
        puts "Removing directory #{dest}..."
        FileUtils.rm_rf dest
        puts "Recreating directory #{dest}..."
        FileUtils.mkdir_p dest
        puts "Installing TinyMCE version #{VERSION} to #{dest}..."
        FileUtils.cp_r "#{RAILS_ROOT}/vendor/plugins/tiny_mce/public/javascripts/tiny_mce/.", dest
        puts "Successfully updated TinyMCE to version #{VERSION}."
      rescue
        puts "ERROR: Problem updating TinyMCE. Please manually copy "
        puts "#{RAILS_ROOT}/vendor/plugins/tiny_mce/public/javascripts/tiny_mce"
        puts "to"
        puts "#{dest}"
      end
    else
      # install
      begin
        puts "Creating directory #{dest}..."
        FileUtils.mkdir_p dest
        puts "Installing TinyMCE version #{VERSION} to #{dest}..."
        FileUtils.cp_r "#{RAILS_ROOT}/vendor/plugins/tiny_mce/public/javascripts/tiny_mce/.", dest
        puts "Successfully installed TinyMCE version #{VERSION}."
      rescue
        puts "ERROR: Problem installing TinyMCE. Please manually copy "
        puts "#{RAILS_ROOT}/vendor/plugins/tiny_mce/public/javascripts/tiny_mce"
        puts "to"
        puts "#{dest}"
      end
    end
  end
end
