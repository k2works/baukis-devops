include_recipe 'python'

docker_service 'default' do
  action [:create, :start]
end

bash "install docker-compose" do
  code <<-EOC
    curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOC
  not_if {File.exists?("/usr/local/bin/docker-compose")}
end

bash "install docker-machine" do
  code <<-EOC
    curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
  EOC
  not_if {File.exists?("/usr/local/bin/docker-machine")}
end

if node['etc']['passwd']['vagrant']
  group 'docker' do
    action [:modify]
    members ['vagrant']
    append true
  end
end
