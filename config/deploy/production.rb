server '206.189.93.219', port: 22, roles: [:web, :app, :db], primary: true

set :stage,     :production
set :branch,    :production
set :rails_env, :production
set :rack_env,  :production
set :puma_env,  :production
# set :rvm_custom_path, '/usr/local/rvm'
set :deploy_to, "/home/#{fetch(:user)}/apps/production/#{fetch(:application)}"
set :pumactl_config_file, "#{shared_path}/puma.rb"

set :pty, true
set :ssh_options, {
  forward_agent: true,
  user: 'rails',
  auth_methods: %w[publickey],
  keys: ENV['WHAREHAUORA_KEY_PEM']
}