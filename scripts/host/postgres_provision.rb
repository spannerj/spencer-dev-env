require_relative 'utilities'

def provision_postgres(root_loc)
  puts colorize_lightblue("Searching for postgres initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  prepared_one = false

  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  docker_commands = []
  docker_commands.push("docker-compose up --no-build -d postgres")
  # Better not run anything until postgres is ready to accept connections...
  docker_commands.push("echo Waiting for postgres to finish initialising")
  docker_commands.push("/vagrant/scripts/guest/docker/postgres/wait-for-it.sh localhost")

  # DEPRECATED: Write the line we always need (for backwards compatibility with apps that don't use their own username yet)
  File.open("#{root_loc}/.postgres_init.sql", 'w') { |file| file.write("CREATE ROLE vagrant WITH LOGIN PASSWORD 'vagrant';") }
  # First, a command to get the file into the container
  docker_commands.push("docker cp /vagrant/.postgres_init.sql postgres:/postgres_init.sql")
  # Then a command to execute the file
  docker_commands.push("docker exec postgres psql -q -f '/postgres_init.sql'")

  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init sql
      # if the app specifically specifies postgres in it's commodity list
      if !File.exist?("#{root_loc}/apps/#{appname}/configuration.yml")
        puts colorize_red("No configuration.yml found for %s" % [appname])
        next
      end
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_postgres = dependencies.key?("commodities") && dependencies["commodities"].include?('postgres')
      next if not has_postgres

      # Load any SQL contained in the apps into the docker commands list
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/postgres-init-fragment.sql")
        puts colorize_pink("Found some in #{appname}")
        if commodity_provisioned?(root_loc, "#{appname}", "postgres")
          puts colorize_yellow("Postgres has previously been provisioned for #{appname}, skipping")
        else
          docker_commands.push("docker cp /vagrant/apps/#{appname}/fragments/postgres-init-fragment.sql postgres:/#{appname}-init.sql")
          docker_commands.push("docker exec postgres psql -q -f '/#{appname}-init.sql'")
          prepared_one = true
          # Update the .commodities.yml to indicate that postgres has now been provisioned
          set_commodity_provision_status(root_loc, "#{appname}", "postgres", true)
        end
      else
        puts colorize_yellow("#{appname} says it uses Postgres but doesn't contain an init SQL file. Oh well, onwards we go!")
      end
    end
  end
  if prepared_one
    # Now actually run the commands
    run_command("vagrant ssh -c \"" + docker_commands.join(" && ") + "\"")
  end
end
