require_relative 'utilities'

def provision_alembic(root_loc)
  puts colorize_lightblue("Searching for alembic code")
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  
  docker_commands = []
  
  had_one = false
  
  config["applications"].each do |appname, appconfig|
    # Any app that has a manage.py should get it executed in it's container
    # Build up just one vagrant ssh command since it's a bit slow to connect
    if File.exists?("#{root_loc}/apps/#{appname}/manage.py")
      if had_one == false
        # Better not run anything until postgres is ready to accept connections...
        docker_commands.push("echo Waiting for postgres to finish initialising")
        docker_commands.push("/vagrant/scripts/guest/docker/postgres/wait-for-it.sh localhost")
        had_one = true
      end
      puts colorize_pink("Found some in #{appname}")
      docker_commands.push("docker exec #{appname} bash -c 'cd /src && python3 manage.py db upgrade'")
    end
  end
  unless docker_commands.empty?
    puts colorize_lightblue("Running alembic database provisioning")
    system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""
  end
end
