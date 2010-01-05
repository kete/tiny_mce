namespace :tiny_mce do

  desc 'Install (or updated if they alread exist) the TinyMCE sources'
  task :install => :environment do
    TinyMCE.install_or_update_tinymce
  end

end
