namespace :tiny_mce do

  desc 'Install or update the TinyMCE sources'
  task :install => :environment do
    TinyMCE.install_or_update_tinymce
  end
  
  namespace :new do
    
    desc 'Generate TinyMCE language files LANG=name'
    task :lang do
      
      require 'fileutils'
      
      env_lang = ENV['LANG']
      
      puts "---------------------------------------------------------------------------------------"
      puts "\t\t TinyMCE Language Basic Generator"
      puts "---------------------------------------------------------------------------------------"
      
      unless env_lang.empty?
        
        
        lib_tinymce = File.join(File.dirname(__FILE__), '../', 'tiny_mce')
        file_valid_langs_path = "#{lib_tinymce}/valid_tinymce_langs.yml"
        file = File.open(file_valid_langs_path)
        yml_langs = YAML::load(file)
        
        unless yml_langs.include?(env_lang)
          yml_langs << env_lang
          yml_langs.sort!
        
          #writing new language to valid_tinymce_langs.yml
          File.open(file_valid_langs_path, 'w') do |f|
            f << "#\n# For more information about available languages, see\n"
            f <<  "# http://tinymce.moxiecode.com/download_i18n.php\n"
            f << "# Should only include a list of completed translations (not incomplete ones which most are :-( )\n#\n\n"
            f << YAML.dump(yml_langs).to_s
          end
           #start to copy en files to new lang
            puts "Generated \"en\" lang copies, translate this files:"
            puts "---------------------------------------------------------------------------------------"
            puts " REMEMBER TO CHANGE ALL THIS FILES."
            puts "IF YOU WANT TO TRANSLATE AN ESPECIFIC PLUGIN GO TO plugin/langs AND ADD YOUR LANG\n\n"
            
        else
          puts "\n\n\t\tLanguage exists on configuration file.\n\n" 
        end
        
        assets_path = "#{lib_tinymce}/assets/tiny_mce" 
        unless File.exists?("#{assets_path}/langs/#{env_lang}.js")
          puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/langs/#{env_lang}.js"
          FileUtils.cp("#{assets_path}/langs/en.js", "#{assets_path}/langs/#{env_lang}.js") 
        end
        unless File.exists?("#{assets_path}/themes/advanced/langs/#{env_lang}.js")
          puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/advanced/langs/#{env_lang}.js"
          FileUtils.cp("#{assets_path}/themes/advanced/langs/en.js", "#{assets_path}/themes/advanced/langs/#{env_lang}.js") 
        end
       unless File.exists?("#{assets_path}/themes/advanced/langs/#{env_lang}_dlg.js")
          puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/advanced/langs/#{env_lang}_dlg.js"
          FileUtils.cp("#{assets_path}/themes/advanced/langs/en_dlg.js", "#{assets_path}/themes/advanced/langs/#{env_lang}_dlg.js")
        end
        unless File.exists?("#{assets_path}/themes/simple/langs/#{env_lang}.js")
          puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/simple/langs/#{env_lang}_dlg.js"
          FileUtils.cp("#{assets_path}/themes/simple/langs/en.js", "#{assets_path}/themes/simple/langs/#{env_lang}.js") 
        end
        
        puts "---------------------------------------------------------------------------------------"
        
      else
        puts "You must set the LANG environment. example: rake tiny_mce:new:lang LANG=pt-BR"
      end
    end
  end

end
