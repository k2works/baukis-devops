# For Emacs
%w{
  build-essential
  texinfo
  libx11-dev
  libxpm-dev
  libjpeg-dev
  libpng-dev
  libgif-dev
  libtiff-dev
  libgtk2.0-dev
  libncurses-dev
}.each do |package|
  package "#{package}" do
    action :install
  end
end

# For Rails
%w{
  nodejs
  sqlite3
  libmysqlclient-dev
  libsqlite3-dev
  libxslt-dev
  libxml2-dev
  imagemagick
  ruby-dev
}.each do |package|
  package "#{package}" do
    action :install
  end
end

# MySQL
# mysql -h0.0.0.0 -uroot -ppassword
# GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
# flush privileges;