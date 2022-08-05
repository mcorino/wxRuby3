#--------------------------------------------------------------------
# @file    defs.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets constants generator
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './standard'

module WXRuby3

  class DefsGenerator < StandardGenerator

    def gen_swig_header(fout, spec)
      fout << <<~__HEREDOC
        /**
         * This file is automatically generated by the WXRuby3 interface generator.
         * Do not alter this file.
         */

        %include "../common.i"

        %module(directors="1") #{spec.module_name}

        // Version numbers from wx/version.h
        %constant const int wxWXWIDGETS_MAJOR_VERSION = wxMAJOR_VERSION;
        %constant const int wxWXWIDGETS_MINOR_VERSION = wxMINOR_VERSION;
        %constant const int wxWXWIDGETS_RELEASE_NUMBER = wxRELEASE_NUMBER;
        %constant const int wxWXWIDGETS_SUBRELEASE_NUMBER = wxSUBRELEASE_NUMBER;
        // WXWIDGETS_VERSION is defined in lib/wx/version.rb
        
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
        #ifdef __WXMSW__
        #define wxPLATFORM "WXMSW"
        #endif
        #ifdef __WXMAC__
        #define wxPLATFORM "WXMAC"
        #endif

      __HEREDOC
    end

    def gen_swig_interface_code(fout, spec)
      gen_enums(fout, spec)

      gen_defines(fout, spec)

      gen_variables(fout, spec)

      gen_functions(fout, spec)
    end

    def gen_interface_include(spec)
      # noop
    end

    def run(spec)
      super

      # TODO : append type definitions to shared typedefs.i???
      fn_typedefs = File.join(Config.instance.classes_dir, 'common', 'typedefs.i')
      File.open(fn_typedefs, File::CREAT|File::TRUNC|File::RDWR) do |f|
        f << <<~__HEREDOC
          /**
           * This file is automatically generated by the WXRuby3 interface generator.
           * Do not alter this file.
           */
        __HEREDOC
        gen_typedefs(f, spec)
      end
    end

  end # class DefsGenerator

end # module WXRuby3
