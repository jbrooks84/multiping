require 'rubygems'
require 'icmp4em'

# From - https://github.com/jakedouglas/icmp4em

Signal.trap("INT") { EventMachine::stop_event_loop }

pings = []
pings << ICMP4EM::ICMPv4.new("8.8.8.8", :stateful => true)

Signal.trap("INT") { EventMachine::stop_event_loop }

EM.run {
  pings.each do |ping|
    ping.on_success {|host, seq, latency, count_to_recovery| puts "SUCCESS from #{host}, sequence number #{seq}, Latency #{latency}ms, Recovering in #{count_to_recovery} more"}
    ping.on_expire {|host, seq, exception, count_to_failure| puts "FAILURE from #{host}, sequence number #{seq}, Reason: #{exception.to_s}, Failing in #{count_to_failure} more"}
    ping.on_failure {|host| puts "HOST STATE WENT TO DOWN: #{host} at #{Time.now}"}
    ping.on_recovery {|host| puts "HOST STATE WENT TO UP: #{host} at #{Time.now}"}
    ping.schedule
  end
}
