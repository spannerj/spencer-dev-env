require_relative 'utilities'
require_relative 'commodities'

def provision_elasticsearch(root_loc)
  # If elasticsearch is a determined commodity
  # And it has not yet been provisioned
  if is_commodity?(root_loc, "elasticsearch") &&
    commodity_provisioned?(root_loc, "elasticsearch") == false

    puts colorize_lightblue("Searching for elasticsearch code")
    require 'yaml'
    root_loc = root_loc
    # Load configuration.yml into a Hash
    config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
    
    docker_commands = []
    
    had_one = false
    
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init sql 
      # if the app specifically specifies elasticsearch in it's commodity list
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/dependencies.yml")
      has_es = dependencies.key?("commodities") && dependencies["commodities"].include?('elasticsearch')
      next if not has_es
    
      # Any app that has a fragment should get it executed in the app container
      # Build up just one vagrant ssh command since it's a bit slow to connect
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/elasticsearch-fragment.sh")
        if had_one == false
          # Better not run anything until elasticsearch is ready to accept connections...
          docker_commands.push("echo Waiting for elasticsearch to finish initialising")
          docker_commands.push("/vagrant/scripts/guest/wait-for-it.sh -h localhost -p 9200")
          had_one = true
        end
        puts colorize_pink("Found some in #{appname}")
        docker_commands.push("docker exec #{appname} bash -c '/src/fragments/elasticsearch-fragment.sh http://elasticsearch:9200'")
      end
    end
    unless docker_commands.empty?
      puts colorize_lightblue("Running elasticsearch provisioning")
      system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
      # Update the .commodities.yml to indicate that elasticsearch has now been provisioned
      set_commodity_provision_status(root_loc, "elasticsearch", true)
    end
  else
     puts colorize_yellow("Elasticsearch not needed or previously provisioned, skipping")
  end
end
