#!/usr/bin/env ruby

require_relative 'utilities'

def update_apps(root_loc)
  require 'yaml'
  root_loc = root_loc
  # Load configuration.yml into a Hash
  config = YAML.load_file("#{root_loc}/dev-env-project/configuration.yml")
  if !(config["applications"] == nil)
      config["applications"].each do |appname, appconfig|
        puts colorize_green("================== #{appname} ==================")

        # Check if dev-env-project exists, and if so pull the dev-env configuration. Otherwise clone it.
        if Dir.exists?("#{root_loc}/apps/#{appname}")
          # The app already exists, we must have cloned it before
          puts colorize_lightblue("The repo directory for this app already exists, so I will try to update it")

          # What branch are we working on?
          current_branch = `git -C #{root_loc}/apps/#{appname} rev-parse --abbrev-ref HEAD`.strip
          # Check for a detached head scenario (i.e. a specific commit) - technically there is therefore no branch
          if current_branch.eql? 'HEAD' then current_branch = 'detached' end

          # If the user is working in another branch, leave them be
          required_branch = appconfig['branch']
          if not current_branch.eql? required_branch
            puts colorize_yellow("The current branch (#{current_branch}) differs from the devenv configuration (#{required_branch}) so I'm not going to update anything")
            next # Skip to next app
          end

          # Update all the remote branches (this will not change the local branch, we'll do that further down')
          puts colorize_lightblue("Fetching from remote...")
          if not system 'git', '-C', "#{root_loc}/apps/#{appname}", 'fetch', 'origin'
            # If there is a git error we shouldn't continue
            puts colorize_red("Error while updating #{appname}")
            exit 1
          end
        else
          puts colorize_lightblue("#{appname} does not yet exist, so I will clone it")
          repo = appconfig["repo"]
          if not system 'git', 'clone', "#{repo}", "#{root_loc}/apps/#{appname}"
            # If there is a git error we shouldn't continue
            puts colorize_red("Error while cloning #{appname}")
            exit 1
          end
          # What branch are we working on?
          current_branch = `git -C #{root_loc}/apps/#{appname} rev-parse --abbrev-ref HEAD`.strip

          # If we have to, create a new tracked local branch that matches the one specified in the config and switch to it
          required_branch = appconfig['branch']
          if not current_branch.eql? required_branch
            puts colorize_lightblue("Switching branch to #{required_branch}")
            system 'git', '-C', "#{root_loc}/apps/#{appname}", 'checkout', '--track', "origin/#{required_branch}"
          else
            puts colorize_lightblue("Current branch is already #{current_branch}")
          end
        end
        # Attempt to merge our remote branch into our local branch, if it's straightforward
        puts colorize_lightblue("Bringing #{required_branch} up to date")
        if not system 'git', '-C', "#{root_loc}/apps/#{appname}", 'merge', '--ff-only'
          colorize_yellow("The local branch couldn't be fast forwarded (a merge is probably required), so to be safe I didn't update anything")
        end
      end
  end
end

if __FILE__ == $0
  update_apps(File.dirname(__FILE__) + "../../")
end
