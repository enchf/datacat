# frozen_string_literal: true

require_relative 'os_strategies'

class Monitor
  def initialize(osname)
    @strategy = OSStrategies.for(osname)
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
