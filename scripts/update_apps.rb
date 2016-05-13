#!/usr/bin/env ruby

def update_apps()
  require 'yaml'

  #Load configuration.yml into a Hash
  config = YAML::load(File.open('dev-env-project/configuration.yml'))

  config["applications"].each do |appname, appconfig|

    #Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
    if Dir.exists?("apps/#{appname}")
      command_successful = system 'git', '-C', "apps/#{appname}", 'pull'
    else
      repo = appconfig["repo"]
      command_successful = system 'git', 'clone', "#{repo}", "apps/#{appname}"
    end

  end
end

if __FILE__ == $0
  update_apps()
end
