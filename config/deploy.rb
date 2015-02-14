# load connection parameters (ssh keys, gateway)
conn_config = File.join(ENV["HOME"], ".xpm", "connection.rb")

if File.exist?(conn_config)
  load conn_config
end

load "config/deploy/xp5k.rb"
