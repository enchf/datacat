# frozen_string_literal: true

require 'prometheus/client'
require 'prometheus/client/push'

require_relative 'command_executor'
require_relative 'strategies/os_strategies'

module DataCat
  class Monitor
    include CommandExecutor

    PUSHGATEWAY_HOST = ENV['PUSHGATEWAY_HOST']

    def initialize(delay = 10)
      osname = execute('uname')

      @delay = delay
      @strategy = OSStrategies.for(osname)
      
      @memory_usage = Prometheus::Client::Gauge.new(:memory_usage, 
                                                    docstring: 'Memory usage per process',
                                                    labels: %i[process host],
                                                    preset_labels: { host: hostname })
      @prometheus = Prometheus::Client.registry
      @prometheus.register(@memory_usage)
    end

    def start
      loop do
        collect
          .each do |entry|
            puts "Updating value of process #{entry[:pid]} to #{entry[:memory_usage]}"
            @memory_usage.set(entry[:memory_usage],
                              labels: { process: entry[:pid] })
          end

        puts 'Pushing to Prometheus...'  
        Prometheus::Client::Push.new(hostname).add(@prometheus)  
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
end
