include_recipe 'python'
include_recipe 'awscli'
include_recipe 'aws'

python_pip "awsebcli"
python_pip "--upgrade awsebcli"

bash "install Amazon ECS CLI" do
  code <<-EOC
    curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
    sudo chmod +x /usr/local/bin/ecs-cli
  EOC
  not_if {File.exists?("/usr/local/bin/ecs-cli")}
end
