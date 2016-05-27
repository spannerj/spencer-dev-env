require_relative 'utilities'
require_relative 'dependencies'

def provision_elasticsearch(root_loc)
  # If elasticsearch is a determined dependency
  # And it has not yet been provisioned
  if is_dependency?(root_loc, "elasticsearch") &&
    dependency_provisioned?(root_loc, "elasticsearch") == false

    puts colorize_lightblue("Searching for elasticsearch code")
    require 'yaml'
    root_loc = root_loc
    # Load configuration.yml into a Hash
    config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
    
    docker_commands = []
    
    had_one = false
    
    config["applications"].each do |appname, appconfig|
      # Any app that has a fragment should get it executed in the app container
      # Build up just one vagrant ssh command since it's a bit slow to connect
      if File.exists?("#{root_loc}/apps/#{appname}/elasticsearch-fragment.sh")
        if had_one == false
          # Better not run anything until elasticsearch is ready to accept connections...
          docker_commands.push("echo Waiting for elasticsearch to finish initialising")
          docker_commands.push("/vagrant/scripts/guest/wait-for-it.sh -h localhost -p 9200")
          had_one = true
        end
        puts colorize_pink("Found some in #{appname}")
        docker_commands.push("docker exec #{appname} bash -c '/src/elasticsearch-fragment.sh http://elasticsearch:9200'")
      end
    end
    unless docker_commands.empty?
      puts colorize_lightblue("Running elasticsearch provisioning")
      system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
      # Update the .dependencies.yml to indicate that elasticsearch has now been provisioned
      set_dependency_provision_status(root_loc, "elasticsearch", true)
    end
  else
     puts colorize_yellow("Elasticsearch not needed or previously provisioned, skipping")
  end
end
