
module Wx

  def self.Cursor(name, bmp_type = nil, *rest)
    art_path = File.dirname(caller_path = caller_locations(1).first.absolute_path)
    art_owner = File.basename(caller_path, '.*')
    art_file = ArtLocator.find_art(name, art_type: :icon, art_path: art_path, art_section: art_owner, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Cursor" unless art_file
    Cursor.new(art_file, bmp_type || Wx::Bitmap::BITMAP_TYPE_GUESS[File.extname(art_file).sub(/\A\./,'')], *rest)
  end

end
