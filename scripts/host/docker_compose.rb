require_relative 'utilities'

def prepare_compose(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the apps into an array, as their compose file argument
  commodity_list = []
  if config["applications"]
      config["applications"].each do |appname, appconfig|
        # If this app is docker, add it's compose to the list
        if File.exists?("#{root_loc}/apps/#{appname}/fragments/docker-compose-fragment.yml")
          commodity_list.push("/vagrant/apps/#{appname}/fragments/docker-compose-fragment.yml")
        end
      end
  end

  # Load any commodities into the docker compose list
    commodities = YAML.load_file("#{root_loc}/.commodities.yml")
    if commodities.key?("commodities")
      commodities["commodities"].each do |commodity_info|
        unless commodity_info.eql? "adfs" # Special Case
          commodity_list.push("/vagrant/scripts/guest/docker/#{commodity_info}/docker-compose-fragment.yml")
        end
      end
    end

  # Put the compose arguments into a file for later retrieval
  File.open("#{root_loc}/.docker-compose-file-list", 'w') {|f| f.write(commodity_list.join(":"))}
end
