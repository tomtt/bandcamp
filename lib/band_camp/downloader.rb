require 'net/http'
require 'uri'

module BandCamp
  class Downloader
    def self.download(options)
      url = options[:url] || raise(ArgumentError, "No url provided")
      file_name = options[:file_name] || raise(ArgumentError, "No file_name provided")

      puts "Saving #{file_name}" if options[:debug]

      parsed_url = URI.parse(url)
      res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http|
        http.get("#{parsed_url.path}?#{parsed_url.query}")
      }

      File.open(file_name, "w") do |file|
        file.puts res.body
      end
    end
  end
end
