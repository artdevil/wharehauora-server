# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :user,            'rails'
set :repo_url,        ENV['DEPLOY_URL']
set :application,     'wharehauora-server'

# Don't change these unless you know what you're doing
set :pty,             false
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{tmp/pids}
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, false
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :pumactl_roles, :app
set :sitemap_roles, :web
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

## Defaults:
# set :format,        :pretty
# set :log_level,     :debug
set :keep_releases, 5

# Bonus! Colors are pretty!
def red(str)
  "\e[31m#{str}\e[0m"
end

# Figure out the name of the current local branch
def current_git_branch
  branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
  puts "Deploying branch #{red branch}"
  branch
end

# Set the deploy branch to the current branch
set :branch, current_git_branch

namespace :puma do
  Rake::Task[:start].clear_actions
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs

  desc 'start application'
  task :start do
    on roles(:app) do
      invoke 'pumactl:restart'
    end
  end
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'pumactl:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'pumactl:restart'
    end
  end

  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
end

namespace :rails do
  desc "Remote console"
  task :console do
    on roles(:app), :primary => true do |h|
      run_interactively "RAILS_ENV=#{fetch(:rails_env)} bundle exec rails console"
    end
  end

  desc "Remote dbconsole"
  task :dbconsole do
    on roles(:app), :primary => true do |h|
      run_interactively "RAILS_ENV=#{fetch(:rails_env)} bundle exec rails dbconsole"
    end
  end

  def run_interactively(command)
    info "Running `#{command}` as rails@#{host}"
    exec %Q(ssh rails@#{host} -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && #{command}'")
  end
end

namespace :sensors_read do
  def sensors_read_pid
    "#{shared_path}/tmp/pids/sensors_read.pid"
  end

  def pid_file_exists?
    test(*("[ -f #{sensors_read_pid} ]").split(' '))
  end

  def pid_process_exists?
    pid_file_exists? and test(*("kill -0 $( cat #{sensors_read_pid} )").split(' '))
  end

  task :start do
    on roles(:app) do
      if !pid_process_exists?
        with RAILS_ENV: fetch(:environment) do
          within "#{fetch(:deploy_to)}/current/" do
            execute "cd #{fetch(:deploy_to)}/current/"
            execute "./scripts/sensor.sh #{fetch(:rails_env)} #{sensors_read_pid}"
          end
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      if pid_process_exists?
        execute "kill `cat #{sensors_read_pid}`"
        execute "rm #{sensors_read_pid}"
      end
    end
  end

  task :restart do
    on roles(:app) do
      invoke "sensors_read:stop"
      invoke "sensors_read:start"
    end
  end
end