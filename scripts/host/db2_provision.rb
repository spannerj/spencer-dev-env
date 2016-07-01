require_relative 'utilities'
require_relative 'commodities'

def prepare_db2(root_loc)
  prepared = false
  puts colorize_lightblue("Searching for db2 initialisation SQL in the apps")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  
  # Create/wipe the file
  File.open("#{root_loc}/.db2_init.sql", "w") {}
  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for init sql 
      # if the app specifically specifies db2 in it's commodity list
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_db2 = dependencies.key?("commodities") && dependencies["commodities"].include?('db2')
      next if not has_db2
      
      # Load any SQL contained in the apps into the master file
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/db2-init-fragment.sql")
        puts colorize_pink("Found some in #{appname}")
        to_append = File.read("#{root_loc}/apps/#{appname}/fragments/db2-init-fragment.sql")
        File.open("#{root_loc}/.db2_init.sql", 'a') { |file| file.puts to_append }
        prepared = true
      end
    end
  end
  return prepared
end

def provision_db2(root_loc)
  # If db2 is a commodity and not already provisioned
  if is_commodity?(root_loc, "db2") && commodity_provisioned?(root_loc, "db2") == false
    #Prepare the SQL that needs to run in db2
    if prepare_db2(root_loc)
      puts colorize_lightblue("Provisioning DB2")
      # Run the the command "db2 bash -c '~/sqllib/bin/db2 -tvf /init.sql" inside the db2 docker container
      system  "vagrant ssh -c \"docker-compose start db2 && docker cp /vagrant/.db2_init.sql db2:/init.sql && docker exec -u db2inst1 db2 bash -c '~/sqllib/bin/db2 -tvf /init.sql'\""
      # Update the .commodities.yml to indicate that db2 has now been provisioned
      set_commodity_provision_status(root_loc, "db2", true)
    end
  else
    puts colorize_yellow("DB2 not needed or previously provisioned, skipping")
  end
end

if __FILE__ == $0
  provision_db2(File.dirname(__FILE__) + "/../../")
end
