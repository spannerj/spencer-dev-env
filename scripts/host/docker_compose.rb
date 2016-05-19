require_relative 'utilities'

def prepare_compose(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the dependencies for all apps into an array, as their compose file argument
  dependency_list = []
  config["applications"].each do |appname, appconfig|
    # If this app is docker, add it's compose to the list
    if File.exists?("#{root_loc}/apps/#{appname}/docker-compose-fragment.yml")
      dependency_list.push("/vagrant/apps/#{appname}/docker-compose-fragment.yml")
    end
    # Load any dependencies into the docker compose list
    if appconfig.key?("dependencies")
      appconfig["dependencies"].each do |dependency|
        dependency_list.push("/vagrant/scripts/guest/docker/#{dependency}/docker-compose-fragment.yml")
      end
    end
  end

  # Remove duplicate dependencies
  dependency_list = dependency_list.uniq

  # Put the compose arguments into a file for later retrieval
  File.open("#{root_loc}/.docker-compose-file-list", 'w') {|f| f.write(dependency_list.join(":"))}
end
