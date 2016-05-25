require_relative 'utilities'

def provision_elasticsearch(root_loc)
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
  end
end
