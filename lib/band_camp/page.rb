require "band_camp/song"
require 'net/http'
require 'uri'
require 'harmony'

module BandCamp
  class Page
    def initialize(url, options = {})
      @options = options
      @url = url
    end

    def page_html
      unless @page_html
        puts "Getting content of \"#{@url}\"" if @options[:debug]
        @page_html = Net::HTTP.get(URI.parse(@url))
      end
      @page_html
    end

    def harmony_page
      unless @harmony_page
        # Assigning to a variable first to make the puts statements make sense
        html = page_html
        puts "Initializing headless browser" if @options[:debug]
        @harmony_page = Harmony::Page.new(html)
      end
      @harmony_page
    end

    def songs
      @songs ||= harmony_page.execute_js("TralbumData.trackinfo").map do |song_object|
        Song.new(song_object.title.to_s, song_object.title_link.to_s, song_object.file.to_s, @options)
      end
    end

    def band_name
      harmony_page.execute_js("BandData.name")
    end

    def album_name
      harmony_page.execute_js("TralbumData.current.title")
    end

    def download
      dir = path_for_download
      unless @options[:try]
        `mkdir -p #{dir}`
      end
      songs.each_with_index { |song, index| song.download(dir, index) }
    end

    def path_for_download
      File.join("download",
                BandCamp::file_safe_string(band_name),
                BandCamp::file_safe_string(album_name))
    end
  end
end
