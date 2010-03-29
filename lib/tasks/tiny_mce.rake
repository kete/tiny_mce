namespace :tiny_mce do

  desc 'Install or update the TinyMCE sources'
  task :install => :environment do
    TinyMCE.install_or_update_tinymce
  end

end
