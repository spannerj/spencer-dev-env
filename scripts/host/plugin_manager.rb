#!/usr/bin/ruby
# @Author: Dev_NIX
# @Date:   2016-03-07 14:24:11
# @Last Modified by:   Dev_NIX
# @Last Modified time: 2016-03-07 16:36:38


def check_plugins(plugins)
    no_missing = true
	if ['up', 'reload'].include? ARGV[0]
		installed_plugins = []

		puts "\033[1m" << "Checking plugins..." << "\e[0m"

		raw_output = `vagrant plugin list`
		raw_list = raw_output.split("\n")

		raw_list.each do |plugin|
			# skip lines that we dont care about (like version pin info)
			if plugin.index("(") == nil
				next
			end
			if plugin.index("\e[0m") != nil
				first = plugin.index("\e[0m")  + 4
			else
				first = 0
			end
			plugin_name = plugin.slice((first)..(plugin.index("(")-1)).strip
			# > 0.0.21 is broken (https://github.com/kusnier/vagrant-persistent-storage/issues/58)
			if plugin_name == "vagrant-persistent-storage" and plugin.index("0.0.21") == nil
				puts "Not running recommended stable version of vagrant-persistent-storage."
				if run_command("vagrant plugin install vagrant-persistent-storage --plugin-version 0.0.21") != 0
					puts "Error - Could not install"
					exit -1
				else
					no_missing = false
				end
			end
			installed_plugins.push(plugin_name)
		end

		plugins.each_with_index do |plugin, index|
			if not installed_plugins.include? plugin
				puts "\033[33m" << " - Missing '#{plugin}'!" << "\e[0m"
				if plugin == "vagrant-persistent-storage"
					plg_command = "vagrant plugin install vagrant-persistent-storage --plugin-version 0.0.21"
				else
				 	plg_command = "vagrant plugin install #{plugin}"
				end
				if run_command(plg_command) != 0
					puts "\n\033[33m" << " - Could not install plugin '#{plugin}'. " << "\e[0m\033[41m" <<"Stopped." << "\e[0m"
					exit -1
				else
            		no_missing = false
        		end
			end
		end

		if no_missing
			puts "\033[1m\033[36m" << " - All plugins already satisfied" << "\e[0m"
		else
			puts "\033[1m\033[32m" << " - Plugins installed" << "\e[0m"
		end
	end
    return no_missing
end
