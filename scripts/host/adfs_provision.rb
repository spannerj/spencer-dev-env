require_relative 'utilities'

# Public: Provision the host's hosts file for adfs usage.
#
# root_loc - The root location of the development environment.
#
def provision_adfs(root_loc):
    require 'yaml'
    host_additions = [] # Holds a list of hosts file entries

    # Determine new host details
    config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
    if config["applications"]
        config["applications"].each do |appname, appconfig|
            # Check adfs is required
            dependencies = YAML.load_file("#{root_loc}/apps/#{appname}/configuration.yml")
            if not dependencies.nil?
                needs_adfs = dependencies.key?("commodities") && dependencies["commodities"].include?('adfs')
                if needs_adfs
                    # We found one with adfs!
                    puts colorize_pink("Found an ADFS provision for #{appname}")
                    if File.exists?("#{root_loc}/apps/#{appname}/fragments/host-fragments.yml")
                        # Allow each app to ammend more than one line to the file.
                        hosts = YAML.load_file("#{root_loc}/apps/#{appname}/fragments/host-fragments.yml")
                        hosts["hosts"].each do |entry|
                            host_additions.push(entry)
                        end
                        # Set status of the commodity
                        set_commodity_provision_status(root_loc, "#{appname}", "adfs", true)
                    else
                        puts colorize_yellow("#{appname} said it required adfs but provided no adfs fragment.")
                    end
                end
            end
        end
    end
    
    # Now modify the host's file according to OS
    hosts_file = nil
    if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
        # WINDOWS
        hosts_file = "C:/Windows/System32/drivers/etc/hosts"
    else
        # LINUX or MAC OS (NOT TESTED)
        hosts_file = "/etc/hosts"
    end

    host_additions.each do |s|
        File.write(hosts_file, s, mode: 'a')
    end

