# frozen_string_literal: true

require_relative 'command_executor'
require_relative 'os_strategies'

class Monitor
  include CommandExecutor

  PUSHGATEWAY_HOST = ENV['PUSHGATEWAY_HOST']
  PUSHER_COMMAND = "echo \"%{data}\" | curl --data-binary @- #{PUSHGATEWAY_HOST}/metrics/job/%{pid}/instance/%{instance}"

  DATA_TEMPLATE = "# TYPE cpu_usage gauge\n" \
                  "memory_usage_%{pid}{label=\"Memory Usage\",command=\"%{command}\",instance=\"%{instance}\",pid=\"%{pid}\"} %{memory_usage}\n"

  def initialize(delay = 10)
    osname = execute('uname')

    @delay = delay
    @strategy = OSStrategies.for(osname)
  end

  def start
    loop do
      collect
        .map { |entry| { data: DATA_TEMPLATE % entry, pid: entry[:pid], instance: entry[:instance] } }
        .each { |message| (PUSHER_COMMAND % message).tap(&method(:puts)).tap { |command| execute(command) } }

      sleep(@delay)
    end
  end

  # Gives a list of hash with :pid, :memused, :command.
  def collect
    @strategy.collect
  end

  # Return the hostname of the instance.
  def hostname
    @strategy.hostname
  end
end
