set :application, "everzealot"
set :repository,  "git@heroku.com:everzealot.git"

set :scm, :git

server "everzealot.com", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/apps/everzealot/"
set :user, "kinopyo"    
set :port, 9587

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end