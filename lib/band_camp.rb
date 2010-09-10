require "band_camp/page"
require "band_camp/cli/options"
if Gem.available?("ruby-debug")
  require "ruby-debug"
end

module BandCamp
  def self.file_safe_string(string)
    string.gsub("&", " and ").tr("^a-zA-Z0-9-", "_").gsub(/_+/, "_")
  end
end
