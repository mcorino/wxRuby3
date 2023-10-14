# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class FileSystem < Director

      def setup
        super
        spec.items << 'wxFileSystemHandler' << 'wxArchiveFSHandler' << 'wxMemoryFSHandler'
        spec.disable_proxies
        spec.make_abstract 'wxFileSystem'
        spec.gc_as_untracked 'wxFileSystem'
        # ignore all instance methods
        # we only want the static methods to be able to add/remove file system handlers
        spec.ignore %w[
          wxFileSystem::ChangePathTo
          wxFileSystem::FindFileInPath
          wxFileSystem::FindFirst
          wxFileSystem::FindNext
          wxFileSystem::GetPath
          wxFileSystem::OpenFile
        ]
        # redefine to allow more precise arg disown
        spec.ignore 'wxFileSystem::AddHandler (wxFileSystemHandler *)', ignore_doc: true
        spec.extend_interface 'wxFileSystem', 'static void AddHandler (wxFileSystemHandler *in_handler)'
        spec.disown 'wxFileSystemHandler *in_handler'
        spec.make_abstract 'wxFileSystemHandler'
        # ignore unuseful methods
        spec.ignore 'wxMemoryFSHandler::AddFile (const wxString &, const void *, size_t)',
                    'wxMemoryFSHandler::AddFileWithMimeType(const wxString &, const void *, size_t, const wxString &)'
        spec.do_not_generate :enums
      end
    end # class FileSystem

  end # class Director

end # module WXRuby3
