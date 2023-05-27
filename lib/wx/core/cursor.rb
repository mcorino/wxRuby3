
module Wx

  def self.Cursor(name, bmp_type = Wx::CURSOR_DEFAULT_TYPE, *rest)
    art_path = File.dirname(caller_path = caller_locations(1).first.absolute_path)
    art_owner = File.basename(caller_path, '.*')
    art_file = ArtLocator.find_art(name, :icon, art_path: art_path, art_owner: art_owner, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Cursor" unless art_file
    Cursor.new(art_file, bmp_type, *rest)
  end

end
