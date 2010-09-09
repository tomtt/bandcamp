require "band_camp/song"
require 'net/http'
require 'uri'
require 'harmony'

module BandCamp
  class Band
    def initialize(url)
      @url = url
    end

    def page_html
      unless @page_html
        puts "Getting content of \"#{@url}\""
        @page_html = Net::HTTP.get(URI.parse(@url))
      end
      @page_html
    end

    def harmony_page
      unless @harmony_page
        html = page_html
        puts "Initializing headless browser"
        @harmony_page = Harmony::Page.new(html)
      end
      @harmony_page
    end

    def songs
      @songs ||= harmony_page.execute_js("TralbumData.trackinfo").map do |song_object|
        Song.new(song_object.title.to_s, song_object.title_link.to_s, song_object.file.to_s)
      end
    end

    def name
      harmony_page.execute_js("BandData.name")
    end

    def download
      dir = path_for_download
      `mkdir -p #{dir}`
      songs.each_with_index { |song, index| song.download(dir, index) }
    end

    def path_for_download
      File.join("download", BandCamp::file_safe_string(name))
    end
  end
end
