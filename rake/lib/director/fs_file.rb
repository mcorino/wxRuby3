###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class FSFile < Director

      def setup
        super
        spec.make_abstract 'wxFSFile'
        spec.ignore %w[wxFSFile::DetachStream wxFSFile::GetStream]
        spec.make_enum_untyped 'wxFileSystemOpenFlags'
        spec.add_swig_code 'enum wxFileSystemOpenFlags;'
      end

    end # class FSFile

  end # class Director

end # module WXRuby3
