require_relative 'utilities'
require_relative 'dependencies'

def prepare_db2(root_loc)
  puts colorize_lightblue("Searching for db2 initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Write the line we always need
  File.open("#{root_loc}/scripts/guest/docker/db2/init.sql", 'w') { |file| file.write("") }

  config["applications"].each do |appname, appconfig|
    # Load any SQL contained in the apps into the master file
    if File.exists?("#{root_loc}/apps/#{appname}/db2-init-fragment.sql")
      puts colorize_pink("Found some in #{appname}")
      to_append = File.read("#{root_loc}/apps/#{appname}/db2-init-fragment.sql")
      File.open("#{root_loc}/scripts/guest/docker/db2/init.sql", 'a') { |file| file.puts to_append }
    end
  end
end

def provision_db2(root_loc)
  # If db2 is a dependency
  if is_dependency?(root_loc, "db2")
    # If db2 it has not already been provisioned
    if dependency_provisioned?(root_loc, "db2") == false
      require 'yaml'

      #Prepare the SQL need to run in db2
      prepare_db2(root_loc)

      dependency_list = []

      if File.exists?("#{root_loc}/dev-env-project/configuration.yml")
        config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

        # Loop through the apps to build a list of dependencies
        config["applications"].each do |appname, appconfig|

          if appconfig.key?("dependencies")
            appconfig["dependencies"].each do |dependency|
              dependency_list.push(dependency)
            end
          end
        end
      end

      # Remove duplicate dependencies
      dependency_list = dependency_list.uniq

      # If db2 is a dependency then run SQL statements
      if dependency_list.include? "db2"
        puts colorize_lightblue("Provisioning DB2")
        # Run the the command "db2 bash -c '~/sqllib/bin/db2 -tvf /init.sql" inside the db2 docker container
        system  "vagrant ssh -c \"docker exec -u db2inst1 db2 bash -c '~/sqllib/bin/db2 -tvf /init.sql'\""
        # Update the .dependencies.yml to indicate that db2 has now been provisioned
        set_dependency_provision_status(root_loc, "db2", true)
      end
    end
  end
end

if __FILE__ == $0
  provision_db2(File.dirname(__FILE__) + "/../../")
end
