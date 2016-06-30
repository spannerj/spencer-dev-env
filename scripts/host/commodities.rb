require_relative 'utilities'
require 'yaml'

def create_commodities_list(root_loc)
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")

  # Put all the commodities for all apps into an array
  commodity_list = []
  if !(config["applications"] == nil)
      config["applications"].each do |appname, appconfig|
        # Load any commodities into the list
        dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
        next if dependencies.nil?
        if dependencies.key?("commodities")
          dependencies["commodities"].each do |appcommodity|
            commodity_list.push(appcommodity)
          end
        end
    end
  end

  # Remove duplicate commodities
  commodity_list = commodity_list.uniq

  if File.exists?("#{root_loc}/.commodities.yml")
    commodity_file = YAML.load_file("#{root_loc}/.commodities.yml")
    # Check if each commodity we want is already there or not, add it if not
    commodity_list.each do |appcommodity|
      if is_commodity?(root_loc, appcommodity) == false
        commodity = {"#{appcommodity}" => {"provisioned" => false}}
        commodity_file["commodities"].push(commodity)
      end
    end
  else
    # Loop through the unique list of commodities and create a hash which will
    # become the .commodities.yml file
    commodity_file = {"commodities" => []}
    commodity_list.each do |appcommodity|
      commodity = {"#{appcommodity}" => {"provisioned" => false}}
      commodity_file["commodities"].push(commodity)
    end
  end

  # Write the commodity information to a file
  File.open("#{root_loc}/.commodities.yml", 'w') {|f| f.write(commodity_file.to_yaml)}
end

def commodity_provisioned?(root_loc, commodity)
  commodity_provisioned = false # initialise

  if File.exists?("#{root_loc}/.commodities.yml")

    commodities = YAML.load_file("#{root_loc}/.commodities.yml")

    commodities["commodities"].each do |commodity_info|
      commodity_info.each do |name, info|
        if name == commodity
          commodity_provisioned = info["provisioned"]
          break
        end
      end
    end

  end

  return commodity_provisioned
end

def set_commodity_provision_status(root_loc, commodity, status)
  if File.exists?("#{root_loc}/.commodities.yml")

    commodities = YAML.load_file("#{root_loc}/.commodities.yml")

    commodities["commodities"].each do |commodity_info|
        commodity_info.each do |name, info|
          if name == commodity
            info["provisioned"] = status

            # Write the commodity information to a file and then break from loop
            File.open("#{root_loc}/.commodities.yml", 'w') {|f| f.write(commodities.to_yaml)}
            break
          end
        end
    end

  end
end

def is_commodity?(root_loc, commodity)
  is_commodity = false # initialise

  if File.exists?("#{root_loc}/.commodities.yml")

    commodities = YAML.load_file("#{root_loc}/.commodities.yml")

    commodities["commodities"].each do |commodity_info|
      commodity_info.each do |name, info|
        if name == commodity
          is_commodity = true
          break
        end
      end
    end

  end

  return is_commodity
end



if __FILE__ == $0
  create_commodities_list(File.dirname(__FILE__) + "/../../")
end
