# Lets output something to the console when people use script/plugin to install tiny_mce
puts <<-EOS
-------

tiny_mce plugin

Thanks for installing the tiny_mce plugin.

Complete the installation by running the following:

rake tiny_mce:install

Then to setup TinyMCE on your site, please view README.rdoc.

Read the section entitled 'Installation'

-------
EOS

filepath = File.join(RAILS_ROOT, 'config', 'tiny_mce.yml')
unless File.exists?(filepath)
  File.open(filepath, 'w') { |f| f.write '' }
end
