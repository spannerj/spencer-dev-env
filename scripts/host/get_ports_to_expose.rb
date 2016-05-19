#!/usr/bin/env ruby

require_relative 'utilities'

def get_port_list(root_loc)
  require 'yaml'
  root_loc = root_loc

  # Put all the app ports into an array
  port_list = []
  dependency_list = []

  if File.exists?("#{root_loc}/dev-env-project/configuration.yml")
    config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

    # Loop through the apps, find the compose fragment, find the host port within
    # the fragment add it to port_list
    config["applications"].each do |appname, appconfig|
      # If this app is docker, add it's compose to the list
      if File.exists?("#{root_loc}/apps/#{appname}/docker-compose-fragment.yml")
        compose_file = YAML.load_file("#{root_loc}/apps/#{appname}/docker-compose-fragment.yml")

        compose_file["services"].each do |composeappname, composeappconfig|
          # If the compose file has a port section
          if composeappconfig.key?("ports")
            # Currently assumes there is only one port to forward and that the
            # first port in the string "port_number1:port_number2" is the host port
            app_host_port = composeappconfig["ports"][0].split(":")[0]
            port_list.push("#{app_host_port}:#{app_host_port}")
          end
        end
      end

      if appconfig.key?("dependencies")
        appconfig["dependencies"].each do |dependency|
          dependency_list.push(dependency)
        end
      end
    end
  end

  # Remove duplicate dependencies
  dependency_list = dependency_list.uniq

  if dependency_list.include? "postgres"
    port_list.push("15432:5432")
  end

  #If rabbitmq is being used then expose the rabbitmq admin port
  if dependency_list.include? "rabbitmq"
    port_list.push("25672:15672")
  end

  return port_list
end

if __FILE__ == $0
  expose_app_and_dependency_ports(File.dirname(__FILE__) + "/../../")
end
