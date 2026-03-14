# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class WebViewHandler < Director

      include Typemap::IOStreams
      include Typemap::MBConv

      def setup
        spec.items.concat %w[wxWebViewArchiveHandler wxWebViewFSHandler wxWebViewHandlerRequest wxWebViewHandlerResponse wxWebViewHandlerResponseData]
        super
        spec.gc_as_untracked 'wxWebViewHandler', 'wxWebViewArchiveHandler', 'wxWebViewFSHandler'
        spec.make_abstract 'wxWebViewHandler'
        spec.gc_as_untracked 'wxWebViewHandlerRequest', 'wxWebViewHandlerResponse', 'wxWebViewHandlerResponseData'
        spec.no_proxy 'wxWebViewHandlerRequest', 'wxWebViewHandlerResponse'
        spec.make_abstract 'wxWebViewHandlerRequest'
        spec.make_abstract 'wxWebViewHandlerResponse'
        spec.make_abstract 'wxWebViewHandlerResponseData'
        spec.add_swig_code <<~__CODE
          %include <wx_shared_ptr.i>
          %wx_shared_ptr(wxWebViewHandlerResponse);
          %wx_shared_ptr(wxWebViewHandlerResponseData);
          __CODE
        spec.map 'wxSharedPtr<wxWebViewHandlerResponse>' => 'Wx::WEB::WebViewHandlerResponse', swig: false do
          map_in code: ''
        end
        spec.map 'wxSharedPtr<wxWebViewHandlerResponseData>' => 'Wx::WEB::WebViewHandlerResponseData', swig: false do
          map_in code: ''
        end
        spec.suppress_warning(473,
                              'wxWebViewHandler::GetFile',
                              'wxWebViewArchiveHandler::GetFile',
                              'wxWebViewFSHandler::GetFile',
                              'wxWebViewHandlerResponseData::GetStream')
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end

    end # class WebViewHandler

  end # class Director

end # module WXRuby3
