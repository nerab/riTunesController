#
# Controls iTunes via command line
#
# For setters, the equal sign must be part of command, and the assigned value must
# be passed in as the second parameter, e.g.
#
#   ruby iTunes_controller_cmd.rb VisualsEnabled= 1
#
require 'iTunes.rb'

if 0 == ARGV.size
  puts "Error: Command missing."
  puts
  puts "Usage: #{__FILE__} <command> [args]"
  puts
  puts "  where <command> is an iTunes COM method. Any arguments will be passed on."
  exit
end

itunes = ITunes.new
puts itunes.send(ARGV[0].to_sym, *ARGV[1..-1])
