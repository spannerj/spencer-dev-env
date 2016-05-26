require_relative 'utilities'
require 'yaml'

def create_dependencies_list(root_loc)
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the dependencies for all apps into an array
  dependency_list = []
  config["applications"].each do |appname, appconfig|
    # Load any dependencies into the docker compose list
    if appconfig.key?("dependencies")
      appconfig["dependencies"].each do |appdependency|
        dependency_list.push(appdependency)
      end
    end
  end
  
  # Remove duplicate dependencies
  dependency_list = dependency_list.uniq
    
  if File.exists?("#{root_loc}/.dependencies.yml")
    dependency_file = YAML.load_file("#{root_loc}/.dependencies.yml")
    # Check if each dependency we want is already there or not, add it if not
    dependency_list.each do |appdependency|
      if is_dependency?(root_loc, appdependency) == false
        dependency = {"#{appdependency}" => {"provisioned" => false}}
        dependency_file["dependencies"].push(dependency)
      end
    end
  else
    # Loop through the unique list of dependencies and create a hash which will
    # become the .dependencies.yml file
    dependency_file = {"dependencies" => []}
    dependency_list.each do |appdependency|
      dependency = {"#{appdependency}" => {"provisioned" => false}}
      dependency_file["dependencies"].push(dependency)
    end
  end
  
  # Write the dependency information to a file
  File.open("#{root_loc}/.dependencies.yml", 'w') {|f| f.write(dependency_file.to_yaml)}
end

def dependency_provisioned?(root_loc, dependency)
  dependency_provisioned = false # initialise

  if File.exists?("#{root_loc}/.dependencies.yml")

    dependencies = YAML.load_file("#{root_loc}/.dependencies.yml")

    dependencies["dependencies"].each do |dependency_info|
      dependency_info.each do |name, info|
        if name == dependency
          dependency_provisioned = info["provisioned"]
          break
        end
      end
    end

  end

  return dependency_provisioned
end

def set_dependency_provision_status(root_loc, dependency, status)
  if File.exists?("#{root_loc}/.dependencies.yml")

    dependencies = YAML.load_file("#{root_loc}/.dependencies.yml")

    dependencies["dependencies"].each do |dependency_info|
        dependency_info.each do |name, info|
          if name == dependency
            info["provisioned"] = status

            # Write the dependency information to a file and then break from loop
            File.open("#{root_loc}/.dependencies.yml", 'w') {|f| f.write(dependencies.to_yaml)}
            break
          end
        end
    end

  end
end

def is_dependency?(root_loc, dependency)
  is_dependency = false # initialise

  if File.exists?("#{root_loc}/.dependencies.yml")

    dependencies = YAML.load_file("#{root_loc}/.dependencies.yml")

    dependencies["dependencies"].each do |dependency_info|
      dependency_info.each do |name, info|
        if name == dependency
          is_dependency = true
          break
        end
      end
    end

  end

  return is_dependency
end



if __FILE__ == $0
  create_dependencies_list(File.dirname(__FILE__) + "/../../")
end
