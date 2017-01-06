require "net/http"
require "uri"
require 'fileutils'

require_relative 'utilities'

def load_supporting_files(root_loc)
  # Get locations ready
  FileUtils.mkdir_p "#{root_loc}/supporting-files/certs"

  # Get live (currently used as dev, though) ADFS public cert
  liveadfscert_uri = URI.parse("http://192.168.249.38/common/dev-env/snippets/14/raw")
  http = Net::HTTP.new(liveadfscert_uri.host, liveadfscert_uri.port)
  request = Net::HTTP::Get.new(liveadfscert_uri.request_uri)
  begin
      response = http.request(request)
      if response.code == "200"
        # Because editing the file in gitlab on windows/mac messes up line endings, lets normalise them
        cert_file = response.body.gsub /\r\n?/, "\n"
        File.open("#{root_loc}/supporting-files/certs/adfs_Dev.crt", 'w') { |file| file.write(cert_file) }
      else
        puts colorize_yellow("There was an error retrieving the dev ADFS public cert (is AWS GitLab down?). I'll just get on with starting the machine...")
      end
  rescue StandardError => e
      puts e
      puts colorize_yellow("There was an error retrieving the dev ADFS public cert (is AWS GitLab down?). I'll just get on with starting the machine...")
  end
end