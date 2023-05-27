
module Wx

  module ArtLocator

    ART_FOLDER = 'art'

    class << self

      # This is not put in a constants as cannot retrieve image handler info
      # before an app has started
      def art_extensions(art_type)
        unless @art_extensions
          @art_extensions = {
            icon: if Wx::PLATFORM == 'WXMSW'
                    %w[ico xpm]
                  elsif Wx::PLATFORM == 'WXGTK'
                    (%w[xpm]+Image.extensions).uniq
                  else
                    (%w[xbm xpm]+Image.extensions).uniq
                  end,
            bitmap: if Wx::PLATFORM == 'WXMSW'
                      (%w[bmp xpm]+Image.extensions).uniq
                    elsif Wx::PLATFORM == 'WXGTK'
                      (%w[xpm]+Image.extensions).uniq
                    else
                      (%w[xbm xpm]+Image.extensions).uniq
                    end,
            cursor: if Wx::PLATFORM == 'WXMSW'
                      %w[cur ico bmp]
                    elsif Wx::PLATFORM == 'WXGTK'
                      []
                    else
                      %w[xbm]
                    end,
            image: Image.extensions
          }
        end
        @art_extensions[(art_type || :image).to_sym] || []
      end
      private :art_extensions

      def art_folder
        @art_folder ||= ART_FOLDER
      end

      def art_folder=(name)
        @art_folder = name ? name.to_s : ART_FOLDER
      end

      def search_paths
        @search_paths ||= []
      end
      private :search_paths

      def add_search_path(*paths)
        paths.flatten.each { |p| paths << s.to_s unless paths.include?(s.to_s) }
      end
      alias :add_search_paths :add_search_path

      def _find_art(art_name, art_type, art_path, art_owner, bmp_type)
        art_paths = [art_path, File.join(art_path, art_folder)]
        art_paths << File.join(art_paths.last, art_type.to_s) if art_type
        art_paths << File.join(art_paths.last, art_owner) if art_owner
        art_paths.reverse_each do |sp|
          (bmp_type ? (Image.handler_extensions[bmp_type] || []) : art_extensions(art_type)).each do |ext|
            fp = File.join(sp, "#{art_name}.#{ext}")
            return fp if File.file?(fp)
          end
        end
        nil
      end
      private :_find_art

      def find_art(art_name, art_type = nil, art_path: nil, art_owner: nil, bmp_type: nil)
        unless art_path
          caller_path = caller_locations(1).first.absolute_path
          art_path = File.dirname(caller_path)
          art_owner ||= File.basename(caller_path, '.*')
        end
        bmp_type = nil if bmp_type == Wx::BitmapType::BITMAP_TYPE_ANY
        unless fp = _find_art(art_name.to_s, art_type, art_path, art_owner, bmp_type)
          search_paths.find { |sp| fp = _find_art(art_name.to_s, art_type, sp, art_owner, bmp_type) }
        end
        fp
      end

    end

  end

end
