# run.rb
require 'optparse'
require 'json'
require 'csv'
require 'fileutils'
require 'memory_profiler'

# Require files from the app folder
Dir["./app/**/*.rb"].each { |file| require file }
require './test/test.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: run.rb [options]"

  opts.on("-v", "--version", "Show version") do
    options[:version] = true
  end

  opts.on("-s", "--sample", "Run Sample") do
    options[:run_sample] = true
  end

  opts.on("-c", "--script", "Run the script in Readme") do
    options[:run_script] = true
  end

  opts.on("-t", "--test", "Run test cases") do
    options[:run_tests] = true
  end

  opts.on("-h", "--help", "Display this help") do
    puts opts
    exit
  end

  # Define other options as per your application requirements
end.parse!


if options[:version]
  puts "App version 1.0.0"
elsif options[:run_sample]
  puts "It works"
elsif options[:run_script]
  App.new("files/pages").run_script
elsif options[:run_tests]
  Test.run("test/cases")
else
  puts "No Action Requested."
end
