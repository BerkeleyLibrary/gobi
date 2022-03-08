require 'gobi'
require 'thor'

module GOBI 
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'watch', 'Monitor a directory for new GOBI marc order files to process .'
    method_option :directory, desc: 'The directory to watch for new files', aliases: '-d', default: GOBI::DEFAULT_INPUT_DIR
    method_option :interval, desc: 'Seconds to sleep between scanning for new files', aliases: '-i', default: 120, type: :numeric
    def watch
      GOBI.watch!(options[:directory], interval: options[:interval])
    end

    desc 'process FILEPATH', 'Process the specific GOBI file given by FILEPATH'
    def process(filepath)
      GOBI.process!(filepath)
    end

    desc 'clear', 'Deletes existing processed and error files'
    def clear
      GOBI.clear!
    end

    desc 'seed', 'Seeds the default data directory with fixture files'
    def seed
      GOBI.seed!
    end

    desc 'refresh', 'Deletes processed files and reseeds from fixtures'
    def refresh 
      GOBI.refresh!
    end
  end
end
