# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class WebView < Window

      include Typemap::IOStreams
      include Typemap::DateTime

      def setup
        spec.items << 'wxWebViewHistoryItem'
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.items << 'wxWebViewConfiguration'
        end
        super
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.gc_as_object 'wxWebViewConfiguration'
          spec.no_proxy 'wxWebViewConfiguration'
          spec.extend_interface 'wxWebViewConfiguration', 'wxWebViewConfiguration()', visibility: 'protected'
          spec.make_abstract 'wxWebViewConfiguration'
          # not useful in wxRuby
          spec.ignore 'wxWebViewConfiguration::GetNativeConfiguration'
        end
        spec.gc_as_untracked 'wxWebViewHistoryItem'

        spec.no_proxy 'wxWebView'
        spec.ignore 'wxWebView::RegisterFactory'
        spec.ignore 'wxWebView::GetNativeBackend'
        if Config.instance.features_set?('WXMSW', 'USE_WEBVIEW_IE')
          spec.include 'wx/msw/webview_ie.h', 'wx/msw/registry.h'
          spec.add_extend_code 'wxWebView', <<~__CODE
            // Have to add our own version here as wxw gets the execution module name wrong. 
            static bool msw_set_ie_emulation_level(wxWebViewIE_EmulationLevel level = wxWEBVIEWIE_EMU_IE11)
            {
              // Registry key where emulation level for programs are set
              static const wxChar* IE_EMULATION_KEY =
                  wxT("SOFTWARE\\\\Microsoft\\\\Internet Explorer\\\\Main")
                  wxT("\\\\FeatureControl\\\\FEATURE_BROWSER_EMULATION");
          
              wxRegKey key(wxRegKey::HKCU, IE_EMULATION_KEY);
              // Check the existence of the key and create it if it does not exist
              if ( !key.Exists() && !key.Create() )
              {
                  wxLogWarning(_("Failed to find web view emulation level in the registry"));
                  return false;
              }
          
              const wxString programName = wxT("ruby.exe");
              if ( level != wxWEBVIEWIE_EMU_DEFAULT )
              {
                  if ( !key.SetValue(programName, level) )
                  {
                      wxLogWarning(_("Failed to set web view to modern emulation level"));
                      return false;
                  }
              }
              else
              {
                  if ( !key.DeleteValue(programName) )
                  {
                      wxLogWarning(_("Failed to reset web view to standard emulation level"));
                      return false;
                  }
              }
          
              return true;
            }
            __CODE
        else
          spec.ignore 'wxWebViewIE_EmulationLevel'
        end
        if Config.instance.wx_version_check('3.1.1') >= 0
          spec.map 'wxString *output' => 'String,nil' do
            map_in ignore: true, temp: 'wxString tmp', code: '$1 = &tmp;'
            map_out ignore: 'bool'
            map_argout code: <<~__CODE
              if (result)
              {
                $result = WXSTR_TO_RSTR(tmp$argnum);
              }
              else
              {
                $result = Qnil;
              }
              __CODE
          end
        end
        if Config.instance.wx_version_check('3.1.6') >= 0
          # do not support inherently unsafe 'void* clientData'
          spec.ignore 'wxWebView::RunScriptAsync', ignore_doc: false
          spec.add_extend_code 'wxWebView', <<~__CODE
            void RunScriptAsync(const wxString& javascript)
            {
              $self->RunScriptAsync(javascript, nullptr);
            }
            __CODE
          spec.map 'void* clientData', swig: false do
            map_in ignore: true, code: ''
          end
        end

        spec.add_swig_code <<~__CODE
          %include <wx_ruby_shared_ptr.i>
          %wx_ruby_shared_ptr(wxWebViewHandler, wxWebViewHandler);
          %wx_ruby_shared_ptr(wxWebViewArchiveHandler, wxWebViewHandler);
          %wx_ruby_shared_ptr(wxWebViewFSHandler, wxWebViewHandler);

          %include <wx_shared_ptr.i>
          %wx_shared_ptr(wxWebViewHistoryItem);
          __CODE

        spec.map 'wxSharedPtr<wxWebViewHandler>' => 'Wx::WebViewHandler>' do
          map_in code: <<~__CODE
            void* argp$argnum;
            int res$argnum = SWIG_ConvertPtr($input, &argp$argnum, SWIGTYPE_p_WxRubySharedPtrT_wxWebViewHandler_wxWebViewHandler_t,  0 );
            if (!SWIG_IsOK(res$argnum)) {
              SWIG_exception_fail(SWIG_ArgError(res2), Ruby_Format_TypeError( "", "WxRubySharedPtr< wxWebViewHandler, wxWebViewHandler >","RegisterHandler", 2, argv[0] )); 
            }  
            if (!argp2) {
              SWIG_exception_fail(SWIG_NullReferenceError, Ruby_Format_TypeError("invalid null reference ", "WxRubySharedPtr< wxWebViewHandler, wxWebViewHandler >","RegisterHandler", 2, argv[0]));
            } else {
              arg2 = *(reinterpret_cast< WxRubySharedPtr< wxWebViewHandler, wxWebViewHandler > * >(argp2));
            }
            __CODE
        end

        spec.map 'wxVector< wxSharedPtr<wxWebViewHistoryItem> >' => 'Array<Wx::WEB::WebViewHistoryItem>' do
          map_out code: <<~__CODE
              $result = rb_ary_new();
              wxVector< wxSharedPtr<wxWebViewHistoryItem> > *history = (wxVector< wxSharedPtr<wxWebViewHistoryItem> > *)&$1;
              for (wxSharedPtr<wxWebViewHistoryItem>& hist_item : *history)
              {
                VALUE r_hist = SWIG_NewPointerObj(new wxSharedPtr<wxWebViewHistoryItem>(SWIG_STD_MOVE(hist_item)), SWIGTYPE_p_wxSharedPtrT_wxWebViewHistoryItem_t, SWIG_POINTER_OWN);
                rb_ary_push($result, r_hist);
              }
            __CODE
        end

        spec.map 'wxSharedPtr<wxWebViewHistoryItem>' => 'Wx::WEB::WebViewHistoryItem', swig: false do
          map_in code: ''
        end

        # fix event definitions
        if Config.instance.wx_version_check('3.3.0') >= 0
          # completely missing up and until 3.3.2 but should be there
          if Config.instance.wx_version_check('3.3.2') <= 0
            spec.add_swig_code %Q{%constant wxEventType wxEVT_WEBVIEW_BROWSING_DATA_CLEARED = wxEVT_WEBVIEW_BROWSING_DATA_CLEARED;}
          end
        end
      end

    end # class WebView

  end # class Director

end # module WXRuby3
