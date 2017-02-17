require_relative 'utilities'

require "json"
require "net/http"
require "rubygems"
require "uri"

def self_update(root_loc, this_version)
  # Check for new version (using a snippet)
  versioncheck_uri = URI.parse("http://192.168.249.38/common/dev-env/snippets/12/raw")
  http = Net::HTTP.new(versioncheck_uri.host, versioncheck_uri.port)
  request = Net::HTTP::Get.new(versioncheck_uri.request_uri)
  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      latest_version = result["version"]
      # Is there a newer version available?
      if Gem::Version.new(latest_version) > Gem::Version.new(this_version)
        puts colorize_yellow("A new version is available - v#{latest_version}")
        puts colorize_yellow("Changes:")
        result["changes"].each { |change| puts colorize_yellow("  " + change) }
        puts ""
        # Have we already asked the user to update today?
        ask_update = true
        update_check_file = root_loc + "/.update-check-context"
        if File.exists?(update_check_file)
          parsed_date = Date.strptime(File.read(update_check_file), '%Y-%m-%d')
          if Date.today == parsed_date
            puts colorize_yellow("You've already said you don't want to update today, so I won't ask again. To update manually, run git pull.")
            puts ""
            ask_update = false
          else
            # We have not asked today yet, delete the file
            File.delete(update_check_file)
          end
        end
        if ask_update
          # Ask the user if they want to pull down the new update now, or just carry on booting up
          print colorize_yellow("Would you like to update now? (y/n) ")
          confirm = STDIN.gets.chomp
          until confirm.upcase.start_with?('Y', 'N')
            print colorize_yellow("Would you like to update now? (y/n) ")
            confirm = STDIN.gets.chomp
          end
          if confirm.upcase.start_with?('Y')
            # (try to) run the update
            if not system 'git', '-C', root_loc, 'pull'
              puts colorize_yellow("There was an error retrieving the new dev-env. Sorry. I'll just get on with starting the machine.")
              puts colorize_yellow("Continuing in 5 seconds...")
              sleep(5)
            else
              puts colorize_yellow("Update successful.")
              puts colorize_yellow("Please rerun your command (vagrant #{ARGV.join(' ')})")
              exit 0
            end
          else
            puts ""
            puts colorize_yellow("Okay. I'll ask again tomorrow. If you want to update in the meantime, simply run git pull yourself.'")
            puts colorize_yellow("Continuing in 5 seconds...")
            puts ""
            File.write(update_check_file, Date.today.to_s)
            sleep(5)
          end
        end
      else
        puts colorize_green("This is the latest version.")
      end
    else
      puts colorize_yellow("There was an error retrieving the current dev-env version (is AWS GitLab down?). I'll just get on with starting the machine.")
      puts colorize_yellow("Continuing in 5 seconds...")
      sleep(5)
    end
  rescue StandardError => e
    puts e
    puts colorize_yellow("There was an error retrieving the current dev-env version (is AWS GitLab down?). I'll just get on with starting the machine.")
    puts colorize_yellow("Continuing in 5 seconds...")
    sleep(5)
  end
end