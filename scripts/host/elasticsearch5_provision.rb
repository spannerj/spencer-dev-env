require_relative 'utilities'
require_relative 'commodities'

def provision_elasticsearch5(root_loc)
  puts colorize_lightblue("Searching for elasticsearch5 initialisation scripts in the apps")
  require 'yaml'
  root_loc = root_loc
  prepared_one = false

  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  docker_commands = []
  docker_commands.push("docker-compose up --build -d elasticsearch5")
  # Better not run anything until elasticsearch is ready to accept connections...
  docker_commands.push("echo Waiting for elasticsearch5 to finish initialising")
  docker_commands.push("/vagrant/scripts/guest/docker/elasticsearch5/wait-for-it.sh http://localhost:9202")

  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init scripts
      # if the app specifically specifies elasticsearch in it's commodity list
      if !File.exist?("#{root_loc}/apps/#{appname}/configuration.yml")
        puts colorize_red("No configuration.yml found for %s" % [appname])
        next
      end
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_elasticsearch5 = dependencies.key?("commodities") && dependencies["commodities"].include?('elasticsearch5')
      next if not has_elasticsearch5

      # Load any SQL contained in the apps into the docker commands list
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/elasticsearch5-fragment.sh")
        puts colorize_pink("Found some in #{appname}")
        if commodity_provisioned?(root_loc, "#{appname}", "elasticsearch5")
          puts colorize_yellow("Elasticsearch5 has previously been provisioned for #{appname}, skipping")
        else
          docker_commands.push("/vagrant/apps/#{appname}/fragments/elasticsearch5-fragment.sh http://localhost:9202")
          prepared_one = true
          # Update the .commodities.yml to indicate that elasticsearch5 has now been provisioned
          set_commodity_provision_status(root_loc, "#{appname}", "elasticsearch5", true)
        end
      else
        puts colorize_yellow("#{appname} says it uses Elasticsearch5 but doesn't contain an init script. Oh well, onwards we go!")
      end
    end
  end
  if prepared_one
    # Now actually run the commands
    run_command("vagrant ssh -c \"" + docker_commands.join(" && ") + "\"")
  end
end
