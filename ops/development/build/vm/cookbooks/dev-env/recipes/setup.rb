include_recipe 'apt'
include_recipe 'tmux'
include_recipe 'chef-dk'
include_recipe 'java::oracle'
include_recipe 'dev-env::setup_docker-env'
include_recipe 'dev-env::setup_aws-env'
include_recipe 'dev-env::setup_mysql-env'
include_recipe 'dev-env::setup_ruby-env'