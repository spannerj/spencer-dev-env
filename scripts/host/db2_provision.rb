require_relative 'utilities'
require_relative 'commodities'

def provision_db2(root_loc)
  puts colorize_lightblue("Searching for db2 initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  prepared_one = false

  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  docker_commands = []
  docker_commands.push("docker-compose start db2")

  # Better not run anything until DB2 is ready to accept connections...
  docker_commands.push("echo Waiting for DB2 to finish initialising")
  docker_commands.push("source /vagrant/scripts/guest/docker/db2/wait-for-db2.sh")

  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init sql
      # if the app specifically specifies db2 in it's commodity list
      if !File.exist?("#{root_loc}/apps/#{appname}/configuration.yml")
        puts colorize_red("No configuration.yml found for %s" % [appname])
        next
      end
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_db2 = dependencies.key?("commodities") && dependencies["commodities"].include?('db2')
      next if not has_db2

      # Load any SQL contained in the apps into the docker commands list
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/db2-init-fragment.sql")
        puts colorize_pink("Found some in #{appname}")
        if commodity_provisioned?(root_loc, "#{appname}", "db2")
          puts colorize_yellow("DB2 has previously been provisioned for #{appname}, skipping")
        else
          docker_commands.push("docker cp /vagrant/apps/#{appname}/fragments/db2-init-fragment.sql db2:/#{appname}-init.sql")
          docker_commands.push("docker exec db2 bash -c 'chmod o+r /#{appname}-init.sql'")
          docker_commands.push("docker exec -u db2inst1 db2 bash -c '~/sqllib/bin/db2 -tvf /#{appname}-init.sql'")
          prepared_one = true
          # Update the .commodities.yml to indicate that db2 has now been provisioned
          set_commodity_provision_status(root_loc, "#{appname}", "db2", true)
        end
      else
        puts colorize_yellow("#{appname} says it uses DB2 but doesn't contain an init SQL file. Oh well, onwards we go!")
      end
    end
  end
  if prepared_one
    # Now actually run the commands
    run_command("vagrant ssh -c \"" + docker_commands.join(" && ") + "\"")
  end
end


if __FILE__ == $0
  provision_db2(File.dirname(__FILE__) + "/../../")
end
