set :application, "everzealot"
set :user, "kinopyo"
set :repository,  "git@github.com:kinopyo/everzealot.git"

set :port, 9587

set :deploy_to, "/var/www/apps/#{application}"

set :scm, :git
set :normalize_asset_timestamps, false
server "everzealot.com", :app, :web, :db, :primary => true
