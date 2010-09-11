module BandCamp
  module Cli
    module Options
      require 'optparse'

      def self.extract_from_argv
        options = {}
        options[:debug] = true

        OptionParser.new do |opts|
          opts.banner = "Usage: example.rb [options]"

          opts.on("-d", "--[no-]debug", "Output debug information") do |v|
            options[:debug] = v
          end

          opts.on("-a", "--all", "If the url does not contain songs but links to tracks/albums: download all those") do |v|
            options[:all] = v
          end
        end.parse!
        options
      end
    end
  end
end
