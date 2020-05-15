#!/usr/bin/env ruby
# frozen_string_literal: true

MIN_SIZE = 10
MAX_SIZE = 10_000
INTERVAL = 5

NUM_RANGE = 1..1_000

def sample_of(array)
  "[#{array.take(MIN_SIZE).map(&:to_s).join(', ')}...]"
end  

# Sort a random size array each 5 seconds.
loop do
  size = rand MIN_SIZE..MAX_SIZE
  array = size.times.map { rand NUM_RANGE }

  puts "Sorting a #{size}-size randomly generated array #{sample_of(array)}"
  
  array.sort!
  puts "Sorted array: #{sample_of(array)}"  

  sleep INTERVAL
end
