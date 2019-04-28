# http://blog.blakesimpson.co.uk/read/80-sidekiq-tasks-for-capistrano-3
# after 'pumactl:restart', 'sidekiq:restart'

namespace :sidekiq do
  def sidekiq_pid
    "#{shared_path}/tmp/pids/sidekiq.pid"
  end

  def pid_file_exists?
    test(*("[ -f #{sidekiq_pid} ]").split(' '))
  end

  def pid_process_exists?
    pid_file_exists? and test(*("kill -0 $( cat #{sidekiq_pid} )").split(' '))
  end

  task :start do
    on roles(:app) do
      if !pid_process_exists?
        with RAILS_ENV: fetch(:environment) do
          within "#{fetch(:deploy_to)}/current/" do
            execute :bundle, :exec, "sidekiq -C config/sidekiq.yml -e #{fetch(:rails_env)} -L #{fetch(:deploy_to)}/shared/log/sidekiq.log -P #{sidekiq_pid} -d"
          end
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      if pid_process_exists?
        execute "kill `cat #{sidekiq_pid}`"
        execute "rm #{sidekiq_pid}"
      end
    end
  end

  task :restart do
    on roles(:app) do
      invoke "sidekiq:stop"
      invoke "sidekiq:start"
    end
  end
end