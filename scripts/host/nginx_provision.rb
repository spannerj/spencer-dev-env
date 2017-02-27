require_relative 'utilities'

def provision_nginx(root_loc)
  puts colorize_lightblue("Searching for NGINX conf files in the apps")
  require 'yaml'
  root_loc = root_loc
  prepared_one = false

  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  docker_commands = []
  docker_commands.push("docker-compose up --build -d nginx")

  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # To help enforce the accuracy of the app's dependency file, only search for a conf file
      # if the app specifically specifies nginx in it's commodity list
      if !File.exist?("#{root_loc}/apps/#{appname}/configuration.yml")
        puts colorize_red("No configuration.yml found for %s" % [appname])
        next
      end
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      has_nginx = dependencies.key?("commodities") && dependencies["commodities"].include?('nginx')
      next if not has_nginx

      # Load any conf files contained in the apps into the docker commands list
      if File.exists?("#{root_loc}/apps/#{appname}/fragments/nginx-fragment.conf")
        puts colorize_pink("Found some in #{appname}")
        if commodity_provisioned?(root_loc, "#{appname}", "nginx")
          puts colorize_yellow("NGINX has previously been provisioned for #{appname}, skipping")
        else
          docker_commands.push("docker cp /vagrant/apps/#{appname}/fragments/nginx-fragment.conf nginx:/etc/nginx/configs/#{appname}-nginx-fragment.conf")
          prepared_one = true
          # Update the .commodities.yml to indicate that NGINX has now been provisioned
          set_commodity_provision_status(root_loc, "#{appname}", "nginx", true)
        end
      else
        puts colorize_yellow("#{appname} says it uses NGINX but doesn't contain a conf file. Oh well, onwards we go!")
      end
    end
  end
  if prepared_one
    # Stop it. As it will need to start after the apps for the proxying to not error out. So let it start with all the rest later.
    docker_commands.push("docker-compose stop nginx")
    # Now actually run the commands
    run_command("vagrant ssh -c \"" + docker_commands.join(" && ") + "\"")
  end
end
