require_relative 'utilities'
require 'yaml'

def create_commodities_list(root_loc)
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the commodities for all apps into an array
  commodity_list = []
  # And keep track of which apps need which commodities
  app_to_commodity_map = Hash.new([].freeze)
  if config["applications"]
    config["applications"].each do |appname, appconfig|
      # Load any commodities into the list
      if !File.exist?("#{root_loc}/apps/#{appname}/configuration.yml")
        puts colorize_red("No configuration.yml found for %s" % [appname])
        next
      end
      dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
      next if dependencies.nil?
      if dependencies.key?("commodities")
        dependencies["commodities"].each do |appcommodity|
          commodity_list.push(appcommodity)
          app_to_commodity_map["#{appname}"] += [appcommodity]
        end
      end
    end
  end

  # Remove duplicate commodities
  commodity_list = commodity_list.uniq

  global_provisioned = []  
  if File.exists?("#{root_loc}/.commodities.yml")
    commodity_file = YAML.load_file("#{root_loc}/.commodities.yml")
    if commodity_file["version"] == '2'
      puts colorize_green("Found a version 2 .commodities file.")
    else
      puts colorize_yellow("Found a version 1 .commodities file. Upgrading to version 2...")
      # Find any commodities that are already provisioned and add them to a list for later use when building the new file
      new_commodity_file = {"version" => "2", "commodities" => [], "applications" => { }}
      commodity_file["commodities"].each do |old_commodity|
        old_commodity.each do |old_commodity_name, old_commodity_info|
          if old_commodity_info["provisioned"] == true
            global_provisioned.push(old_commodity_name)
          end
        end
      end
      commodity_file = new_commodity_file
    end
  else
    # Create the base file structure
    puts colorize_green("Did not find any .commodities file. I'll create a new one (v2).'")
    commodity_file = {"version" => "2", "commodities" => [], "applications" => { }}
  end
  
  # Rebuild the the master list
  commodity_file["commodities"] = commodity_list
  
  cf_app_list = commodity_file["applications"]
  # Add any missing app/commodity pairings to the list
  app_to_commodity_map.each do |app_name, app_commodity_list|
    # App
    if not cf_app_list.has_key? app_name
      cf_app_list["#{app_name}"] = { }
    end

    # Commodity
    app_commodity_list.each do |current_commodity|
      if not cf_app_list["#{app_name}"].has_key? current_commodity
        # If, in the v1 upgrade, this commodity was found to be already provisioned, init it to true
        if global_provisioned.include? current_commodity
          cf_app_list["#{app_name}"]["#{current_commodity}"] = true
        else
          cf_app_list["#{app_name}"]["#{current_commodity}"] = false
        end
        puts colorize_pink("Found a new commodity dependency from #{app_name} to #{current_commodity}")
      end
    end
  end

  # Write the commodity information to a file
  File.open("#{root_loc}/.commodities.yml", 'w') {|f| f.write(commodity_file.to_yaml)}
end

def commodity_provisioned?(root_loc, app_name, commodity)
  commodity_file = YAML.load_file("#{root_loc}/.commodities.yml")
  return commodity_file["applications"]["#{app_name}"]["#{commodity}"]
end

def set_commodity_provision_status(root_loc, app_name, commodity, status)
    commodity_file = YAML.load_file("#{root_loc}/.commodities.yml")
    commodity_file["applications"]["#{app_name}"]["#{commodity}"] = status
    File.open("#{root_loc}/.commodities.yml", 'w') {|f| f.write(commodity_file.to_yaml)}
end

def is_commodity?(root_loc, commodity)
  is_commodity = false # initialise

  if File.exists?("#{root_loc}/.commodities.yml")

    commodities = YAML.load_file("#{root_loc}/.commodities.yml")

    commodities["commodities"].each do |commodity_name|
      if commodity == commodity_name
        is_commodity = true
        break
      end
    end

  end

  return is_commodity
end



if __FILE__ == $0
  create_commodities_list(File.dirname(__FILE__) + "/../../")
end
