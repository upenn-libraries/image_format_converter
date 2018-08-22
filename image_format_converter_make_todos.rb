#!/usr/bin/ruby

require 'logger'
require 'smarter_csv'
require 'uuid'
require 'yaml'

require_relative 'lib/naming'

def validate_args!
  raise ArgumentError.new('Please supply a CSV file') if ARGV[0].nil?
  raise ArgumentError.new('Please supply a destination directory') if ARGV[1].nil?
end

HEADERS = %i{ original_location converted_location original_format converted_format ppi html_manifest_name rename_delimiter scale_dimensions skip_conversion }

def create_todo_file(args = {}, dest_dir)
  directory_name = Naming.filename(args[:original_location])
  todo_path = File.join dest_dir, "#{directory_name}.todo"
  data = HEADERS.inject({}) { |h,header| h.merge(header => args[header]) }
  File.open(todo_path, 'w+') { |f| f.puts YAML::dump data }
  return "#{directory_name}.todo"
end

validate_args!

file = ARGV[0]
dest_dir = ARGV[1]

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
logger.info('Make TODOs started')

SmarterCSV.process(file).each do |row|
  todo_filename = create_todo_file(row, dest_dir)
  logger.info("TODO file #{todo_filename} created.")
end

logger.info("Make TODOs complete.  Files available at #{dest_dir}.")