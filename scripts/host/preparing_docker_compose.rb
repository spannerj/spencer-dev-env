require File.dirname(__FILE__)+'/utilities'

def prepare_compose(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  dependency_list = []
  config["applications"].each do |appname, appconfig|
    dependency_list.push(*appconfig["dependencies"])
  end

  docker_compose = YAML::load_file("#{root_loc}/scripts/guest/docker/docker-compose.template")

  #Remove duplicate dependencies
  dependency_list = dependency_list.uniq

  dependency_list.each do |dependency|
    if dependency == "postgres"
      postgres = {}
      docker_compose["services"]["postgres"] = postgres
      postgres["container_name"] = "postgres"
      postgres["build"] = "/vagrant/scripts/guest/docker/postgres"
      postgres["ports"] = ["5432:5432"]
    end
  end

  File.open("#{root_loc}/scripts/guest/docker/docker-compose.yml", 'w') {|f| f.write docker_compose.to_yaml } #Store
end

#If this script is run directly
if __FILE__ == $0
  prepare_compose(File.dirname(__FILE__) + "../../")
end
