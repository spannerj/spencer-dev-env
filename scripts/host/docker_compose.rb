require_relative 'utilities'

def prepare_compose(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the commodities for all apps into an array, as their compose file argument
  commodity_list = []
  config["applications"].each do |appname, appconfig|
    # If this app is docker, add it's compose to the list
    if File.exists?("#{root_loc}/apps/#{appname}/docker-compose-fragment.yml")
      commodity_list.push("/vagrant/apps/#{appname}/docker-compose-fragment.yml")
    end
    # Load any commodities into the docker compose list
    if appconfig.key?("commodities")
      appconfig["commodities"].each do |commodity|
        commodity_list.push("/vagrant/scripts/guest/docker/#{commodity}/docker-compose-fragment.yml")
      end
    end
  end

  # Remove duplicate commodities
  commodity_list = commodity_list.uniq

  # Put the compose arguments into a file for later retrieval
  File.open("#{root_loc}/.docker-compose-file-list", 'w') {|f| f.write(commodity_list.join(":"))}
end
