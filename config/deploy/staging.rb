server '104.248.153.164', port: 22, roles: [:web, :app, :db], primary: true

set :stage,     :staging
set :branch,    :master
set :rails_env, :staging
set :rack_env,  :staging
set :puma_env,  :staging
set :rvm_custom_path, '/usr/local/rvm'
set :deploy_to, "/home/#{fetch(:user)}/apps/staging/#{fetch(:application)}"
set :pumactl_config_file, "#{shared_path}/puma.rb"

set :pty, true
set :ssh_options, {
  forward_agent: true,
  user: 'rails',
  auth_methods: %w[publickey],
  keys: ENV['WHAREHAUORA_STAGING_KEY_PEM']
}