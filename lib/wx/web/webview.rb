# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  module WEB

    WEBVIEW_DEFAULT_URL_STR = 'about:blank'
    WEBVIEW_BACKEND_WEB_KIT = 'wxWebViewWebKit'
    WEBVIEW_BACKEND_CHROMIUM = 'wxWebViewChromium'
    WEBVIEW_BACKEND_EDGE = 'wxWebViewEdge'
    WEBVIEW_BACKEND_DEFAULT = case Wx::PLATFORM
                               when 'WXOSX'
                                 if Wx.has_feature?(:USE_WEBVIEW_WEBKIT)
                                   WEBVIEW_BACKEND_WEB_KIT
                                 elsif Wx.has_feature?(:USE_WEBVIEW_CHROMIUM)
                                   WEBVIEW_BACKEND_CHROMIUM
                                 else
                                   ''
                                 end
                               when 'WXMSW'
                                 if Wx.has_feature?(:USE_WEBVIEW_EDGE) || Wx.has_feature?(:USE_WEBVIEW_EDGE_STATIC)
                                   WEBVIEW_BACKEND_EDGE
                                 elsif Wx.has_feature?(:USE_WEBVIEW_CHROMIUM)
                                   WEBVIEW_BACKEND_CHROMIUM
                                 else
                                   ''
                                 end
                               when 'WXGTK'
                                 if Wx.has_feature?(:USE_WEBVIEW_WEBKIT2) || Wx.has_feature?(:USE_WEBVIEW_WEBKIT)
                                   WEBVIEW_BACKEND_WEB_KIT
                                 elsif Wx.has_feature?(:USE_WEBVIEW_CHROMIUM)
                                   WEBVIEW_BACKEND_CHROMIUM
                                 else
                                   ''
                                 end
                               else
                                 ''
                               end
    WEBVIEW_NAME_STR = 'WebView'

    class WebView < Wx::Control

      class << self
        # Redefine #new method to support positional and named
        # arguments
        WEBVIEW_NEW_PARAMS = [Wx::Parameter[:id, Wx::StandardID::ID_ANY],
                              Wx::Parameter[:url, WEBVIEW_DEFAULT_URL_STR],
                              Wx::Parameter[:pos, Wx::DEFAULT_POSITION],
                              Wx::Parameter[:size, Wx::DEFAULT_SIZE],
                              Wx::Parameter[:backend, WEBVIEW_BACKEND_DEFAULT],
                              Wx::Parameter[:style, 0],
                              Wx::Parameter[:name, WEBVIEW_NAME_STR]]

        wx_new = instance_method(:new)
        wx_redefine_method :new do |*args, **kwargs|

          if args.size == 1 && args.first.is_a?(::String)
            wx_new.bind(self).call(*args) # no need for keyword scanning
          elsif ::Wx::WXWIDGETS_VERSION >= '3.3.0' && args.size == 1 && args.first.is_a?(Wx::WEB::WebViewConfiguration)
            wx_new.bind(self).call(*args) # no need for keyword scanning
          else
            full_args = []

            full_args << args.shift # get parent argument

            begin
              args = Wx::args_as_list(WEBVIEW_NEW_PARAMS, *args, **kwargs)
            rescue => err
              err.set_backtrace(caller)
              Kernel.raise err
            end

            # update the full arguments list with the optional arguments
            full_args.concat(args)

            # Call original add with full args
            wx_new.bind(self).call(*full_args)
          end

        end

      end

    end

  end
end
