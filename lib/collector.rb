# frozen_string_literal: true

# Question 1
# Write a script that, in parallel, collects the memory used per process across 50 linux hosts.
# The collected information should be output to a suitable metrics back-end via statsd (TICK,
# Prometheus, Statsite). If you are not sure what this is, then please use
# https://github.com/obfuscurity/synthesize. Please do not use an agent such as Telegraf or
# Collectd. We would like to see how you would code this :)

require_relative 'monitor'

Monitor.new.start
