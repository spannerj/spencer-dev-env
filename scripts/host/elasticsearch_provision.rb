require_relative 'utilities'
require_relative 'commodities'

def provision_elasticsearch(root_loc)
  puts colorize_lightblue("Searching for elasticsearch initialisation scripts in the apps")
  require 'yaml'
  root_loc = root_loc
  prepared_one = false

  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  docker_commands = []
  docker_commands.push("docker-compose start elasticsearch")
  # Better not run anything until elasticsearch is ready to accept connections...
  docker_commands.push("echo Waiting for elasticsearch to finish initialising")
  docker_commands.push("/vagrant/scripts/guest/docker/elasticsearch/wait-for-it.sh http://localhost:9200")

  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init scripts
      # if the app specifically specifies elasticsearch in it's commodity list
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_elasticsearch = dependencies.key?("commodities") && dependencies["commodities"].include?('elasticsearch')
      next if not has_elasticsearch

      # Load any SQL contained in the apps into the docker commands list
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/elasticsearch-fragment.sh")
        puts colorize_pink("Found some in #{appname}")
        if commodity_provisioned?(root_loc, "#{appname}", "elasticsearch")
          puts colorize_yellow("Elasticsearch has previously been provisioned for #{appname}, skipping")
        else
          docker_commands.push("/vagrant/apps/#{appname}/fragments/elasticsearch-fragment.sh http://localhost:9200")
          prepared_one = true
          # Update the .commodities.yml to indicate that elasticsearch has now been provisioned
          set_commodity_provision_status(root_loc, "#{appname}", "elasticsearch", true)
        end
      else
        puts colorize_yellow("#{appname} says it uses Elasticsearch but doesn't contain an init SQL file. Oh well, onwards we go!")
      end
    end
  end
  if prepared_one
    # Now actually run the commands
    system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
  end
end
