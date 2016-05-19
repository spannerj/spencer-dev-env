require File.dirname(__FILE__)+'/utilities'

def provision_alembic(root_loc)
  puts colorize_lightblue("Searching for alembic code")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  
  docker_commands = []
  
  config["applications"].each do |appname, appconfig|
    # Any app that has a manage.py should get it executed in it's container
    # Build up just one vagrant ssh command since it's a bit slow to connect
    if File.exists?("#{root_loc}/apps/#{appname}/manage.py")
      puts colorize_lightblue("Found some in #{appname}")
      docker_commands.push("docker exec #{appname} bash -c 'cd /src && python3 manage.py db upgrade'")
    end
  end
  unless docker_commands.empty?
    puts colorize_lightblue("Running alembic database provisioning")
    system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
  end
end
