# apt-get -q -y install mysql-server-5.6=5.6.19-0ubuntu0.14.04.1
mysql_service 'default' do
  port '3306'
  version '5.6'
  initial_root_password 'password'
  action [:create, :start]
end