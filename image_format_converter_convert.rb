#!/usr/bin/env ruby

require 'erb'
require 'logger'
require 'mini_magick'
require 'optparse'
require 'rake'
require 'readline'
require 'todo_runner'
require 'yaml'
require 'zaru'

def invalid_args?
  return true if ARGV[0].nil?
  return true unless File.exist?(ARGV[0])
  return false
end

def prompt(prompt='', newline=false)
  prompt += "\n" if newline
  Readline.readline(prompt, true).squeeze(' ').strip
end

########
##
## Deprecated
##
#######
def enumeration_check(input_files, original_format, logger)
  filenames = []
  input_files.each{ |f| filenames << File.basename(f).gsub(".#{original_format}",'')}
  file_ints = filenames.sort.collect { |i| i.to_i }
  correct_enumeration = (1..file_ints.last).to_a
  difference = correct_enumeration - file_ints
  unless difference.empty?
    continue = prompt("According to file enumeration pattern for HathiTrust, file(s) appear to be missing at #{difference.each{|x| puts x}}. Continue?")
    return if %w[y yes].include?(continue.downcase)
    abort('Cancelling script at user prompt') if %w[n no].include?(continue.downcase)
    abort('Please specify \'y\' or \'n\', aborting.')
  end
end

def validate_option(option_value)
  return option_value == "[optional]" || option_value.nil? ? false : option_value
end

def mogrify_actions(options = {}, image)
  mogrify = MiniMagick::Tool::Mogrify.new
  mogrify.resample(options['ppi']) unless options['ppi'].nil?
  mogrify << image
end

def create_manifest(files, manifest_file)
  link_set = ''
  files.each do |filename, file_link|
    link_set << "<li>#{link_to("#{image_tag(file_link) + filename}", file_link)}</li>"
  end

  @page_style = File.read(File.expand_path '../templates/assets/stylesheets/page_style.css', __FILE__)
  @links = "<ul>#{link_set}</ul>"

  template = File.read(File.expand_path '../templates/views/manifest_template.html.erb', __FILE__)
  result = ERB.new(template).result(binding)
  File.open(manifest_file, 'w+') do |f|
    f.write result
  end
end

def link_to(text, target)
  return "<a href=\"#{target}\">#{text}</a>"
end

def image_tag(image, options = {})
  return "<img src=\"#{image}\" #{"style=\"#{options[:style]}\"" if options[:style]} #{"alt=\"#{options[:alt]}\"" if options[:alt]}/>"
end

def populate_options(config)
  options = {}
  mogrify_keys = ['ppi']
  mogrify_keys.each do |key|
    options[key] = config[key] unless config[key].nil?
  end
  return options
end

def move_and_log_problem(problem_file, logger, original_location)
  problem_location = "#{original_location}/problem"
  logger.warn("Problem detected for #{problem_file}, moving to #{problem_location}")
  FileUtils.mkdir_p(problem_location)
  FileUtils.mv(problem_file,problem_location)
end

flags = {}
OptionParser.new do |opts|
  opts.banner = "Usage: converter.rb [options] MANIFEST.yml OPTIONAL_DELIMITER"

  opts.on("-r", "--rename DELIMITER", "Rename converted files, appending delimiter and checksum, advisable in case of filename collision at the source") do |a|
    flags[:rename] = a
  end

  opts.on("-m", "--manifest MANIFEST_NAME", "Return an HTML manifest") do |a|
    flags[:manifest] = "#{Zaru.sanitize!(a)}"
  end

  opts.on("-k", "--skip-conversion", "Skip image conversion, just return an HTML manifest") do |a|
    flags[:skip_conversion] = a
  end

  opts.on("-s", "--scale DIMENSIONS", "Dimensions to scale derivatives in widthxheight format (optional, example: 800x600)") do |a|
    flags[:scale] = a
  end

end.parse!

abort('Please supply a YML  manifest.') if invalid_args?

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

TodoRunner.define do
  start :process_options

  task :process_options, on_fail: :FAIL, next_step: :perform_options do |todo_file|
    begin
      data = YAML.load todo_file

      flags[:skip_conversion] = validate_option(data[:skip_conversion])
      flags[:manifest] = validate_option(data[:html_manifest_name])
      flags[:rename] = validate_option(data[:rename_delimiter])
      flags[:scale] = validate_option(data[:scale_dimensions])

      true
    rescue Exception => ex
      logger.fatal("ERROR: #{ex.message}")
      false
    end
  end

  task :perform_options, on_fail: :FAIL, next_steps: :log do |todo_file|
    begin
      data = YAML.load todo_file

      rename_delimiter = flags[:rename] ? Zaru.sanitize!(flags[:rename]) : ''

      original_location = data[:original_location]
      converted_location = data[:converted_location]

      original_format = data[:original_format]
      converted_format = data[:converted_format]

      unless flags[:skip_conversion]
        FileUtils.mkdir_p(converted_location)
        original_location = "#{original_location}/*" unless original_location.end_with?('*')
        files = Dir.glob("#{original_location}.#{original_format}")
        mogrify_options = populate_options(data)
        files.each do |file|
          begin
            logger.info("Opening #{file}")
            image = MiniMagick::Image.open(file)
            converted_filename = flags[:rename] ? "#{File.basename(file, '.*')}#{rename_delimiter}#{image.signature}.#{converted_format}" : "#{File.basename(file, '.*')}.#{converted_format}"
            converted_image = "#{converted_location}/#{converted_filename}"
            logger.info("Converting #{file}")
            image.format "#{converted_format}"
            image.resize(flags[:scale]) if flags[:scale]
            logger.info("Writing #{converted_image}")
            image.write "#{converted_image}"
          rescue => exception
            move_and_log_problem(file, logger, original_location) if exception.message.downcase.include?('failed with error')
            next
          end
          unless mogrify_options.empty?
            logger.info("Mogrifying #{file}")
            mogrify_actions(mogrify_options, converted_image)
          end
        end
      end


      if flags[:manifest]
        converted_files_glob = Dir.glob("#{converted_location}/*.#{converted_format}")
        converted_files ||= {}
        converted_files_glob.sort!
        converted_files_glob.each do |c_file|
          converted_files[File.basename(c_file)] = c_file
        end
        manifest_file = flags[:manifest].ext('html')
        create_manifest(converted_files, manifest_file)
        logger.info("HTML manifest written to #{manifest_file}")
      end

    rescue Exception => ex
      logger.fatal("ERROR: #{ex.message}")
      false
    end

    true

  end

end

logger.info('Todo Runner initialized, starting run...')

TodoRunner.run(*ARGV)

logger.info('Run complete.')
