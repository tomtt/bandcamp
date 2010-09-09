require "band_camp/band"

module BandCamp
  def self.file_safe_string(string)
    string.tr("^a-zA-Z0-9-_", "_").gsub(/_+/, "_")
  end
end
