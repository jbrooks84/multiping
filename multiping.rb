#!/usr/bin/ruby
require 'rubygems'
require 'icmp4em'

@HOST_TABLE = []
@HOST_TABLE2 = []
@node_hostnames = ["8.8.8.8", "8.8.4.4", "4.2.2.1", "4.2.2.2", "4.2.2.3", "4.2.2.4", "4.2.2.5", "4.2.2.6", "google.com", "10.1.1.1"]

@Good = []
@Bad = []

def process_ping()
  node_hostname ||= @HOST_TABLE.pop
  return unless (node_hostname)

  ping = ICMP4EM::ICMPv4.new(node_hostname, :stateful => true, :timeout => 1, :interval => 1)

  ping.on_success {|host, seq, latency, count_to_recovery| puts "SUCCESS from #{host}, sequence number #{seq}, Latency #{latency}ms, Recovering in #{count_to_recovery} more"}
  ping.on_expire {|host, seq, exception, count_to_failure| puts "FAILURE from #{host}, sequence number #{seq}, Reason: #{exception.to_s}, Failing in #{count_to_failure} more"}

  #ping.on_success do |host, seq, latency, count_to_recovery|
  #  process_ping_success(host, seq, latency, count_to_recovery)
  #end

  #ping.on_expire do |host, seq, exception, count_to_failure|
  #  process_ping_expire(host, seq, exception, count_to_failure)
  #end

  ping.schedule

  EM.next_tick do
    process_ping()
  end
end

def process_ping_success(host, seq, latency, count_to_recovery)
  local_host = host
  @Good.push :hostname => "#{local_host}", :result => "SUCCESS"
  count = []
  @Good.each_with_object(Hash.new{|h,k|h[k]='0'}) do |h,res|
    count = res[h['result']].succ!
  end
  @success = []
  @success << ["#{host}", "#{count}"]
end

def process_ping_expire(host, seq, exception, count_to_failure)
  @Bad << "#{host}" << "FAILURE"
  @fail = @Bad.count("FAILURE")
  #puts "Fail - #{host} - #{fail}"
end

def kickoff_process_ping()
  @node_hostnames.each {|n| @HOST_TABLE.push(n)}
  process_ping()
end

def kickoff_table()
  col_length = 10
  str = ""
  str += "| " + "Name".ljust(col_length) + "|" + "Pass".ljust(col_length)
  str += "\n"
  str += "| "
  str += @success[0][0].ljust(col_length)
  str += " | "
  str += @success[0][1].ljust(col_length)
  str += " |\n"
  puts str
end

EM.run {
  EM.add_timer(1) do
    kickoff_process_ping()
  end
  #EM.add_periodic_timer(5) do
  #  kickoff_table()
  #end
}
