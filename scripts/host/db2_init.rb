require_relative 'utilities'

def prepare_db2(root_loc)
  puts colorize_lightblue("Searching for db2 initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Write the line we always need
  File.open("#{root_loc}/scripts/guest/docker/postgres/init.sql", 'w') { |file| file.write("CREATE ROLE vagrant WITH LOGIN PASSWORD 'vagrant';") }

  config["applications"].each do |appname, appconfig|
    # Load any SQL contained in the apps into the master file
    if File.exists?("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      puts colorize_pink("Found some in #{appname}")
      to_append = File.read("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      File.open("#{root_loc}/scripts/guest/docker/postgres/init.sql", 'a') { |file| file.puts to_append }
    end
  end



end
