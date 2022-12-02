#--------------------------------------------------------------------
# @file    fs_file.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class FSFile < Director

      def setup
        super
        spec.make_abstract 'wxFSFile'
        spec.ignore %w[wxFSFile::DetachStream wxFSFile::GetStream]
      end

    end # class FSFile

  end # class Director

end # module WXRuby3
