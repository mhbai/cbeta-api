# config valid only for current version of Capistrano
lock '3.15.0'

set :application, 'cbdata14'
set :repo_url, 'git@gitlab.com:cbdata/cbdata13'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/secrets.yml', 'config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('data', 'public/download', 'public/help')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :restart do
    on roles(:web), in: :sequence do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end