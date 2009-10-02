require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'tiny_mce'
    gem.summary = %Q{TinyMCE editor for your rails applications}
    gem.description = %Q{Gem that allows easy implementation of the TinyMCE editor into your applications.}
    gem.email = 'kieran@katipo.co.nz'
    gem.homepage = 'http://github.com/kete/tiny_mce'
    gem.authors = ['Blake Watters', 'Kieran Pilkington', 'Sergio Cambra', 'Alexander Semyonov']
    gem.extra_rdoc_files = ['README.rdoc', 'SPELLCHECKING_PLUGIN.rdoc', 'CHANGELOG_PLUGIN.rdoc', 'DEV_UPGRADE_NOTES.rdoc']
    gem.rdoc_options << '--exclude=lib/tiny_mce/assets'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end



desc 'Default: run unit tests.'
task :default => :test

desc 'Test the tiny_mce plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the tiny_mce plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TinyMce'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Bump patch version and release to github and gemcutter"
task :bump => %w(version:bump:patch release gemcutter:release install)
