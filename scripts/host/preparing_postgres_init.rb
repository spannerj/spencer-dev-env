require File.dirname(__FILE__)+'/utilities'

def prepare_postgres(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  
  # Write the line we always need
  File.open("#{root_loc}/scripts/guest/docker/postgres/init.sql", 'w') { |file| file.write("CREATE ROLE vagrant WITH LOGIN PASSWORD 'vagrant';") }
  
  config["applications"].each do |appname, appconfig|
    # Load any SQL contained in the apps into the master file
    if File.exists?("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      to_append = File.read("#{root_loc}/apps/#{appname}/postgres-init-fragment.sql")
      File.open("#{root_loc}/scripts/guest/docker/postgres/init.sql", 'a') { |file| file.puts to_append }
    end
  end
  
  

end
