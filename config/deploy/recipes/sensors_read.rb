after 'pumactl:restart', 'sensors_read:restart'

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
        # https://stackoverflow.com/questions/10889621/launching-background-process-in-capistrano-task/34622311
        execute "cd #{release_path} && (nohup #{fetch(:rvm_path)}/bin/rvm default do bundle exec rake sensors:ingest BACKGROUND=true PIDFILE=#{sensors_read_pid} RAILS_ENV=#{fetch(:rails_env)} &) && sleep 1"
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

  task :logs do
    on roles(:app), :primary => true do |h|
      execute "tail -f #{release_path}/log/sensor.log"
    end
  end
end