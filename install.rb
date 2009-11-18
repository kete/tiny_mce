# Lets output something to the console when people use script/plugin to install tiny_mce
puts "-------"
puts "tiny_mce plugin"
puts ""
puts "Thanks for installing the tiny_mce plugin."
puts "To complete the process, please view README.rdoc."
puts "Read the section entitled 'Installation"
puts "-------"

filepath = File.join(RAILS_ROOT, 'config', 'tiny_mce.yml')
unless File.exists?(filepath)
  File.open(filepath, 'w') { |f| f.write '' }
end