require_relative 'utilities'

def provision_nginx(root_loc)
  puts "configuring nginx"
  docker_commands = []
  # run docker configuration script
  docker_commands.push("docker exec nginx sh /share/configure-nginx.sh")
  # restart container
  docker_commands.push("docker restart nginx")

  # Now actually run the commands
  system "vagrant ssh -c \"" + docker_commands.join(" && ") + "\""

  puts "nginx configured"
end
