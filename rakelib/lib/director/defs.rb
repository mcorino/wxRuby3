# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Defs director
###

module WXRuby3

  class Director

    class Defs < Director

      def setup
        spec.items.replace ['defs.h']
        spec.ignore %w{
          wxINT8_MIN
          wxINT8_MAX
          wxUINT8_MAX
          wxINT16_MIN
          wxINT16_MAX
          wxUINT16_MAX
          wxINT32_MIN
          wxINT32_MAX
          wxUINT32_MAX
          wxINT64_MIN
          wxINT64_MAX
          wxUINT64_MAX
          wxVaCopy
          wxDELETE
          wxDELETEA
          wxSwap
        }
        if Config.instance.wx_version >= '3.2.7'
          spec.ignore %w[wxWARN_UNUSED]
        end
        spec.ignore 'wxOVERRIDE'
        super
      end

      def generator
        WXRuby3::DefsGenerator.new(self)
      end
      protected :generator

      def rake_generator
        WXRuby3::DefsRakeGenerator.new(self)
      end
      protected :rake_generator

    end # class Defs

  end # class Director

  class DefsGenerator < InterfaceGenerator

    def gen_swig_header(fout)
      fout << <<~__HEREDOC
        /**
         * This file is automatically generated by the WXRuby3 interface generator.
         * Do not alter this file.
         */

        %include "../common.i"

        %module(directors="1") #{module_name}

        // Version numbers from wx/version.h
        %constant const int wxWXWIDGETS_MAJOR_VERSION = wxMAJOR_VERSION;
        %constant const int wxWXWIDGETS_MINOR_VERSION = wxMINOR_VERSION;
        %constant const int wxWXWIDGETS_RELEASE_NUMBER = wxRELEASE_NUMBER;
        %constant const int wxWXWIDGETS_SUBRELEASE_NUMBER = wxSUBRELEASE_NUMBER;
        // WXWIDGETS_VERSION is defined in lib/wx/core.rb
        
        #ifdef __WXDEBUG__
        %constant const bool wxDEBUG = true;
        #else
        %constant const bool wxDEBUG = false;
        #endif
                 
        // Platform constants
        
        #ifdef __WXMOTIF__
        #define wxPLATFORM "WXMOTIF"
        #endif
        #ifdef __WXX11__
        #define wxPLATFORM "WXX11"
        #endif
        #ifdef __WXGTK__
        #define wxPLATFORM "WXGTK"
        #endif
        #ifdef __WXQT__
        #define wxPLATFORM "WXQT"
        #endif
        #ifdef __WXMSW__
        #define wxPLATFORM "WXMSW"
        #endif
        #ifdef __WXOSX__
        #define wxPLATFORM "WXOSX"
        #endif

      __HEREDOC
    end

    def gen_interface_include_code(fout)
      gen_enums(fout)

      gen_defines(fout)

      gen_variables(fout)

      gen_functions(fout)
    end

    def run
      Stream.transaction do
        f = CodeStream.new(File.join(Config.instance.classes_dir, 'common', 'typedefs.i'))
        f << <<~__HEREDOC
          /**
           * This file is automatically generated by the WXRuby3 interface generator.
           * Do not alter this file.
           */
        __HEREDOC
        gen_typedefs(f)
      end
      # make sure to keep this last for the parallel builds synchronize on the *.i files
      super
    end

  end # class DefsGenerator

  class DefsRakeGenerator < RakeDependencyGenerator


    def create_rake_tasks(frake)
      super
      frake << <<~__TASK
          file '#{File.join(Config.instance.common_dir, 'typedefs.i')}' => '#{File.join(Config.instance.classes_dir, 'Defs.i')}'
      __TASK
    end
    protected :create_rake_tasks

  end

end # module WXRuby3
