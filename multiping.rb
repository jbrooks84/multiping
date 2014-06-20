require 'rubygems'
require 'icmp4em'

Signal.trap("INT") { EventMachine::stop_event_loop }

#host = ICMP4EM::ICMPv4.new("8.8.8.8")
#host.on_success {|host, seq, latency| puts "Got echo sequence number #{seq} from host #{host}. It took #{latency}ms." }
#host.on_expire {|host, seq, exception| puts "I shouldn't fail on loopback interface, but in case I did: #{exception.to_s}"}

#EM.run { host.schedule }

pings = []
pings << ICMP4EM::ICMPv4.new("8.8.8.8", :stateful => true)
pings << ICMP4EM::ICMPv4.new("10.1.0.175", :stateful => true)

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
