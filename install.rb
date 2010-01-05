# Lets output something to the console when people use script/plugin to install tiny_mce
require File.join(File.dirname(__FILE__), 'init')

puts "-------"
TinyMCE.install_or_update_tinymce
puts ""
puts "To complete the process, please view README.rdoc."
puts "Read the section entitled 'Installation"
puts "-------"
