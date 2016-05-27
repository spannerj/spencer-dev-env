require_relative 'utilities'

def prepare_postgres(root_loc)
  puts colorize_lightblue("Searching for postgres initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  
  # Write the line we always need
  File.open("#{root_loc}/.postgres_init.sql", 'w') { |file| file.write("CREATE ROLE vagrant WITH LOGIN PASSWORD 'vagrant';") }
  
  config["applications"].each do |appname, appconfig|
    # Load any SQL contained in the apps into the master file
    if File.exists?("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      puts colorize_pink("Found some in #{appname}")
      to_append = File.read("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      File.open("#{root_loc}/.postgres_init.sql", 'a') { |file| file.puts to_append }
    end
  end

end

def provision_postgres(root_loc)
  # If postgres is an identified commodity and has not already been provisioned
  if is_commodity?(root_loc, "postgres") && commodity_provisioned?(root_loc, "postgres") == false
    #Prepare the SQL that needs to run (creates the init.sql file)
    prepare_postgres(root_loc)
    puts colorize_lightblue("Provisioning Postgres")
    docker_commands = []
    # Better not run anything until postgres is ready to accept connections...
    docker_commands.push("echo Waiting for postgres to finish initialising")
    docker_commands.push("/vagrant/scripts/guest/docker/postgres/wait-for-it.sh localhost")
    # First, a command to get the file into the container
    docker_commands.push("docker cp /vagrant/.postgres_init.sql postgres:/init.sql")
    # Then a command to execute the file
    docker_commands.push("docker exec postgres psql -q -f '/init.sql'")
    # Now actually run the commands
    system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
    # Update the .dependencies.yml to indicate that postgres has now been provisioned
    set_commodity_provision_status(root_loc, "postgres", true)
  else
    puts colorize_yellow("Postgres not needed or previously provisioned, skipping")
  end
end