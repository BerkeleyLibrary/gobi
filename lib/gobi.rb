require 'marc'
require 'yaml'
require 'fileutils'
require_relative 'logging'
include Logging

module GOBI

DATA_DIR = File.expand_path(File.join(__dir__, '../data'))
FIXTURES_DIR = File.expand_path(File.join(__dir__, '../spec/fixtures'))
OUT_DIR = File.join(DATA_DIR, 'gobi_processed')
INCOMING_DIR = File.join(DATA_DIR, 'incoming')
PROCESSED = File.join(DATA_DIR, 'incoming/processed')
PROVIDER_PATH = File.expand_path(File.join(__dir__, '../config'))
DEFAULT_INPUT_DIR = File.join(DATA_DIR, 'incoming')

#get 3 letter Gobi providers
@gobi_providers = YAML.load_file(File.join(PROVIDER_PATH,'gobi_providers.yml'))
def self.watch!(directory = nil, interval: 120)
  directory ||= DEFAULT_INPUT_DIR
  raise ArgumentError, "Watch directory '#{directory}' is not a directory or symlink to a directory" \
    unless File.directory?(directory) || \
        (File.symlink?(directory) && File.directory?(File.readlink(directory)))

  raise ArgumentError, "interval must be a positive integer" \
    unless interval > 0 and interval.to_i == interval

  pattern = File.expand_path(File.join(directory, '*.ord'))
  logger.info "GOBI: Watching #{pattern} for updates"

  while true
    Dir.glob(pattern) do |filepath|
      begin
        logger.info "Processing file: #{filepath}"
        process!(filepath)
      rescue StandardError => e
        logger.info "Error processing #{filepath}: #{e}"
      end
    end

    logger.info "... pausing #{interval}s before checking for new files"
    sleep interval
  end
end

# Copies fixtures files into the default data directory
def self.seed!
  Dir.glob("#{FIXTURES_DIR}/*.ord") do |filepath|
    FileUtils.cp(filepath, File.join(DEFAULT_INPUT_DIR, File.basename(filepath)))
  end
end

#delete 
def self.clear!
  logger.info "Deleting .ord files under #{DATA_DIR}"
  FileUtils.rm_f(Dir.glob(File.join(DATA_DIR, '**/*.ord')))
end

#clear and reseed data directory
def self.refresh!
  logger.info "Deleting .ord files under #{DATA_DIR}"
  clear!

  logger.info "reseeding .ord files from fixtures"
  seed!
end

def self.write_marc(rec,outfile)
  logger.info "GOBI: Going to write marc file"
  writer = MARC::Writer.new(outfile)
  writer.write(rec)
  writer.close
end

#Gobi provider code is the first 3 characters in the 961 $d
def self.get_provider(rec)
  logger.info "GOBI: Getting provider"
  if rec['961'] && rec['961']['d']
    provider = rec['961']['d'][0,3]
    logger.info "GOBI: Provider found #{provider}"
    return provider 
  end
end

#output filehandle will be have the provider code or will be blank if the provider
#961 $d is blank or not defined in gobi_providers
def self.get_output_filehandle(fname,provider)
  if @gobi_providers.include?(provider) 
    outfile = fname.gsub('ebook',"ebook#{provider}")
  else
    outfile = fname.gsub('ebook','ebookZZZ')
  end

  logger.info "GOBI: Opening filehandle for #{outfile}" 
  fh = open(File.join(OUT_DIR,outfile),'a')
end

def self.process!(fname)
    logger.info "GOBI: Going to process #{fname}"
	  reader = MARC::Reader.new(fname, :external_encoding => "UTF-8")
	  for record in reader
	    provider = get_provider(record)
	    outfile = get_output_filehandle(File.basename(fname),provider)
	    write_marc(record,outfile)  
	  end
	
    logger.info "GOBI: Finished processing #{fname}"
	  #File processed move to processed directory.
	  FileUtils.mv fname,File.join(PROCESSED,File.basename(fname))
    logger.info "GOBI: moved #{fname} to #{PROCESSED}"
end


end
